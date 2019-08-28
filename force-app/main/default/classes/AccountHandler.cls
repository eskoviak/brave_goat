public with sharing class AccountHandler {
    public AccountHandler() {

    }

    public static Account insertNewAccount(String newAcctName) {
        try {
            Account acct = new Account(Name = newAcctName);
            insert acct;
            return acct;
        } catch (DmlException e) {
            return null;
        }
    }
 

}