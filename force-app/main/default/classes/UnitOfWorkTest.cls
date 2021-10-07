@IsTest
private class UnitOfWorkTest {

    @isTest static void challengeComplete() {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Contact.SObjectType,
                Account.SObjectType,
                Note.SObjectType
            }
        );
        for(Integer a=0; a<100; a++){
            Account acc = new Account();
            acc.Name = 'OoW Test name' + a;
            acc.Support_Tier__c = 'Bronze';
            uow.registerNew(acc);
            for(integer i=0; i<5; i++) {
                Contact c = new Contact();
                //Contact.AccountId = acc.Id;
                c.LastName = 'UoW Test name' + (a*5)+i;
                uow.registerNew(c, Contact.AccountId, acc);
                Note n = new Note();
                n.Title = 'UoW Test Title' + (1*5)+i;
                uow.registerNew(n, Note.ParentId, acc);
            }
        }
        uow.commitWork();
        System.assertEquals(100, [Select Id From Account].size());
        System.assertEquals(500, [Select Id from Contact].size());
        System.assertEquals(500, [Select Id from Note].size());

    }
}