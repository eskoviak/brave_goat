global with sharing class XDMConnection 
    extends DataSource.Connection {
    
        private String APIMUrl;
        private String SubcriptionKey;
        private String PhoneRegEx;

        public XDMConnection(DataSource.ConnectionParams connectionParams) {
            this.APIMUrl = connectionParams.endpoint;
            this.SubcriptionKey = connectionParams.oauthToken;
            this.PhoneRegEx = '^[\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$';
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
            columns.add(DataSource.Column.text('MelissaPersonatorAddress.PostalCode'));
            tables.add(DataSource.Table.get('Person', 'FullPersonName', columns));
            return tables;
        }

        /**
         * The Query Function -- this is called whenever a query (SOQL) is executed against the external object.  The
         * query particulars are passed in the QueryContext argument.
         */
        override global DataSource.TableResult query(DataSource.QueryContext context) {
            if (context.tableSelection.columnsSelected.size() == 1 &&
                context.tableSelection.columnsSelected.get(0).aggregation ==
                    DataSource.QueryAggregation.COUNT) {
                    List<Map<String,Object>> rows = getRows(context);
                    List<Map<String,Object>> response =
                        DataSource.QueryUtils.filter(context, getRows(context));
                    List<Map<String, Object>> countResponse =
                        new List<Map<String, Object>>();
                    Map<String, Object> countRow =
                        new Map<String, Object>();
                    countRow.put(
                        context.tableSelection.columnsSelected.get(0).columnName,
                        response.size());
                    countResponse.add(countRow);
                    return DataSource.TableResult.get(context, countResponse);
            } else {
                return DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, getRows(context));
            }
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
/*
        global override List<DataSource.UpsertResult> upsertRows(DataSource.UpsertContext context) {
            if (context.tableSelected == 'Sample') {
                List<DataSource.UpsertResult> results = new List<DataSource.UpsertResult>();
                List<Map<String, Object>> rows = context.rows;

                for (Map<String, Object> row : rows){
                    // Make a callout to insert or update records in the external system.
                    HttpResponse response;
                    // Determine whether to insert or update a record.
                    if (row.get('ExternalId') == null){
                        // Send a POST HTTP request to insert new external record.
                        // Make an Apex callout and get HttpResponse.
                        response = makePostCallout(
                            '{"name":"' + row.get('Name') + '","ExternalId":"' + 
                            row.get('ExternalId') + '"');
                    } else {
                        // Send a PUT HTTP request to update an existing external record.
                        // Make an Apex callout and get HttpResponse.
                        response = makePutCallout(
                            '{"name":"' + row.get('Name') + '","ExternalId":"' + 
                            row.get('ExternalId') + '"',
                            String.valueOf(row.get('ExternalId')));
                    }

                    // Check the returned response.
                    // Deserialize the response.
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(
                            response.getBody());
                    if (response.getStatusCode() == 200){
                        results.add(DataSource.UpsertResult.success(
                                String.valueOf(m.get('id'))));
                    } else {
                        results.add(DataSource.UpsertResult.failure(
                                String.valueOf(m.get('id')), 
                                'The callout resulted in an error: ' + 
                                response.getStatusCode()));
                    }
                } 
                return results;
            } 
            return null;
        }


        global override List<DataSource.DeleteResult> deleteRows(DataSource.DeleteContext context) {
            if (context.tableSelected == 'Sample'){
                List<DataSource.DeleteResult> results = new List<DataSource.DeleteResult>();
                for (String externalId : context.externalIds){
                    HttpResponse response = makeDeleteCallout(externalId);
                    if (response.getStatusCode() == 200){
                        results.add(DataSource.DeleteResult.success(externalId));
                    }  else {
                        results.add(DataSource.DeleteResult.failure(externalId, 'Callout delete error:' + response.getBody()));
                    }
                }
                return results;
            }
            return null;
        }

        //  Private helper functions
        // Helper method to get record values from the external system for the Sample table.
        private List<Map<String, Object>> getRows () {
            // Get row field values for the Sample table from the external system via a callout.
            HttpResponse response = makeGetCallout();
            // Parse the JSON response and populate the rows.
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(
                    response.getBody());
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            if (error != null) {
                throwException(string.valueOf(error.get('message')));
            }
            List<Map<String,Object>> rows = new List<Map<String,Object>>();
            List<Object> jsonRows = (List<Object>)m.get('value');
            if (jsonRows == null) {
                rows.add(foundRow(m));
            } else {
                for (Object jsonRow : jsonRows) {
                    Map<String,Object> row = (Map<String,Object>)jsonRow;
                    rows.add(foundRow(row));
                }
            }
            return rows;
        }
*/
        /**
         * Helper function to perform query operation.
         */
        private List<Map<String, Object>> getRows(DataSource.QueryContext context){
            DataSource.TableSelection table = context.tableSelection;
            List<Map<String,Object>> rows = new List<Map<String,Object>>();
            // Handle Person Table -- FROM Person__x
            if(table.tableSelected == 'Person') {
                String personKey;
                DataSource.Filter filter = table.filter;
                // Handle Query by ExternalId (PersonKey) -- WHERE ExternalId = <>
                // special case -- will only return zero or one row
                personKey = (String)filter.columnValue;  // Map ExternalId -> PersonKey
                // REST Callout
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(this.APIMUrl + '/semarchy/api/rest/query/RWS_MDM_PRD/Person/GD/' + personKey);
                request.setMethod('GET');
                request.setHeader('Ocp-Apim-Subscription-Key',this.SubcriptionKey);
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> row = new Map<String, Object>();
                    for(DataSource.ColumnSelection item : table.columnsSelected){
                        row.put(item.columnName, m.get(item.columnName));
                    }
                    row.put('ExternalId', personKey);  // Map PersonKey -> ExteranlId.  Prevents Null ExteranlId.
                    rows.add(row);
                } else {
                    // TODO Handle other cases (400, 500)
                }
            }
            return rows;
        }

        /**
         * Helper function to perform the search operation.
         */
        private List<Map<String, Object>> getRows(DataSource.SearchContext context) {
            List<Map<String,Object>> results = new List<Map<String,Object>>();
            for( DataSource.TableSelection table : context.tableSelections) {
                // Handle person table
                if (table.tableSelected == 'Person') {
                    Pattern phonePattern = Pattern.compile(this.PhoneRegEx);
                    if (phonePattern.matcher(context.searchPhrase).matches()) {
                        String phoneNumber = context.searchPhrase.replace('() .-', '');
                        // REST Callout
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(this.APIMUrl + '/semarchy/api/rest/named-query/RWS_MDM_PRD/GetConsumersByPhone/GD/?PhoneNumber=' +
                           context.searchPhrase.replace('() .-', ''));
                        request.setMethod('GET');
                        request.setHeader('Ocp-Apim-Subscription-Key',this.SubcriptionKey);
                        //List<Object> records = new List<Map<String, Object>>();
                        HttpResponse response = http.send(request);                        
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
            }
            return results;
        }
}
