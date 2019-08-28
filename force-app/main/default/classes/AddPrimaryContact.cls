public class AddPrimaryContact implements Queueable {

    private Contact contact;
    private String state;

    public AddPrimaryContact(Contact contact, String state) {
        this.contact = contact;
        this.state = state;
    }

    public void execute(QueueableContext qc){
        List<Contact> contacts = new List<Contact>();
        List<Account> accounts = [SELECT id, BillingState FROM Account WHERE BillingState = :state ];
        for(Account account : accounts){
            Contact contactClone = contact.clone();
            contactClone.AccountId = account.Id;
            contacts.add(contactClone);
        }
        insert contacts;
    }
}
