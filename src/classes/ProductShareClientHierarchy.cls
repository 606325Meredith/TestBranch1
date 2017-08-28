/**************************************************************************************
Apex Class Name:  ProductShareClientHierarchy
Version     : 1.0 
Created Date    : 7 July 2016
Description    : Batch class to give product sharing for L1,L2,L3 and L4 client account team members. It will also delete the product sharing, when the user is no more part of the
                 client account team. This batch job will pick all the products and then to the corresponding processing.               
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar        7 July 2016              Original Version
*************************************************************************************/
public with sharing class ProductShareClientHierarchy implements Database.Batchable<sObject>{   
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Start method to query all the Products
     */  
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id, Account__c, Account__r.ParentId, Account__r.L2_Country__c , Account__r.L1_Master__c from Product__c ]);       
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Execute method to grant / revoke the product sharing.
     */      
    public void execute(Database.BatchableContext bc, List<Product__c> scope){

        /*
        try{
            Set<Id> setAccId = new Set<Id>();
            Set<Id> setProductId = new Set<Id>();
            //add all the L1,L2,L3 and L4 account Ids to the setAccId
            for(Product__c pro : scope){
                if(pro.Account__c != null){
                    setAccId.add(pro.Account__c); 
                }
                if(pro.Account__r.ParentId != null){
                    setAccId.add(pro.Account__r.ParentId); 
                }
                if(pro.Account__r.L2_Country__c != null){
                    setAccId.add(pro.Account__r.L2_Country__c); 
                }
                if(pro.Account__r.L1_Master__c != null){
                    setAccId.add(pro.Account__r.L1_Master__c); 
                }                        
                setProductId.add(pro.Id);   
            }   
            Map<Id, List<AccountTeamMember>> mapAccIdListATM = new Map<Id, List<AccountTeamMember>>(); 
            //get all the account team members and construct a map with key as account id and value as List of ATM      
            for(AccountTeamMember atm :  [Select UserId, AccountId, CreatedDate, LastModifieddate from AccountTeamMember where AccountId in : setAccId]){     
                if(mapAccIdListATM.containsKey(atm.AccountId)){
                    mapAccIdListATM.get(atm.AccountId).add(atm);
                }
                else{
                    mapAccIdListATM.put(atm.AccountId, new List<AccountTeamMember>{atm});
                }
            }  
            Map<Id, List<AccountTeamMember>> mapProductIdListATM = new Map<Id, List<AccountTeamMember>>();   
            //Loop through the products and construct a map with key as product id and value as List of ATM 
            for(Product__c pro : scope){
                List<AccountTeamMember> listATM = new List<AccountTeamMember>();
                if(mapAccIdListATM.get(pro.Account__c) != null){
                    listATM.addAll(mapAccIdListATM.get(pro.Account__c));
                }
                if(mapAccIdListATM.get(pro.Account__r.ParentId) != null){
                    listATM.addAll(mapAccIdListATM.get(pro.Account__r.ParentId));
                }
                if(mapAccIdListATM.get(pro.Account__r.L2_Country__c) != null){
                    listATM.addAll(mapAccIdListATM.get(pro.Account__r.L2_Country__c));
                }
                if(mapAccIdListATM.get(pro.Account__r.L1_Master__c) != null){
                    listATM.addAll(mapAccIdListATM.get(pro.Account__r.L1_Master__c));
                }
                mapProductIdListATM.put(pro.Id, listATM);
            }  
            
            List<Product__Share> listPShare = new List<Product__Share>();
            Set<String> setPShare = new Set<String>();
            //Logic to create new Product shares
            for(Product__c pro : scope){
                if(mapProductIdListATM.get(pro.Id) != null){
                    for(AccountTeamMember atm : mapProductIdListATM.get(pro.Id)){
                        //create product share if the account team member is added or modified in the last 1 day
                        if(atm.CreatedDate >= System.Today()-Integer.ValueOf(System.Label.NoOfDaysATMPicked) || atm.LastModifieddate >= System.Today()-Integer.ValueOf(System.Label.NoOfDaysATMPicked)){
                            Product__Share pShare = new Product__Share();
                            pShare.AccessLevel = AcostaConstants.readAccess;
                            pShare.ParentID = pro.Id;
                            pShare.UserOrGroupId = atm.UserId;
                            pshare.RowCause = Schema.Product__Share.RowCause.AccountTeam__c;
                            listPShare.add(pShare);                 
                        }                     
                        setPShare.add(String.valueOf(pro.Id)+String.valueOf(atm.UserId));
                    }
                }
            }
            
            //Logic to delete the unwanted product shares
            List<Product__Share> listPShareDelete = new List<Product__Share>();     
            for(Product__Share pShare : [Select Id, ParentID, UserOrGroupId from Product__Share where ParentID in : setProductId AND RowCause =: Schema.Product__Share.RowCause.AccountTeam__c]){   
                if(!setPShare.contains(String.valueOf(pShare.ParentID)+String.valueOf(pShare.UserOrGroupId))){
                    listPShareDelete.add(pShare);
                }
            }
            Database.Insert(listPShare, false);
            Database.Delete(listPShareDelete, false);        
        } 
        Catch(Exception ex){
            AcostaConstants.logCustomException('ProductShareClientHierarchy','execute',ex.getMessage(),ex.getLineNumber());    
        }      
        */   
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Finish method for post process logic
     */     
    public void finish(Database.BatchableContext bc){}
}