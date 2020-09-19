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
        public MelissaPersonatorAddress MelissaPersonatorAddress;
    }

    public class MelissaPersonatorAddress {
        public String PostalCode;
        public String FormattedAddress;
    }
    
    public static XDMPerson parse(String json) {
        return (XDMPerson) System.JSON.deserialize(json, XDMPerson.class);
    }
}
