@isTest
private class AccountTrigger_Test {
    @isTest static void TestCreateNewAccountInBulk() {
        // Test Setup data
        // Create 200 new Accounts
        List<Account> accts = new List<Account>();
        for(Integer i=0; i < 200; i++) {
            Account acct = new Account(BillingState = 'CA', Name = 'Test Acct ' + i);
            accts.add(acct);
        }              
+        // Perform Test
        Test.startTest();
        insert accts;                               
        Test.stopTest();
        // Verify that 200 new Accounts were inserted
        List<Account> verifyAccts = [SELECT Id FROM Account];
        System.assertEquals(200, verifyAccts.size());    
        // Also verify that 200 new Opportunities were inserted
        //List<Opportunity> v;erifyOpps = [SELECT Id FROM Opportunity];                              
        //System.assertEquals(200, verifyOpps.size());
        for (Account a : verifyAccts){
            String BillingSt = a.BillingState;
            System.assertEquals('CA', BillingSt);        
        }
    }
}