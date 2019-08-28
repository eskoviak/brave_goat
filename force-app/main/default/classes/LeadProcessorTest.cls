@isTest
private class LeadProcessorTest {
    
    @testSetup
    static void setup() {
    	List<Lead> leads = new List<lead>();
        for (Integer i=0; i<200; i++) {
            leads.add(new Lead(LastName='lead '+i, Company='you keep', Status='Open - Not Contacted', leadsource = 'testscript'));
        }
        insert leads;
    }
    
    static testmethod void test() {
        Test.startTest();
        LeadProcessor lp = new LeadProcessor();
        Id batchId = Database.executeBatch(lp);
        Test.stopTest();
        System.assertEquals(200, [SELECT count() FROM Lead WHERE LeadSource = 'Dreamforce']);
    }
}