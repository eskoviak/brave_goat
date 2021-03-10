@IsTest
private class AccountManagerTest {
    @isTest static void testGetAccount() {
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://yourInstance.salesforce.com/services/apexrest/Accounts/'
            + recordId
            + '/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;

        // call the method to test
        Account account = AccountManager.getAccount();
    }

    static Id createTestRecord() {
        Account accountTest = new Account(
            Name = 'The Neighborhood'
        );

        Contact contactTest = new Contact(
            FirstName = 'Fred',    
            LastName = 'Rodgers',
            AccountId = accountTest.Id
        );
        insert accountTest;
        insert contactTest;
        return accountTest.Id;


    }

}