/*****************************************************************************************
Trigger Name: AccountTrigger
Purpose: Trigger on any DML on account
******************************************************************************************
Version         DateModified         ModifiedBy		 		              Change
1.0             12/04/2017           Rakesh Ramaswamy (PwC)               Initial Development
******************************************************************************************/
trigger AccountTrigger on Account (before update, after update) {
    
    //creating an instance of account trigger handler
    AccountTriggerHandler accHandler = new AccountTriggerHandler();
    
    //event to execute on before update 
    // AcostaConstants.accountBeforeUpdateExecuted is a constant literal to prevent before update from firing over again due to other hard updates across the CRM application
    if(Trigger.isBefore && Trigger.isUpdate && !AcostaConstants.accountBeforeUpdateExecuted)
     {    	
        accHandler.executeOnBeforeUpdate();
     }
    
    //event to execute on after update
    // AcostaConstants.accountAfterUpdateExecuted is a constant literal to prevent after update from firing over again due to other hard updates across the CRM application
    if(Trigger.isAfter && Trigger.isUpdate && !AcostaConstants.accountAfterUpdateExecuted)
     {
        accHandler.executeOnAfterUpdate();  
     }
}