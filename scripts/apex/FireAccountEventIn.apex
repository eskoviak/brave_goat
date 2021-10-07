AccountEventIn__e event = new AccountEventIn__e(Account_ID__c='0011U00001ve33tQAA', Credit_App_Status__c = 'Approved');

Database.SaveResult result = EventBus.publish(event);
// Inspect publishing results
if (!result.isSuccess()) {
    for (Database.Error error : result.getErrors()) {
        System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
    }
}
