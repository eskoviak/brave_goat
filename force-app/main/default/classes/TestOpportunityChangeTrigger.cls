@isTest
public class TestOpportunityChangeTrigger {
    @isTest static void testCreateAndUpdateOpportunity() {
        insert new Opportunity(
            Name = 'Sell 100 Widgets',
            StageName = 'Prospecting',
            CloseDate = Date.Today().addMonths(3)
        );
        Test.getEventBus().deliver();
        Opportunity[] oppList = [SELECT StageName FROM Opportunity];
        Opportunity opp = oppList[0];
        opp.StageName = 'Closed Won';
        update opp;
        Test.getEventBus().deliver();
        Task[] taskList2 = [SELECT Id,Subject FROM Task];
        System.assertEquals(2, taskList2.size(),
            'The change event trigger did not create the expected task.');        

    }
}