global with sharing class XDMConnection 
    extends DataSource.Connection {
    
        private String APIMUrl;
        private String SubcriptionKey;
        private Pattern phonePattern;

        public XDMConnection(DataSource.ConnectionParams connectionParams) {
            this.APIMUrl = connectionParams.endpoint;
            this.SubcriptionKey = connectionParams.oauthToken;
            this.phonePattern = Pattern.compile('^[\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$');
        }

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

        /**
         * The Query Function -- this is called whenever a query (SOQL) is executed against the external object.  The
         * query particulars are passed in the QueryContext argument.
         */
        override global DataSource.TableResult query(DataSource.QueryContext context) {
            return DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, getRows(context));
        }

        /**
         * The Search function -- this is called whenever a search (SOSL) is executed against the external object.  The
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
         * Helper function to perform query operation.  Note this is different (in signature DataSource.QueryContext) from the getRows for Search.
         */
        private List<Map<String, Object>> getRows(DataSource.QueryContext context){
            DataSource.TableSelection table = context.tableSelection;
            DataSource.Filter filter = table.filter;
            List<Map<String,Object>> rows = new List<Map<String,Object>>();

            // Handle Person Table -- FROM Person__x
            if(table.tableSelected == 'Person') {
                // Handle Query by ExternalId (PersonKey) -- WHERE ExternalId = <>
                if ( filter.columnName == 'ExternalId') {
                    HttpResponse response = getXDMData(this.APIMUrl + 
                        '/semarchy/api/rest/query/RWS_MDM_PRD/Person/GD/' + 
                        '?$f=PersonKey=' + (String)filter.columnValue);  // Map ExternalId -> PersonKey
                        if (response.getStatusCode() == 200) {
                            XDMPerson persons = XDMPerson.parse(response.getBody());
                            for(XDMPerson.Person person : persons) {
                                Map<String, Object> row = new Map<String, Object>();
                                for(DataSource.ColumnSelection item : table.columnsSelected) {
                                    row.put(item.columnName, person.columnName);
                                }
                                rows.add(row);
                            }

/* 
                            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                            Map<String, Object> row = new Map<String, Object>();
                            for(DataSource.ColumnSelection item : table.columnsSelected){
                                row.put(item.columnName, m.get(item.columnName));
                            }
                            row.put('ExternalId', personKey);  // Map PersonKey -> ExteranlId.  Prevents Null ExteranlId.
                            rows.add(row);

 */                            
                        } else {
                            // TODO Handle other cases (400, 500)
                        }
                }
            }
            return rows;
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
                             requires a join at semarchy and this is the fastest way to do that
                            */
                            if (this.phonePattern.matcher(searchTokens[0]).matches()) {
                                HttpResponse response = getXDMData('/semarchy/api/rest/named-query/RWS_MDM_PRD/GetConsumersByPhone/GD/?PhoneNumber=' +
                                    searchTokens[0].replace('() .-', ''));
                                if (response.getStatusCode() == 200) {
                                    XDMPhoneResp phones = XDMPhoneResp.parse(response.getBody());
                                    for(XDMPhoneResp.Records person : phones.records) {
                                        Map<String, Object> row = new Map<String, Object>();
                                        row.put('ExternalId', person.Person.PersonKey);
                                        row.put('FirstName', person.Person.FirstName);
                                        row.put('FullPersonName', person.Person.FullPersonName);
                                        results.add(row);
                                    }
                                } else {
                                    // Handle other Responses (404, etc.)
                                }
                            }
                        }
                        when 2 { }
                        when 3 {
                            Map<String, Object> row = new Map<String, Object>();
                            row.put('ExternalId', '9999999999');
                            row.put('FirstName', searchTokens[0]);
                            row.put('LastName', searchTokens[1]);
                            row.put('FullPersonName', searchTokens[0]+' '+searchTokens[1]);
                            results.add(row);
                        }
                    }
                }
            }
            return results;
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
