@isTest
public class AddPrimaryContactTest {
    @TestSetup
    static void setup(){
        List<Account> acctNY = new List<Account>();
        List<Account> acctCA = new list<Account>();
        for(Integer i=0; i<50; i++){
            acctNY.add(new Account(name='NY '+i, BillingState = 'NY'));
            acctCA.add(new Account(name='CA '+i, BillingState = 'CA'));
        }
        insert acctNY;
        insert acctCA;

    }

    static testmethod void testQueueable() {
        AddPrimaryContact apc = new AddPrimaryContact(new Contact(FirstName='Luigi', LastName='Luzone'), 'CA');
        Test.startTest();
        System.enqueueJob(apc);
        Test.stopTest();
        System.assertEquals(50, [SELECT count() FROM Contact WHERE name='Luigi Luzone'], 'Something Bad Happend to Luigi');
    }
}
