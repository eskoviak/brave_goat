public with sharing class CreateContactExtension {

    private final Sobject parent;
    public Contact theContact {get; set;}
    public String lastError {get; set;}

    public CreateContactExtension(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        theContact = new Contact();
        theContact.PersonKey__c = parent.id;
        //theContact.FirstName = parent.FirstName;
        //theContact.LastName = parent.LastName;
    }
}