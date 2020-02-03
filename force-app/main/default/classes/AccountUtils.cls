public class AccountUtils {
    public static List<Account> accountsByState(string acctBillingState) {
        List<Account> accts = [SELECT id, name FROM Account where billingState = :acctBillingState];
        return accts;
    } 

}