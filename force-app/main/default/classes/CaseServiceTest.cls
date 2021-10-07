@IsTest
private class CaseServiceTest {
    @isTest static void testCloseCase(){
        Id recordId = createTestRecord();
        String comments = 'Other';
        CaseService.closeCases(new Set<Id> {recordId}, comments);
        Case thisCase = [SELECT Id, Status, Comments, Reason FROM Case WHERE Id=:recordId];
        System.assertEquals('Closed', thisCase.Status);
        System.assertEquals(comments, thisCase.Reason);
        //System.assertEquals(comments, thisCase.Comments);

    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Case caseTest = new Case(
            Subject='Test record',
            Status='New',
            Origin='Phone',
            Priority='Medium',
            Comments='Added for run');
        insert caseTest;
        return caseTest.Id;
    } 
}