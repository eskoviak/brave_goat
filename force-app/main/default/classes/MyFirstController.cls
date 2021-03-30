public with sharing class MyFirstController {
    public String getName() {
        return 'Ed is a controller';
    }

    public Person__x getPerson() {
        return [ SELECT FirstName__c, LastName__c FROM Person__x WHERE ExternalId = :Apexpages.currentPage().getParameters().get('id')][0];

    }
}
