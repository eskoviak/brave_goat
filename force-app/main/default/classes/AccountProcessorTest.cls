@isTest
private class AccountProcessorTest {
    @TestSetup
    static void makeData(){
        List<Account> accts = new List<Account>();
        for(integer i = 0; i<100; i++){
            accts.add(new Account(name='test '+i, Number_of_Contacts__c = null));
        }
        insert accts;        
    }
    @isTest static void testAccountProcessor() {
        // Get list of Ids
        Map<Id, Account> m = new Map<Id, Account>(new List<Account>([SELECT Id, Name FROM Account]));
        List<Id> acctIds = new List<Id>();
        for (Id id : m.keySet() ){
            acctIds.add(id);
        }
        Test.startTest();
        AccountProcessor.countContacts(acctIds);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Number_of_Contacts__c = null]);
    }
}