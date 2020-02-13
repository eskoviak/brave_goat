trigger OrderEventTrigger on Order_Event__e (after insert) {
    List<Task> tasks = new List<Task>();
    for( Order_event__e event: Trigger.New){
        if (event.Has_Shipped__c == true) {
            Task myTask = new Task();
            myTask.Subject = 'Other';
            myTask.Priority = 'Medium';
           	myTask.Description = 'Follow up on shipped order: ' + event.Order_Number__c;
            myTask.OwnerId = event.CreatedById;
            tasks.add(myTask);
        }
    }
    insert tasks;
}