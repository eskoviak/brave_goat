/**
 * XDMConnection is the servicing class for the the Salesforce Connect access to the Semarchy
 * xDM Application (Master Data Management system).SELECT  FROM Account
 * 
 * Or
 */
global with sharing class XDMConnection 
    extends DataSource.Connection {
    
        /**
         * Internal Properties
         */
        private String APIMUrl;
        private String SubcriptionKey;
        private String DataLocation;
        private String apiVersion;
        private Pattern phonePattern;
        private Pattern PostalCodePattern;

        /**
         * Internal Enums
         */
        private enum Entity { Person, PersonPhone }
        private enum View { GD, MD, GH }

        public XDMConnection(DataSource.ConnectionParams connectionParams) {
            this.APIMUrl = connectionParams.endpoint;
            this.SubcriptionKey = connectionParams.oauthToken;
            // For Semarchy On AWS
            this.DataLocation = 'RWS_MDM_PRD';
            this.apiVersion = '1';

            this.phonePattern = Pattern.compile('^[\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$');
            this.PostalCodePattern = Pattern.compile('^[0-9]{5}(?:-[0-9]{4})?$');
        }

        ///// SYNC

        /**
         * <p>The sync function is called during registration and sync to define the tables (objects)
         * available in the external object.</p>
         * 
         * @return List<DataSource.Table> The list of tables which this connection supports.
         */
        override global List<DataSource.Table> sync() {
            List<DataSource.Table> tables = new List<DataSource.Table>();

            /**
             * <p>Person Table -- Other than ExternalId, which is mapped to PersonKey, all other
             * column names are as they appear in the JSON response from the API call.  This
             * prevents needing to double map the data.</p>
             */
            List<DataSource.Column> personColumns = new List<DataSource.Column>();
            ///// Person Table
            // These are required, standard fields
            personColumns.add(DataSource.Column.text('ExternalId', 255)); // will be mapped to PersonKey
            personColumns.add(DataSource.Column.url('DisplayUrl'));
            // JSON Response fields -- Note these are selected from the larger dataset which is returned.
            personColumns.add(DataSource.Column.text('FullPersonName'));
            personColumns.add(DataSource.Column.text('FirstName'));
            personColumns.add(DataSource.Column.text('LastName'));
            personColumns.add(DataSource.Column.text('MiddleName'));
            personColumns.add(DataSource.Column.text('EnrichedPrimaryPhone'));
            personColumns.add(DataSource.Column.text('EnrichedPrimaryEmail'));
            personColumns.add(DataSource.Column.text('MPA_FormattedAddress'));
            personColumns.add(DataSource.Column.text('MPA_PostalCode'));
            personColumns.add(DataSource.Column.indirectLookup('Contact', 'Contact', 'Person_Key__c'));
            tables.add(DataSource.Table.get('Person', 'FullPersonName', personColumns));

            ///// PersonSales Table
            List<DataSource.Column> personSalesColumns = new List<DataSource.Column>();
            // These are required, standard fields
            personSalesColumns.add(DataSource.Column.text('ExternalId', 255)); // will be mapped to CustomerID
            personSalesColumns.add(DataSource.Column.url('DisplayUrl'));
            // JSON Response fields -- Note these are selected from the larger dataset which is returned.
            personSalesColumns.add(DataSource.Column.text('xactDate'));
            personSalesColumns.add(DataSource.Column.integer('storeNumber', 6));
            personSalesColumns.add(DataSource.Column.text('style'));
            personSalesColumns.add(DataSource.Column.text('item'));
            personSalesColumns.add(DataSource.Column.number('netSalesAmt', 18, 3));
            tables.add(DataSource.Table.get('PersonSales', 'xactDate', personSalesColumns));


            return tables;
        }

        ///// QUERY

        /**
         * The Query Function -- this is called by Saleforce whenever a query or SOQL is executed against the external object.  The
         * query particulars are passed in the QueryContext argument.  This may only operate on one table at a time.
         */
        override global DataSource.TableResult query(DataSource.QueryContext context) {
            return DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, queryRows(context));
        }

        /**
         * <p>Helper function to perform query operation.</p>
         * @param context The context of the query
         * @return List<Map<String, Object>> The rows -- Map<String, Object> -- Each Map key represents the column name 
         * defined above; the value is it's contents.  Note:  If the contex.filter.columnsSelected drives the list of columns returned.
         */
        private List<Map<String, Object>> queryRows(DataSource.QueryContext context){
            DataSource.TableSelection table = context.tableSelection;
            DataSource.Filter filter = table.filter;
            List<Map<String,Object>> rows = new List<Map<String,Object>>();
            Map<String, Object> row = new Map<String, Object>();

            // Handle Person Table -- FROM Person__x
            if(table.tableSelected == 'Person') {
                // Handle Query by ExternalId (PersonKey) -- WHERE ExternalId = <>
                if ( filter.columnName == 'ExternalId') {
                    String filterString = 'PersonKey IN ('+ (string)filter.columnValue + ')'; 
                    List<Map<String, Object>> records = queryXdm(Entity.Person, View.GD, filterString);
                    if( ! records.isEmpty()) {
                        for(Map<string, Object> record : records) {
                            row.clear();
                            for(DataSource.ColumnSelection column : table.columnsSelected) {
                                row.put(column.columnName, record.get(column.columnName));
                            }
                            // Make sure the ExternalId is set explicitly
                            row.put('ExternalId', record.get('PersonKey'));
                            row.put('Contact', record.get('PersonKey'));
                            rows.add(row.clone());
                        }
                    }
                }
            } else if (table.tableSelected == 'PersonSales') {
                // Handle Query by ExternalID (PersonKey) -- WHERE ExternalId = <>
                if (filter.columnName == 'ExternalId') {
                    String filterString = 'Gold_PersonKey IN (' + (String)filter.columnValue + ')';
                    List<Map<String, Object>> records = queryXdm(Entity.Person, View.MD, filterString);
                    if (! records.isEmpty()) {

                        // Get the data from the sales hub API
                        List<Map<String, Object>> sales = new List<Map<String, Object>>();
                        for (Map<String, Object> record : records ) {
                            String sourceId;
                            if (record.get('PublisherID') == 'XCENTER') {
                                // fix mangled XCENTER Ids
                                sourceId = 'C' + ((String)record.get('SourceID')).replace('_1', '').leftPad(14, '0');
                            } else {
                                // Assume the other keys aren't mangled
                                sourceId = (String)record.get('SourceID');
                            }
                            sales.addAll(querySalesHub((String)record.get('PublisherID'), sourceId));
                        }

                        // populate the dataset
                        for(Map<String, Object> sale : sales) {
                            row.clear();
                            for(DataSource.ColumnSelection column : table.columnsSelected) {
                                row.put(column.columnName, sale.get(column.columnName));
                            }
                            // Make sure the ExternalId is set explicitly
                            row.put('ExternalId', (String)filter.columnValue);
                            rows.add(row.clone());
                        }
                    }
                }
            }
        return rows;
        }

        ///// SEARCH

        /**
         * The Search function -- this is called whenever a search or SOSL is executed against the external object.  The
         * search parameters are passed in the SearchContext argument.
         */
        override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
            List<DataSource.TableResult> results = new List<DataSource.TableResult>();
            for (DataSource.TableSelection tableSelection : context.tableSelections) {
                results.add(DataSource.TableResult.get(true, null, tableSelection.tableSelected, searchRows(context)));
                }
            return results;
        }

        /**
         * Helper function to perform the search operation.
         */
        private List<Map<String, Object>> searchRows(DataSource.SearchContext context) {
            List<Map<String,Object>> results = new List<Map<String,Object>>();
            List<String> searchTokens = getTokens(context.searchPhrase);
            for( DataSource.TableSelection table : context.tableSelections) {
                // Handle person table
                if (table.tableSelected == 'Person') {
                    List<Map<String,Object>> persons = new List<Map<String,Object>>();
                    switch on searchTokens.size() {
                        when 1 {
                            // is it a phone number?
                            if (this.phonePattern.matcher(searchTokens[0]).matches()) {
                                String filterString = 'PhoneNumber=\'' + searchTokens[0] + '\'';
                                List<Map<String, Object>> records = queryXdm(Entity.PersonPhone, View.GD, filterString);                            
                                List<String> FID_Persons = new List<String>();
                                for( Map<String, Object> record : records) {
                                    FID_Persons.add(String.valueOf(record.get('FID_Person')));
                                }
                                persons = queryXdm(Entity.Person, View.GD, 'PersonKey IN ' + String.valueOf(FID_Persons));
                            }
                        }
                        when 2 { }
                        when 3 {
                            /**
                             * Assume that the first two token are 'FirstName' and 'LastName'.  The third can either be the two letter state abbreviation ( match MPA_State)
                             * or a 5 or 5+4 Postal code (MPA_PostalCode)
                             */
                            String filterString = 'FirstName=\''+searchTokens[0].trim() + '\' AND ';
                            filterString += 'LastName=\''+searchTokens[1].trim() + '\' AND ';
                            if(searchTokens[2].length() == 2 ) {
                                filterString += 'MelissaPersonatorAddress.State=\'' + searchTokens[2].toUpperCase() + '\'';
                            } else if (this.PostalCodePattern.matcher(searchTokens[2]).matches()) {
                                filterString += 'MelissaPersonatorAddress.PostalCode=\'' + searchTokens[2] + '\'';
                            }
                            persons = queryXdm(Entity.Person, View.GD, filterString);
                        }
                    }
                    if(persons == null) {
                        throw new DataSource.DataSourceException('Error in searchRows: persons is null');
                    } else {
                        // the row 'names' are mapped to the Person Search Screen
                        Map<String, Object> row = new Map<String, Object>();
                        for( Map<String, Object> person : persons) {
                            row.clear();
                            row.put('ExternalId', person.get('PersonKey'));
                            row.put('FullPersonName', person.get('FullPersonName'));
                            row.put('EnrichedPrimaryPhone', person.get('EnrichedPrimaryPhone'));
                            row.put('EnrichedPrimaryEmail', person.get('EnrichedPrimaryEmail'));
                            row.put('MPA_PostalCode', person.get('MPA_PostalCode'));
                            results.add(row.clone());
                        }
                    }
                }
            }
            return results;
        }

        ///// UTILS



        /**
         * Function to query xDM
         * @param entity -- the Entity to query of the enum Entity
         * @param view -- the View to query base on the enum View
         * @param filter -- the filter string to apply
         * @return List<Map<String, Object>> The rows -- Map<String, Object> -- Each Map key represents the column name 
         * defined above; the value is it's contents.
         */
        private List<Map<String, Object>> queryXdm(Entity e, View v, String filter) {
            if (System.Test.isRunningTest()) {
                // return appropriate mock
                if(e == Entity.Person) {
                    return parse(mockPersonResponse);
                } else if ( e == Entity.PersonPhone) {
                    return parse(mockPersonPhoneResponse);
                } else {
                    throw new DataSource.DataSourceException('Unknown entity in queryXdm test: ' + e);
                }
            } else {
                String xdmUri = ('/semarchy/query/' + this.DataLocation + '/' +
                    e + '/' + v + '/?$f=' + filter).replace(' ', '%20');
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(this.APIMUrl + xDMUri);
                request.setMethod('GET');
                request.setHeader('Ocp-Apim-Subscription-Key',this.SubcriptionKey);
                request.setHeader('x-api-version', this.apiVersion);
                HttpResponse response = http.send(request);
                Integer status = response.getStatusCode();
                // nothing to see here
                if (status == 404) { return new List<Map<String, Object>>(); }
                else if (status == 200) {
                    return parse(response.getBody());
                } else {
                    throw new DataSource.DataSourceException('Error in queryXDM: ' + String.valueOf(status));
                }
            }
        }

        /**
         * Function to query Sales Hub
         */
        private List<Map<String, Object>> querySalesHub(String source, String sourceId) {
            if (System.Test.isRunningTest()) {
                return parse(mockSalesResponse);
            } else {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(APIMUrl + '/consumerDetail/source/' + source + '/consumer/' + sourceId);
                request.setMethod('GET');
                request.setHeader('Ocp-Apim-Subscription-Key',this.SubcriptionKey);
                request.setHeader('x-api-version', this.apiVersion);
                HttpResponse response = http.send(request);
                Integer status = response.getStatusCode();
                // nothing to see here
                if (status == 404) { return new List<Map<String, Object>>(); }
                else if (status == 200) {
                    return parse(response.getBody());
                } else {
                    throw new DataSource.DataSourceException('Error in querySaleHub: ' + String.valueOf(status));
                }
            }
        }

        ///// MOCKS

        /**
         * These mocks only contain enough content to pass the tests
         */
        static String mockPersonPhoneResponse = '{' +
            ' "records": [ ' +
            '   {' +
            '       "PersonPhoneKey": 888888888, ' +
            '       "PhoneNumber": "8885551212",' +
            '       "FID_PersonKey": 17700326' +
            '   }, ' +
            '   {' +
            '       "PersonPhoneKey": 888888889, ' +
            '       "PhoneNumber": "8885551212",' +
            '       "FID_PersonKey": 18350909' +
            '   }' +
            ' ]' +
            '}';

        static String mockPersonResponse = '{' +
        ' "records": [ ' +
        '   {' +
        '       "PersonKey": 17700326,' +
        '       "FullPersonName": "Ludwig Von Beethoven"' +
        '   },' +
        '   {' +
        '       "PersonKey": 18350909,' +
        '       "FullPersonName": "Camille SaintSaens"' +
        '   }' +
        ' ]' +
        '}';

        static String mockSalesResponse = '{' +
        ' "records": [ ' +
        '   {' +
        '       "xactDate": "08/05/2018",' +
        '       "storeNumber": 136,' +
        '       "style": "21684",' +
        '       "item": "00605D 100",' +
        '       "netSalesAmount": 128.99' +
        '   }' +
        ' ]' +
        '}';


        /**
         * getTokens --  parses a phase into a List of tokens, preserving spaces in items that are quoted
         * @param phrase -- The string phrase to be tokenized
         * @return List<String> -- a list of the string tokens found 
         */
        private List<String> getTokens(String phrase){
            phrase = phrase.normalizeSpace();  // remove leading/trailing/multi space
            List<String> tokens = new List<String>();
            Integer testChar;
            Integer startToken = 0;
            Boolean quoteOn = false;
            Boolean tokenOn = false;
            for(Integer i = 0; i< phrase.length(); i++){
                testChar = phrase.charAt(i);

                // 34 = double quote
                if ((testChar == 34)  && !quoteOn) {
                    quoteOn = true;
                    startToken = i+1;
                    tokenOn = true;
                    continue;
                }

                if ((testChar == 34) && quoteOn) {
                    quoteOn = false;
                    tokenOn = false;
                    tokens.add(phrase.substring(startToken, i));
                    continue;
                }

                // 32 = space -- the assumed delimiter
                if (testChar == 32 && quoteOn) {
                    continue;
                }

                if (testChar == 32 && tokenOn) {
                    tokenOn = false;
                    tokens.add(phrase.substring(startToken, i));
                    continue;
                }

                if (tokenOn) {
                    continue;
                }

                if (!tokenOn) {
                    tokenOn = true;
                    startToken = i;
                    continue;
                }
            }
            // handles the end of string with tokenOn
            if(tokenOn) {
                tokens.add(phrase.substring(startToken));
            }      
            return tokens;          
        }

        /**
         * Method parse -- parses the standard return format from XDM into a List of Map<String, Object>,
         * where each map is derived from the objects in the 'records' array
         * 
         * The standard query return format is
         * {
         *      "records" : [
         *          { ... },
         *      ]
         * }
         * 
         * Any function that meets this format, will return a List, based on the named array "records".  The individual maps will
         * have a key for each property in the object, and the value will be mapped to the appropriate JSON format (String, Integer etc.)
         * 
         * @param inputJson the json received from the API
         * @return List<Map<String, Object>> the parsed json data
         * 
         */
        private List<Map<String, Object>> parse(String inputJson) {
            // Apply Xnomis convention to remove the dotted property names in the returned
            // JSON and create the parser
            inputJson = inputJson.replace('MelissaPersonatorAddress.', 'MPA_');
            inputJson = inputJson.replace('InputAddress.', 'IA_');
            JSONParser parser =  JSON.createParser(inputJson);
    
            // Set up local storage
            List<Map<String, Object>>  records = new List<Map<String, Object>>();
            Map<String,Object> record = new Map<String, Object>();
            system.JSONToken token;
            String propertyName;
    
            // advance parser past first token (START_OBJECT)
            if (parser.nextToken() != System.JSONToken.START_OBJECT) {
                // In case the createParser function didn't already puke
                throw new JSONException('Malformed JSON in XDMConnection.parse()');
            }
    
            // expect an array named records
            parser.nextToken();
            if(parser.getCurrentName() != 'records') {
                throw new JSONException('Named array \'records\' not found at top level in XDMConnection.parse()');
            }
    
            while( (token = parser.nextToken()) != null){
    
                if (token == System.JSONToken.START_ARRAY) {
                    records.clear();
                    continue;
                }
    
                if (token == System.JSONToken.START_OBJECT) {
                    continue;
                }
    
                if (token == System.JSONToken.FIELD_NAME ) { 
                    propertyName = parser.getText();
                    token = parser.nextToken();
                    if (token == System.JSONToken.VALUE_NUMBER_INT) {
                        record.put(propertyName, parser.getLongValue());
                    } else if (token == System.JSONToken.VALUE_STRING) {
                        record.put(propertyName, parser.getText());
                    } else if (token == System.JSONToken.VALUE_NULL) {
                        record.put(propertyName, '' );
                    } else if ((token == System.JSONToken.VALUE_TRUE) || (token == System.JSONToken.VALUE_FALSE)) {
                        record.put(propertyName, parser.getBooleanValue());
                    } else {
                        record.put(propertyName, 'UNDEFINED');
                    }
                    continue;
                }
    
                if (token == System.JSONToken.END_OBJECT) {
                    if( ! record.isEmpty() ) {
                        records.add(record.clone());
                        record.clear();
                    }
                    continue;
                }
    
                if (token == System.JSONToken.END_ARRAY ) {
                    continue;
                }
            }
            return records;
        }
}

