/**************************************************************************************
Apex Class Name:  InitiativePlanAccess
Version     : 1.0 
Created Date    : 22 August 2016
Description    : Batch class to give Initiative Plan access to the newly added team members to the account which are having relationship to initiative plan,
                 and also to delete the access sharing records when team member is deleted from the account.               
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anil Nedunuri            22 August 2016              Original Version
*************************************************************************************/

public with sharing class InitiativePlanAccess implements Database.Batchable<sObject>{

        public InitiativePlanAccess(){
                   // Batch Constructor
        }
       
        // Start Method
        public Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator([SELECT ID,NAME, (Select Id from Customer_Visits__r) FROM Customer_Visit__c where master__c =: null]);
        }
      
      // Execute Logic
        public void execute(Database.BatchableContext BC, List<Customer_Visit__c>scope){
          try{
              // Logic to be Executed batch wise     
              Set<Id> cvIds= new Set<Id>();
                     for(Customer_Visit__c custVisit : scope) {
                        cvIds.add(custVisit.Id);
                     }
                   system.debug('Check scopecountcheck' +scope.size());
                   set<Id> setAccIds = new set<Id>();
                   Map<id,set<id>> mapIpAccId = new map<id,set<id>>();
                   Map<id,list<AccountTeamMember>> mapAccIdListTeamId = new Map<id,list<AccountTeamMember>>();
                   
                        for(Customer_Visit_Account_Relationship__c objCustVisitRel : [SELECT ID,NAME,Account__c,Account__r.Id,Customer_Visit__r.Id FROM Customer_Visit_Account_Relationship__c WHERE Customer_Visit__c IN : cvIds]){
                               system.debug('Check objCustVisitRel' +objCustVisitRel);
                               setAccIds.add(objCustVisitRel.Account__c);
                               if (mapIpAccId.containsKey(objCustVisitRel.Customer_Visit__r.Id)){
                                   mapIpAccId.get(objCustVisitRel.Customer_Visit__r.Id).add(objCustVisitRel.Account__c);
                                   
                               }
                               else{    
                                   mapIpAccId.put(objCustVisitRel.Customer_Visit__r.Id, new Set<Id>{objCustVisitRel.Account__c});
                                   
                               }
                                
                        }
                        system.debug('Check mapIpAccId1' +mapIpAccId);   
                              
                               for(AccountTeamMember accTeamMem : [SELECT ID,ACCOUNTID,UserId,CreatedDate FROM AccountTeamMember WHERE ACCOUNTID IN : setAccIds]) {
                                   if (mapAccIdListTeamId.containsKey(accTeamMem.AccountId)){
                                   
                                       mapAccIdListTeamId.get(accTeamMem.AccountId).add(accTeamMem);
                                   }
                                   else{
                                       mapAccIdListTeamId.put(accTeamMem.AccountId, new List<AccountTeamMember>{accTeamMem});     
                                   }                                  
                               }
    
                               
                               system.debug('Check mapAccIdListTeamId1' +mapAccIdListTeamId);
                     Map<Id, Set<Id>> mapCVUser = new Map<Id, Set<Id>>();          
                     for(Customer_Visit__Share cshare :  [Select Id, ParentID, UserOrGroupId from Customer_Visit__Share where ParentID in : cvIds AND RowCause =: Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c]){
                         if(mapCVUser.containsKey(cshare.ParentID)){
                             mapCVUser.get(cshare.ParentID).add(cshare.UserOrGroupId);
                             
                         }
                         else{
                             mapCVUser.put(cshare.ParentID, new Set<Id>{cshare.UserOrGroupId});
                         }    
                     }
                     system.debug('Check mapCVUser11' +mapCVUser);
                     List<Customer_Visit__Share> listCustShare = new List<Customer_Visit__Share>();
                     Set<String> setCVShare = new Set<String>();
                     Set<Id> setChildCVId = new Set<Id>();
                     for(Customer_Visit__c custVisit  : scope){ 
                        if(mapIpAccId.get(custVisit.Id) != null){
                          for(Id accId : mapIpAccId.get(custVisit.Id)){  
                               if(mapAccIdListTeamId.get(accId) != null){
                               for(AccountTeamMember accTmMem : mapAccIdListTeamId.get(accId)){
                               system.debug('Check mapIpAccId11' +mapIpAccId);  
                               system.debug('Check mapAccIdListTeamId11' +mapAccIdListTeamId);
                                           setCVShare.add(String.valueOf(custVisit.Id)+String.valueOf(accTmMem.UserId));
                                           if(accTmMem.CreatedDate > System.Today()-Integer.ValueOf(System.Label.NoOfDaysATMPicked) && (mapCVUser.get(custVisit.Id) == null || !mapCVUser.get(custVisit.Id).contains(accTmMem.UserId))) {
                                              system.debug('Check AccountTeamMember' +accTmMem.CreatedDate); 
                                                // master share
                                                Customer_Visit__Share cShare = new Customer_Visit__Share();
                                                cShare.AccessLevel = AcostaConstants.readAccess;
                                                cShare.ParentID = custVisit.Id;
                                                cShare.UserOrGroupId = accTmMem.UserId;
                                                cShare.RowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;
                                                listCustShare.add(cShare); 
                                            }  
                                              system.debug('Check accTmMem111' +accTmMem); 
                                                for(Customer_Visit__c custVisitChild : custVisit.Customer_Visits__r){
                                                system.debug('Check mapIpAccId111' +mapIpAccId);  
                                                system.debug('Check mapAccIdListTeamId111' +mapAccIdListTeamId);
                                                setCVShare.add(String.valueOf(custVisitChild.Id)+String.valueOf(accTmMem.UserId));
                                                if(accTmMem.CreatedDate > System.Today()-Integer.ValueOf(System.Label.NoOfDaysATMPicked) && (mapCVUser.get(custVisit.Id) == null || !mapCVUser.get(custVisit.Id).contains(accTmMem.UserId))){
                                                //child share
                                                Customer_Visit__Share cvchildShare = new Customer_Visit__Share();
                                                cvchildShare.AccessLevel = AcostaConstants.readAccess;
                                                cvchildShare.ParentID = custVisitChild.Id;
                                                cvchildShare.UserOrGroupId = accTmMem.UserId;
                                                cvchildShare.RowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;
                                                listCustShare.add(cvchildShare); 
                                                
                                                      
                                                }
                                                setChildCVId.add(custVisitChild.Id);                                                         
                                                } 
                                                            
                                                
                                                
                                  }
                                   system.debug('Check mapIpAccId1111' +mapIpAccId); 
                                 }  
                              }
                            }
                          } 

                               
                    //Logic to delete the unwanted Initiative Plan Master shares
                    List<Customer_Visit__Share> listCVShareDelete = new List<Customer_Visit__Share>();     
                                for(Customer_Visit__Share cShare : [Select Id, ParentID, UserOrGroupId from Customer_Visit__Share where ParentID in : cvIds AND RowCause =: Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c]){   
                                           if(!setCVShare.contains(String.valueOf(cShare.ParentID)+String.valueOf(cShare.UserOrGroupId))){
                                                listCVShareDelete.add(cShare);
                                            }
                                } 
                                  // Child Initiative Paln Deletion
                                  for(Customer_Visit__Share cvchildShare : [Select Id, ParentID, UserOrGroupId from Customer_Visit__Share where ParentID in : setChildCVId AND RowCause =: Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c]){   
                                           if(!setCVShare.contains(String.valueOf(cvchildShare.ParentID)+String.valueOf(cvchildShare.UserOrGroupId))){
                                                listCVShareDelete.add(cvchildShare);
                                            }
                                }  
                                
                                   Database.Insert(listCustShare, false);
                                   Database.Delete(listCVShareDelete, false); 
                    }
                    Catch(Exception ex){
                        AcostaConstants.logCustomException('InitiativePlanAccess','execute',ex.getMessage(),ex.getLineNumber());    
        }                  
              }
 
         public void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }