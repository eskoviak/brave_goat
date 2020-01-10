public  class AccountProcessor {
    @future
    public static void countContacts(List<Id> recordIds){
        List<Account> accts = [SELECT Id, Number_of_Contacts__c FROM Account WHERE Id in :recordIds];
        for(Account acct : accts) {
            acct.Number_of_Contacts__c = [SELECT COUNT() FROM Contact WHERE AccountId = :acct.Id];
        }
        update accts;
    } 
}