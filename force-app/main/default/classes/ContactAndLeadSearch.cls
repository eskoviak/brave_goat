public with sharing class ContactAndLeadSearch {
    public ContactAndLeadSearch() {

    }

    public static List<List<SObject>> searchContactsAndLeads(String searchText){
        List<List<sObject>> searchList = [FIND :searchText IN NAME FIELDS RETURNING CONTACT, LEAD];
        return searchList;
    }
}