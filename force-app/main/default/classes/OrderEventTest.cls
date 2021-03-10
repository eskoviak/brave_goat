@isTest
public class OrderEventTest {
    @isTest static void testEvent() {
        Order_Event__e oe = new Order_Event__e(
            Has_Shipped__c = true,
            Order_Number__c = '05181957');

            List<Task> tasks = [SELECT Id from Task];
            System.assertEquals(0, tasks.size());

            Test.startTest();
            Database.SaveResult sr = EventBus.publish(oe);
            Test.stopTest();

            System.assertEquals(true, sr.isSuccess());
            tasks = [SELECT Id from Task];
            System.assertEquals(1, tasks.size());
    }


}