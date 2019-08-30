public class AccountProcessorTrigger implements Schedulable {

    public void execute(SchedulableContext sc){
        Map<Id, Account> m = new Map<Id, Account>(new List<Account>([SELECT Id, Name FROM Account]));
        List<Id> acctIds = new List<Id>();
        for (Id id : m.keySet() ){
            acctIds.add(id);
        }
        AccountProcessor.countContacts(acctIds);
    }
}
