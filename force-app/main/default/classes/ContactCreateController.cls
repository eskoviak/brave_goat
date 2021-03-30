public with sharing class ContactCreateController {
    public Person__x getPerson() {
        return [ SELECT FirstName__c, LastName__c, MiddleName__c, EnrichedPrimaryEmail__c, EnrichedPrimaryPhone__c, MPA_FormattedAddress__c
                 FROM Person__x 
                 WHERE ExternalId = :Apexpages.currentPage().getParameters().get('id')][0];
    }

    public Pagereference submit() {
        return null;
    }

    public Pagereference cancel() {
        return null;
    }
}