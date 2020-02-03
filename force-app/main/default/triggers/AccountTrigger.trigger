trigger AccountTrigger on Account (before insert,
                                   before update,
                                   before delete,
                                   after insert, 
                                   after update,
                                   after delete,
                                   after undelete)
{
      if(Trigger.isbefore && Trigger.isInsert){
		AccountTriggerHandler.CreateAccounts(Trigger.New);                                           
      }                                       

}