global with sharing class XDMConnection 
    extends DataSource.Connection {
    
        private String APIMUrl;
        private String SubcriptionKey;
        private Pattern phonePattern;
        private Pattern PostalCodePattern;

        public XDMConnection(DataSource.ConnectionParams connectionParams) {
            this.APIMUrl = connectionParams.endpoint;
            this.SubcriptionKey = connectionParams.oauthToken;
            this.phonePattern = Pattern.compile('^[\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$');
            this.PostalCodePattern = Pattern.compile('^[0-9]{5}(?:-[0-9]{4})?$');
        }

        ///// SYNC

        /**
         * The sync function is called during registration and sync to define the tables (objects)
         * available in the external object
         */
        override global List<DataSource.Table> sync() {
            List<DataSource.Table> tables = new List<DataSource.Table>();

            /**
             * Person Table -- Other than ExternalId, which is mapped to PersonKey, all other
             * column names are as they appear in the JSON response from the API call.  This
             * prevents needing to double map the data.
             */
            List<DataSource.Column> columns = new List<DataSource.Column>();
            // These are required, standard fields
            columns.add(DataSource.Column.text('ExternalId', 255)); // will be mapped to PersonKey
            columns.add(DataSource.Column.url('DisplayUrl'));
            // JSON Response fields -- Note these are selected from the larger dataset which is returned.
            columns.add(DataSource.Column.text('FullPersonName'));
            columns.add(DataSource.Column.text('FirstName'));
            columns.add(DataSource.Column.text('LastName'));
            columns.add(DataSource.Column.text('MiddleName'));
            columns.add(DataSource.Column.text('EnrichedPrimaryPhone'));
            columns.add(DataSource.Column.text('EnrichedPrimaryEmail'));
            columns.add(DataSource.Column.text('MPA_FormattedAddress'));
            columns.add(DataSource.Column.text('MPA_PostalCode'));
            tables.add(DataSource.Table.get('Person', 'FullPersonName', columns));
            return tables;
        }

        ///// QUERY

        /**
         * The Query Function -- this is called by Saleforce whenever a query or SOQL is executed against the external object.  The
         * query particulars are passed in the QueryContext argument.  This may only operate on one table at a time.
         */
        override global DataSource.TableResult query(DataSource.QueryContext context) {
            return DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, getRows(context));
        }

        /**
         * Helper function to perform query operation.  Note this is different (in signature DataSource.QueryContext) from the getRows for Search.
         */
        private List<Map<String, Object>> getRows(DataSource.QueryContext context){
            DataSource.TableSelection table = context.tableSelection;
            DataSource.Filter filter = table.filter;
            List<Map<String,Object>> rows = new List<Map<String,Object>>();
            Map<String, Object> row = new Map<String, Object>();

            // Handle Person Table -- FROM Person__x
            if(table.tableSelected == 'Person') {
                // Handle Query by ExternalId (PersonKey) -- WHERE ExternalId = <>
                if ( filter.columnName == 'ExternalId') {
                    List<String> personKeys = new List<String>();
                    // special case of general search-a-tivity: only one PersonKey; but hey, a list of one is a valid list.
                    personKeys.add( (String)filter.columnValue);
                    List<Map<String, Object>> records = getPersons(personKeys);
                    for(Map<string, Object> record : records) {
                        row.clear();
                        for(DataSource.ColumnSelection column : table.columnsSelected) {
                            row.put(column.columnName, record.get(column.columnName));
                        }
                        // Make sure the ExternalId is set explicitly
                        row.put('ExternalId', record.get('PersonKey'));
                        rows.add(row.clone());
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
            results.add(DataSource.TableResult.get(true, null, tableSelection.tableSelected, getRows(context)));
            }
        return results;
        }

        /**
         * Helper function to perform the search operation.  Different signature than getRows above.
         */
        private List<Map<String, Object>> getRows(DataSource.SearchContext context) {
            List<Map<String,Object>> results = new List<Map<String,Object>>();
            List<String> searchTokens = getTokens(context.searchPhrase);
            for( DataSource.TableSelection table : context.tableSelections) {
                // Handle person table
                if (table.tableSelected == 'Person') {
                    switch on searchTokens.size() {
                        when 1 {
                            /**
                             Test for phone number.  If true, then use name-query GetConsumersByPhone as this
                             requires a join at semarchy and this is the fastest way to do that.  This uses a named-query
                             as the person object is 
                            */
                            if (this.phonePattern.matcher(searchTokens[0]).matches()) {
                                String filterString = '?$f=PhoneNumber=\''+ searchTokens[0] + '\'';
                                HttpResponse response = getXDMData('/semarchy/api/rest/query/RWS_MDM_PRD/PersonPhone/GD/' + filterString);
                                if(response.getStatusCode() == 404) { return results; }
                                if(response.getStatusCode() == 200) {
                                    List<Map<String, Object>> records = XDMPerson.parse(response.getBody());
                                    List<String> FID_Persons = new List<String>();
                                    for( Map<String, Object> record : records) {
                                        FID_Persons.add(String.valueOf(record.get('FID_Person')));
                                    }
                                    List<Map<String, Object>> persons = getPersons(FID_Persons);
                                    Map<String, Object> row = new Map<String, Object>();

                                    if(persons == null) {
                                        row.put('ExternalId', 999999999);
                                        row.put('FullPersonName', 'Persons is null in getRows');
                                        row.put('EnrichedPrimaryPhone', 'Keys '+String.valueOf(FID_Persons));
                                        results.add(row.clone());
                                    } else {
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
                                } else {
                                    // Handle other Responses (404, etc.)
                                }
                            }
                        }
                        when 2 { }
                        when 3 {
                            /**
                             * Assume that the first two are 'FirstName' and 'LastName'.  The third can either be the two letter state abbreviation ( match MPA_State)
                             * or a 5 or 5+4 Postal code (MPA_PostalCode)
                             */
                            String filterString = '?$f=FirstName=\''+searchTokens[0].trim() + '\' AND ';
                            filterString += 'LastName=\''+searchTokens[1].trim() + '\' AND ';
                            if(searchTokens[2].length() == 2 ) {
                                filterString += 'MelissaPersonatorAddress.State=\'' + searchTokens[2].toUpperCase() + '\'';
                            } else if (this.PostalCodePattern.matcher(seachTokens[2]).matches()) {
                                filterString += 'MelissaPersonatorAddress.PostalCode=\'' + seachTokens[2] + '\'';
                            }
                            HttpResponse response = getXDMData('/semarchy/api/rest/query/RWS_MDM_PRD/Person/GD/' + filterString.replace(' ', '%20'));
                            results.add(row);
                        }
                    }
                }
            }
            return results;
        }

        ///// UTILS
 
        /**
         * Helper function to get person or persons using a filter -- this is a common function
         */
        private List<Map<String, Object>> getPersons(List<String> personKeys) {
            String filterString = '?$f=PersonKey IN '+ String.valueOf(personKeys);
            HttpResponse response = getXDMData('/semarchy/api/rest/query/RWS_MDM_PRD/Person/GD/' + filterString.replace(' ', '%20'));
            if(response.getStatusCode() == 200) {
                return XDMPerson.parse(response.getBody());
            } else {
                // TODO Handle other cases (400, 500)
                return null;
            }
        }

        /**
         * Helper function to perform the API call out
         * PARAM xDMUri -- the path to call on semarchy and query params, if any
         */
        private HttpResponse getXDMData(String xDMUri) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(this.APIMUrl + xDMUri);
            request.setMethod('GET');
            request.setHeader('Ocp-Apim-Subscription-Key',this.SubcriptionKey);
            return http.send(request);
        }

        
        /**
         * Helper function to parse a phase into a List of tokens, preserving spaces in items that are quoted 
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
}
