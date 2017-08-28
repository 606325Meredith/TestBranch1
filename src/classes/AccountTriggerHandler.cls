/*****************************************************************************************
Class Name: AccountTriggerHandler
Purpose: Handler class for account trigger
******************************************************************************************
Version         DateModified          ModifiedBy              			    Change
1.0             13/04/2017           Rakesh Ramaswamy (PwC)               Initial Development.
1.1				20/04/2017			 Rakesh Ramaswamy (PwC)				  Inclusion of Assert checks.
******************************************************************************************/
public class AccountTriggerHandler
{   
    /*********************************
    Method: executeOnBeforeUpdate
    Purpose: Method executed for before update event on account object
    *********************************/
    public void executeOnBeforeUpdate()
     {
        Set<ID> setAccID = new Set<ID>();        
        //lopping over account details
        for(Account acc : ((List<Account>)Trigger.new))
         {
            //getting all account id where owner has changed
            if(acc.OwnerID != ((Account)Trigger.OldMap.get(acc.ID)).OwnerID)
             {
                setAccID.add(acc.ID);       
             }
         }
        
        //getting list of account share for those account
        if(!setAccID.isEmpty())
         {
         	// Using an application wide constant list collection to query and set the AccountShare records that were originally tied to the Account, which is getting its ownership updated.
         	// We need to perform this as the shares get deleted post update of ownership on the Account object, so it is imperative to fetch the share data in the before update context.
            AcostaConstants.lstAccountShareToInsert = [select AccountAccessLevel,AccountId,UserOrGroupId,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel from AccountShare where RowCause = 'Manual' and AccountId in:setAccID limit 10000];
         }        
        
        // This is a boolean checker just to prevent this logic from running multiple times in a transaction involving DML(s) on the Account object.
        // Under Update DML context.
        // This is to check in the before update context.
        AcostaConstants.accountBeforeUpdateExecuted = true;    
     }
    
    /*********************************
    Method: executeOnAfterUpdate
    Purpose: Method executed for after update event on account object
    *********************************/
    public void executeOnAfterUpdate()
     {
        //if there are account share records to be inserted
        if(!AcostaConstants.lstAccountShareToInsert.isEmpty())
         {
            //inserting those accountshare again
            list<AccountShare> lstAccShare = new list<AccountShare>();
            
            // Re-iterating through the application constant list collection to add AccountShares that are bound to get deleted post ownership updates on the Account record.
            for(AccountShare accShare :AcostaConstants.lstAccountShareToInsert)
             {
                lstAccShare.add(accShare.clone());
             } 
            
            if(!lstAccShare.isEmpty())
             {
             	// Re-inserting all the Account Shares into the system due to ownership updates.
                insert lstAccShare;
             }             
         }
         
        // This is a boolean checker just to prevent this logic from running multiple times in a transaction involving DML(s) on the Account object.
        // Under Update DML.
        // This is to check in the after update context.    
        AcostaConstants.accountAfterUpdateExecuted = true;     
     }
}