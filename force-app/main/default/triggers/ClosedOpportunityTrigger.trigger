trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {

    List<Task> newTasks = new List<Task>();

    for( Opportunity opp : [SELECT Id, StageName 
                            FROM Opportunity
                            WHERE Id in :Trigger.new 
                              AND StageName = 'Closed Won']) {
        newTasks.add( new Task(
                Priority = 'Normal',
                Status = 'Not Started',
                Subject = 'Follow Up Test Task',
                WhatId = opp.Id )
        );
    }

    if(newTasks.size() > 0){
        insert newTasks;
    }
}