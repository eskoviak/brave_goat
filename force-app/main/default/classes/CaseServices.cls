public with sharing class CaseServices {

    public static void closeCases(List<Id> caseList, String reason) {
        if (caseList == null || caseList.size() == 0) {
            throw new CaseServiceException('Cases not specified');
        }
        if (reason == null ) {
            throw new CaseServiceException('Close reason cannot be null');
        }

        List<Case> cases = [Select Id, Status, Comments from Case where Id in :caseList];
        List<Case> updCases = new List<Case>();
        for(Case caseToClose : cases){
            caseToClose.Status = 'Closed';
            caseToClose.Comments = reason;
            updCases.add(caseToClose);
        }

        SavePoint sp = Database.setSavePoint();
        try {
            update updCases;
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }

    public class CaseServiceException extends Exception {}

}