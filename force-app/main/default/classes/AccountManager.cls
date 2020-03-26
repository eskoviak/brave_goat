@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountManager {

    @HttpGet
    global static Account getAccount() {
        RestRequest req = RestContext.request;
        Integer start = req.requestURI.indexOf('Accounts/')+9,
            strend = req.requestURI.lastIndexOf('/');
        String accountId = req.requestURI.substring(start, strend);
        Account result = [SELECT Id, Name, (SELECT Id, Name FROM Contacts WHERE AccountId = :accountId) FROM Account WHERE Id = :accountId];

        return result;

    }
}
