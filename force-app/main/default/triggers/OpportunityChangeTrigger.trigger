trigger OpportunityChangeTrigger on OpportunityChangeEvent (after insert) {
    List<Task> tasks = new List<Task>();

    for(OpportunityChangeEvent oce : Trigger.New) {
        Eventbus.ChangeEventHeader h = oce.ChangeEventHeader;
        System.debug('Received change event for ' +
            h.entityName +
            ' for the ' + h.changeType + ' operation.' +
            ' with the isWon: ' +
            oce.isWon);
        if (h.changetype == 'UPDATE' && oce.isWon == true) {
            Task t = new Task();
            t.Subject = 'Follow up on won opportunities: ' + h.recordIds;
            tasks.add(t);
        }

    }
    if(tasks.size() > 0) {
        insert tasks;
    }

}