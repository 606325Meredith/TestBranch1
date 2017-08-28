/*****************************************************************************************
Trigger Name: ClientCustomerRelationshipTrigger
Purpose: Trigger on only update DML on Client Customer Relationship (CCR)
******************************************************************************************
Version         DateModified          ModifiedBy		 		              Change
1.0             19/04/2017           Rakesh Ramaswamy (PwC)               Initial Development.
1.1				21/04/2017			 Rakesh Ramaswamy (PWC)				  Updates to handle cloning of instances related to CCR. Refer line no. 19
																		  and also line no. 95 in ClientCustomerRelationshipTriggerTest unit test class.
******************************************************************************************/

trigger ClientCustomerRelationshipTrigger on Client_Customer_Relationship__c (after update, before update) 
 {
    //creating an instance of Client Customer Relationship trigger handler
    ClientCustomerRelationshipTriggerHandler CCRTrigHandler = new ClientCustomerRelationshipTriggerHandler();
    
    //event to execute on before update of Client Customer Relationship records.
    if(Trigger.isBefore && Trigger.isUpdate && !AcostaConstants.CCRBeforeUpdateExecuted)
     {          
        // We are passing oldMap value to be handled from the test class perspective where we need to clone instances of CCR(s) involed in pass by reference issues.
        CCRTrigHandler.executeOnBeforeUpdate(trigger.new, trigger.oldMap);
     }
    
    //event to execute on after update of Client Customer Relationship records.
    if(Trigger.isAfter && Trigger.isUpdate && !AcostaConstants.CCRAfterUpdateExecuted)
     {
        CCRTrigHandler.executeOnAfterUpdate();  
     }           
 }