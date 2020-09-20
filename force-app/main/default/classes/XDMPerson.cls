public with sharing class XDMPerson {
    public XDMPerson() {}

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

    public static XDMPerson parse(String json) {
        /** 
         * Ed Hack:
         * Replace 'MelissaPersonatorAddress.' with 'MPA_' 
         */
        json = json.replaceAll('MelissaPersonatorAddress.', 'MPA_');
        return (XDMPerson) System.JSON.deserialize(json, XDMPerson.class);
    }
}
