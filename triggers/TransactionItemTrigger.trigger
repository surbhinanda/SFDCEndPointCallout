// Trigger is called on transaction item so that endpoint call could be made to send the data to external system.

trigger TransactionItemTrigger on TransactionItem__c (after insert,after update,after delete, after undelete) {
    if(Trigger.isAfter) { 
    TransactionItemTriggerHandler.onAfter(trigger.new,trigger.oldmap); 
   } 

}