/**************************************************************************************
Apex Class Name:  nationalInitiativeTriggerHelper
Version     : 1.0
Created Date    : 9 Sept 2016
Description    :  Whenever the National Initiative record is updated, this class fetches the related Banner Allocations and the Sub-Banner Allocations and updates it.
                 The purpose of this is to trigger the workflows on Banner and Sub-Banner allocation records to fecth the initiatives values on it.

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Raj Balla        9 Sept 2016              Original Version
*************************************************************************************/





public class nationalInitiativeTriggerHelper {


    public static void updateNBAandNSBA(Map<Id,National_Initiative__c> newInitiativeMap)

   {
    List<National_Banner_Allocation__c> NBAlist  = new List<National_Banner_Allocation__c>();
  List<National_Sub_Banner_Allocation__c> NSBAlist  = new List<National_Sub_Banner_Allocation__c>();
  Set<Id> nBAIdSet = new Set<Id>();




       //Query the NBAs that are associated to this Initiative
        NBAlist = [Select Id from National_Banner_Allocation__c where National_Initiative_Lookup__c in : newInitiativeMap.keyset()];

      //Get SBAs assoicated under the NBAs too
         if(NBAlist.size() >0)
             {
               for(National_Banner_Allocation__c nba : NBAlist)
                 {
                   nBAIdSet.add(nba.Id);
                 }
            }

      NSBAlist = [select Id from National_Sub_Banner_Allocation__c where National_Banner_Allocation__c in : nBAIdSet];

   // Update the 2 lists     //Once the list is ready, update it back
         try
            {
                 update NBAlist;

               if(NSBAlist.size()>0)
                {
                  update NSBAlist;
                }

             }

             catch (Exception e)
             {
             }
    }

}