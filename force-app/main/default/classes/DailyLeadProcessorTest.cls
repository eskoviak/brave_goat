@isTest
private class DailyLeadProcessorTest {

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @TestSetup
    static void makeData(){
        List<Lead> testLeads = new List<Lead>();
        for( Integer i=0; i<200; i++){
            testLeads.add(new Lead(LastName='lead '+i, Company='you keep', Status='Open - Not Contacted', leadsource = ''));
        }
        insert testLeads;
    }

    static testmethod void testScheduledJob(){
        Test.startTest();
            String jobId = System.schedule('Update Lead Source', CRON_EXP, new DailyLeadProcessor());   
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Lead WHERE LeadSource = 'Dreamforce'], 'Something not so bad happened');
    }

}