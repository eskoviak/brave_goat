public with sharing class XDMPhoneResp {
    public XDMPhoneResp() {}

    public List<Records> records;
        
    public class Person {
        public Integer PersonKey;
        public String FirstName;
        public String LastName;
        public Object MiddleName;
        public String PostalCode;
        public String EnrichedPrimaryEmail;
        public String EnrichedPrimaryPhone;
        public String FullPersonName;
    }

    public class Records {
        public Person Person;
    }

    
    public static XDMPhoneResp parse(String json) {
        return (XDMPhoneResp) System.JSON.deserialize(json, XDMPhoneResp.class);
    }
}