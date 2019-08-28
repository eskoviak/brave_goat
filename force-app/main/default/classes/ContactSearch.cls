public with sharing class ContactSearch {
    public ContactSearch() {

    }

    public static List<Contact> searchForContacts(String lastName, String mailingPostalCode) {
        List<Contact> contacts = [SELECT ID, Name FROM Contact Where LastName=:lastName AND mailingPostalCode=:mailingPostalCode];
        return contacts;
    }
}