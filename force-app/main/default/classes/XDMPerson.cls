public with sharing class XDMPerson {
    public XDMPerson() {}
/* 
    public List<Person> records;
        
    public class Person {
        public Integer PersonKey;
        public String FullPersonName;
        public String FirstName;
        public String LastName;
        public Object MiddleName;
        public String EnrichedPrimaryPhone;
        public String EnrichedPrimaryEmail;
        public String MPA_PostalCode;
        public String MPA_FormattedAddress;
    }

 */
    public static List<Map<String, Object>> parse(String inputJson) {
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
            // TODO Handle malformed JSON
        }

        // expect an array named records
        parser.nextToken();
        if(parser.getCurrentName() != 'records') {
            // TODO Handle this condition
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