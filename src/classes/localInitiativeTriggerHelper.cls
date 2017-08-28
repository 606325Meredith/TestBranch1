/**************************************************************************************
Apex Class Name:  localInitiativeTriggerHelper
Version     : 1.0 
Created Date    : 9 Sept 2016
Description    :  Whenever the Local Initiative record is updated, this class fetches the related Banner Allocations and the Sub-Banner Allocations and updates it.
                 The purpose of this is to trigger the workflows on Banner and Sub-Banner allocation records to fetch the initiatives values on it. 

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raj Balla        9 Sept 2016              Original Version
*************************************************************************************/








public class localInitiativeTriggerHelper {


    public static void updateLBAandLSBA(Map<Id,Local_Initiative__c> newInitiativeMap) 
       
   {
   
     List<Local_Banner_Allocation__c> LBAlist  = new List<Local_Banner_Allocation__c>(); 
  List<Local_Sub_Banner_Allocation__c> LSBAlist  = new List<Local_Sub_Banner_Allocation__c>(); 
  Set<Id> lBAIdSet = new Set<Id>();
   
   
       //Query the NBAs that are associated to this Initiative
        LBAlist = [Select Id from Local_Banner_Allocation__c where Local_Initiative__c in : newInitiativeMap.keyset()];
       
      //Get SBAs assoicated under the NBAs too
         if(LBAlist.size() >0)
             {
               for(Local_Banner_Allocation__c lba : LBAlist)
                 {
                   lBAIdSet.add(lba.Id);
                 }
            } 

      LSBAlist = [select Id from Local_Sub_Banner_Allocation__c where Local_Banner_Allocation__c in : lBAIdSet];  
 
   // Update the 2 lists     //Once the list is ready, update it back
         try
            {
                 update LBAlist;
              
               if(LSBAlist.size()>0)
                {
                  update LSBAlist;
                }

             }

             catch (Exception e)
             {
             } 
    }

}