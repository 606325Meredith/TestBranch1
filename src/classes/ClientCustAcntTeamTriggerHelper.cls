/**
     * @Author : RAKESH RAMASWAMY
     * @Company : PRICEWATERHOUSECOOPERS LLP
     * @Created Date : 3rd April, 2017.
     * @LastModified Date: 21st April, 2017.
     * @Desc : Apex Helper/Handler Class to provide sharing to Client Accounts , Customer Accounts and Client Customer Relationships and also the Products linked to Client Accounts.
 */  
public class ClientCustAcntTeamTriggerHelper
{   
    list<Client_Customer_Account_Team__c> oldRecords, newRecords;
    map<Id,Client_Customer_Account_Team__c> oldRecordsMap, newRecordsMap;
    public static final String CONNECTOR = '-';
    String accKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
    String ccrKeyPrefix = Client_Customer_Relationship__c.sObjectType.getDescribe().getKeyPrefix();
    
    // Constructor Begins here..    
    public ClientCustAcntTeamTriggerHelper(list<Client_Customer_Account_Team__c> newRecords, list<Client_Customer_Account_Team__c> oldRecords, map<Id,Client_Customer_Account_Team__c> newRecordsMap, map<Id,Client_Customer_Account_Team__c> oldRecordsMap)
     {             
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
        this.oldRecordsMap = oldRecordsMap;        
     } 
    // End of the Constructor..
    
    map<Id,Id> ccatmIdToClientIdMap = new map<Id,Id>();
    map<Id,Id> ccatmIdToCustomerIdMap = new map<Id,Id>();
    map<Id,Client_Customer_Account_Team__c> ccatIdToCCATMap = new map<Id,Client_Customer_Account_Team__c>();
    map<Id,Id> ccatIdToCCRIdMap = new map<Id,Id>();   
    set<Id> usersWithCCAccessChanged = new set<Id>();
    list<AccountShare> accSharesToInsert = new list<AccountShare>();
    list<AccountShare> accSharesToUpdate = new list<AccountShare>();
    list<AccountShare> accSharesToDelete = new list<AccountShare>();
    list<Client_Customer_Relationship__Share> ccrSharesToInsert = new list<Client_Customer_Relationship__Share>(); 
    list<Client_Customer_Relationship__Share> ccrSharesToUpdate = new list<Client_Customer_Relationship__Share>(); 
    list<Client_Customer_Relationship__Share> ccrSharesToDelete = new list<Client_Customer_Relationship__Share>(); 

    public void processAfterInsert()
    {
        for(Client_Customer_Account_Team__c ccatm: newRecords)
        {
           if(ccatm.Source__c == AcostaConstants.sourceClient)
            {
                AccountShare accShare = createAccountShare(ccatm.User__c,ccatm.Customer__c,ccatm.CC_Access__c);
                accSharesToInsert.add(accShare);
            }
            else if(ccatm.Source__c == AcostaConstants.sourceCustomer )
            {
                AccountShare accShare = createAccountShare(ccatm.User__c,ccatm.Client__c,ccatm.Client_Access__c);
                accSharesToInsert.add(accShare);
            } 

            //Create ccr share for every CCATM
            Client_Customer_Relationship__Share ccrShare = createCCRShare(ccatm.User__c,ccatm.Client_Customer_Relationship__c,ccatm.Client_Customer_Access__c);
                ccrSharesToInsert.add(ccrShare);
        }//end for on newRecords
        
        try
        {
            if(!accSharesToInsert.isEmpty())
            {
                Database.insert(accSharesToInsert,false);
            }

            if(!ccrSharesToInsert.isEmpty())
            {
                Database.insert(ccrSharesToInsert,false);
            }
            
          //turning off product sharing
          //shareProductsToChannelsBU(newRecords, null);
           
        }catch(Exception ex)
        {
            AcostaConstants.logCustomException('ClientCustAcntTeamTriggerHelper','processAfterInsert',ex.getMessage(),ex.getLineNumber()); 
        }
        
    }//end processAfterInsert()
    
    public void processAfterUpdate()
    {
        Set<Id> userIdsToUpdateAccShares = new Set<Id>();
        Set<Id> accountIdsToUpdateShares = new Set<Id>();
        Set<Id> userIdsToDeleteAccShares = new Set<Id>();
        Set<Id> accountIdsToDeleteShares = new Set<Id>();

        Set<Id> userIdsToUpdateCCRShares = new Set<Id>();
        Set<Id> userIdsToDeleteCCRShares = new Set<Id>();
        Set<Id> ccrIdsToUpdateShares = new Set<Id>();
        Set<Id> ccrIdsToDeleteShares = new Set<Id>();
        Map<String,String> compoundKeyToNewAccessMap = new Map<String,String>();

        for(Client_Customer_Account_Team__c ccatm: newRecords)
        {           
           if((ccatm.Source__c == AcostaConstants.sourceClient) && ((ccatm.CC_Access__c != oldRecordsMap.get(ccatm.Id).CC_Access__c)))           
            {
                if(AcostaConstants.mapAccessLevelShare.containsKey(ccatm.CC_Access__c))
                {
                   userIdsToUpdateAccShares.add(ccatm.User__c);
                   accountIdsToUpdateShares.add(ccatm.Customer__c);
                   compoundKeyToNewAccessMap.put(String.valueOf(ccatm.User__c)+CONNECTOR+String.valueOf(ccatm.Customer__c),ccatm.CC_Access__c);
                }else
                {
                   userIdsToDeleteAccShares.add(ccatm.User__c);  
                   accountIdsToDeleteShares.add(ccatm.Customer__c);  
                }
            }           
           else if((ccatm.Source__c == AcostaConstants.sourceCustomer) && (ccatm.Client_Access__c != oldRecordsMap.get(ccatm.Id).Client_Access__c))           
            {
                if(AcostaConstants.mapAccessLevelShare.containsKey(ccatm.Client_Access__c))
                {
                   userIdsToUpdateAccShares.add(ccatm.User__c);
                   accountIdsToUpdateShares.add(ccatm.Client__c);
                   compoundKeyToNewAccessMap.put(String.valueOf(ccatm.User__c)+CONNECTOR+String.valueOf(ccatm.Client__c),ccatm.Client_Access__c);
                }else
                {
                   userIdsToDeleteAccShares.add(ccatm.User__c);  
                   accountIdsToDeleteShares.add(ccatm.Client__c);  
                }
            }            
            
            //Modify the CCR Shares for all types of updates
            if(AcostaConstants.mapAccessLevelShare.containsKey(ccatm.Client_Customer_Access__c))
            {               
               userIdsToUpdateCCRShares.add(ccatm.User__c);
               ccrIdsToUpdateShares.add(ccatm.Client_Customer_Relationship__c);
               compoundKeyToNewAccessMap.put(String.valueOf(ccatm.User__c)+CONNECTOR+String.valueOf(ccatm.Client_Customer_Relationship__c),ccatm.Client_Customer_Access__c);
            }else
            {              
                userIdsToDeleteCCRShares.add(ccatm.User__c);  
                ccrIdsToDeleteShares.add(ccatm.Client_Customer_Relationship__c);               
            }            
        }//end for on newRecords                
    
       upsertAccountShares(userIdsToUpdateAccShares, accountIdsToUpdateShares, compoundKeyToNewAccessMap);
       deleteAccountShares(userIdsToDeleteAccShares, accountIdsToDeleteShares, true);           
       deleteCCRShares(userIdsToDeleteCCRShares, ccrIdsToDeleteShares);    
       upsertCCRShares(userIdsToUpdateCCRShares, ccrIdsToUpdateShares, compoundKeyToNewAccessMap);              
       //shareProductsToChannelsBU(newRecords, oldRecordsMap);
    }//end processAfterUpdate()
    
    public void processAfterDelete()
    {        
        set<Id> userIdsToDeleteShares = new set<Id>();
        set<Id> accountIdsToDeleteShares = new set<Id>();
        set<Id> ccrIdsToDeleteShares = new set<Id>();               
        
        for(Client_Customer_Account_Team__c ccatm: oldRecords)
        {           
            userIdsToDeleteShares.add(ccatm.User__c);                        
            accountIdsToDeleteShares.add(ccatm.Customer__c);       
            accountIdsToDeleteShares.add(ccatm.Client__c);                    
            ccrIdsToDeleteShares.add(ccatm.Client_Customer_Relationship__c); 
        }//end for on oldRecords                              
               
        deleteAccountShares(userIdsToDeleteShares, accountIdsToDeleteShares, false);
        deleteCCRShares(userIdsToDeleteShares, ccrIdsToDeleteShares);
        //shareProductsToChannelsBU(null, oldRecordsMap);
    }//end processAfterDelete()
      
    public void upsertAccountShares(Set<Id> userIds, Set<Id> accountIds, map<String,String> compoundKeyToNewAccessMap)
    {
        list<AccountShare> accountSharesToUpsert = new list<AccountShare>();
        set<String> compositeKeysThatAreUpdated = new set<String>();//to keep track of update vs insert               
                        
           //Update account shares
           if(!userIds.isEmpty() 
                && !accountIds.isEmpty())
           {
                for(AccountShare accShare: [SELECT AccountAccessLevel,AccountId,UserOrGroupId 
                                            FROM AccountShare 
                                            WHERE (AccountId IN : accountIds 
                                                    AND UserOrGroupId IN : userIds)])
                {
                    if(compoundKeyToNewAccessMap.containsKey(String.valueOf(accShare.UserOrGroupId)+CONNECTOR+String.valueOf(accShare.AccountId)))
                    {
                       String shareLevel = compoundKeyToNewAccessMap.get(String.valueOf(accShare.UserOrGroupId)+CONNECTOR+String.valueOf(accShare.AccountId));
                        accShare.AccountAccessLevel = AcostaConstants.mapAccessLevelShare.get(shareLevel);
                        accountSharesToUpsert.add(accShare);    
                        compositeKeysThatAreUpdated.add(String.valueOf(accShare.UserOrGroupId)+CONNECTOR+String.valueOf(accShare.AccountId));
                    }
                }
           }//end empty check
           
           //Check if any of the shares do not exist already. Create new shares for these.
           if(!compoundKeyToNewAccessMap.isEmpty())
           {
                for(String key: compoundKeyToNewAccessMap.keySet())
                {
                    if(!compositeKeysThatAreUpdated.contains(key))
                    {
                        List<String> parts = key.split(CONNECTOR);
                        String userId = parts.get(0);
                        String accountId = parts.get(1);
                        if(!accountId.startsWith(accKeyPrefix))//Don't add if the ID is not for an Account
                        {
                          continue;
                        }
                        AccountShare accShare = createAccountShare(userId, accountId, compoundKeyToNewAccessMap.get(key));
                        accountSharesToUpsert.add(accShare);
                    }
                }
            }//end empty check on map
           
           try
           {
                if(!accountSharesToUpsert.isEmpty())
                {
                    Database.upsert(accountSharesToUpsert,false);    
                }
           }catch(Exception ex)
           {
                AcostaConstants.logCustomException('ClientCustAcntTeamTriggerHelper','upsertAccountShares',ex.getMessage(),ex.getLineNumber()); 
           }
    }//end upsertAccountShares()        

    public void deleteAccountShares(Set<Id> userIds, Set<Id> accountIds, boolean isCCATUpdt)
    {              
       // This set collection is used to capture all the Client Account Record Id(s) from the formula field on CCAT object to Client(Lookup to Account).
       // The Client__c formula field on CCAT object returns 15-digit alphanumeric Id. 
       set<String> setCCATRelatedClientId = new set<String>();
       // This set collection is used to capture all the Customer Account Record Id(s) from the formula field on CCAT object to Customer(Lookup to Account).
       // The Customer__c formula field on CCAT object returns 15-digit alphanumeric Id. 
       set<String> setCCATRelatedCustId = new set<String>(); 
       // This set collection captures all the user ids tagged to the respective CCAT records in the system and being processed.
       set<Id> setUserRecAcctAssnWithCCATId = new set<Id>();
       // This set collection captures all the record id(s) of the CCAT that is going to be deleted from the system.
       set<Id> setDeletedCCATIds = new set<Id>();
       // This map collection determines how many CCR(s) exist for a user and common client account across multiple CCR(s).
       map<String, set<Id>> usrIdClientIdCCRMap = new map<String, set<Id>>();
       // This map collection determines how many CCR(s) exist for a user and common customer account across multiple CCR(s).
       map<String, set<Id>> usrIdCustIdCCRMap = new map<String, set<Id>>();
       // A list collection to capture AccountShare records to be deleted.       
       list<AccountShare> accountSharesToDelete = new list<AccountShare>();
       // A list collection to capture AccountShare records to be inserted.
       list<AccountShare> accountSharesToReInsrt = new list<AccountShare>();
                      
       system.debug('239 ### userIds Set ==> '+userIds);   
       system.debug('240 ### accountIds Set ==> '+accountIds);                                
       //Delete account shares
       if(!userIds.isEmpty() && !accountIds.isEmpty())
       {            
            for(AccountShare acctShare : [SELECT AccountAccessLevel, AccountId, RowCause, UserOrGroupId FROM AccountShare WHERE ((AccountId IN : accountIds) AND (UserOrGroupId IN : userIds))])
             {
                accountSharesToDelete.add(acctShare);
             }             
       }//end empty check       
       
       system.debug('250 ### accountSharesToDelete ==> '+accountSharesToDelete);
       
       // isCCATUpdt is a boolean flag variable, that is used to determine whether the deletion of Account Shares has to result on update of CCAT records or during deletion of CCAT records.
       // the boolean flag is true whenever CCAT records existing in the system are updated.
       // the boolean flag is false whenever CCAT records in the system are deleted.
       if(isCCATUpdt)
        {           
           for(Client_Customer_Account_Team__c CCATTempObj : newRecords)
             {
                set<Id> setCCRClientTempIds = new set<Id>();
                set<Id> setCCRCustomerTempIds = new set<Id>();
                         
                // Capturing all the related CCR record Id(s) for determining release or inclusion of Apex Sharing Reason on Client and Customer from CCR.                          
                if((CCATTempObj.Client_Access__c != null) && CCATTempObj.Client_Access__c.equals(AcostaConstants.noAccess))            
                  {                     
                    setCCATRelatedClientId.add(String.valueOf(CCATTempObj.Client__c));
                    setUserRecAcctAssnWithCCATId.add(CCATTempObj.User__c);
                  }
                
                if((CCATTempObj.CC_Access__c != null) && CCATTempObj.CC_Access__c.equals(AcostaConstants.noAccess))
                  {                      
                     setCCATRelatedCustId.add(String.valueOf(CCATTempObj.Customer__c));
                     setUserRecAcctAssnWithCCATId.add(CCATTempObj.User__c);
                  }                       
                  
                 if(!usrIdClientIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c)))
                   {
                      setCCRClientTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdClientIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c), setCCRClientTempIds);
                   }
                  else if(usrIdClientIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c)))
                   {
                      setCCRClientTempIds = usrIdClientIdCCRMap.get(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c));
                      setCCRClientTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdClientIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c), setCCRClientTempIds);
                   }                     
                                 
                  if(!usrIdCustIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c)))
                   {
                      setCCRCustomerTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdCustIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c), setCCRCustomerTempIds);
                   }
                  else if(usrIdCustIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c)))
                   {
                      setCCRCustomerTempIds = usrIdCustIdCCRMap.get(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c));
                      setCCRCustomerTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdCustIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c), setCCRCustomerTempIds);
                   }    
             }                          
        }
        // The following else logic will come into existence whenever CCAT records are deleted.
        else
        {       
                
            for(Client_Customer_Account_Team__c CCATTempObj : oldRecords)
             {              
                set<Id> setCCRClientTempIds = new set<Id>();
                set<Id> setCCRCustomerTempIds = new set<Id>();                                
                
                setDeletedCCATIds.add(CCATTempObj.Id);
                                
                 if(CCATTempObj.Client_Access__c != null)                            
                  {                     
                    setCCATRelatedClientId.add(String.valueOf(CCATTempObj.Client__c));
                    setUserRecAcctAssnWithCCATId.add(CCATTempObj.User__c);
                  }                                  
                
                 if(CCATTempObj.CC_Access__c != null)                
                  {                      
                     setCCATRelatedCustId.add(String.valueOf(CCATTempObj.Customer__c));
                     setUserRecAcctAssnWithCCATId.add(CCATTempObj.User__c);
                  }    
                 
                 // Capturing all the related CCR record Id(s) for determining release or inclusion of Apex Sharing Reason on Client and Customer from CCR. 
                 if(!usrIdClientIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c)))
                   {
                      setCCRClientTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdClientIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c), setCCRClientTempIds);
                   }
                  else if(usrIdClientIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c)))
                   {
                      setCCRClientTempIds = usrIdClientIdCCRMap.get(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c));
                      setCCRClientTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdClientIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Client__c), setCCRClientTempIds);
                   }                     
                                 
                  if(!usrIdCustIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c)))
                   {
                      setCCRCustomerTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdCustIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c), setCCRCustomerTempIds);
                   }
                  else if(usrIdCustIdCCRMap.containsKey(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c)))
                   {
                      setCCRCustomerTempIds = usrIdCustIdCCRMap.get(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c));
                      setCCRCustomerTempIds.add(CCATTempObj.Client_Customer_Relationship__c);
                      usrIdCustIdCCRMap.put(String.valueOf(CCATTempObj.User__c)+String.valueOf(CCATTempObj.Customer__c), setCCRCustomerTempIds);
                   }                        
             }
        }                  
           
           // The following logic is to decipher whether for a client and user how many CCAT(s) exist in the system across multiple CCR(s).
           // Also to determine the other way round how many CCAT(s) exist in the system for a given user and Customer Account in the system.  
           if(((setCCATRelatedCustId != null) || (setCCATRelatedClientId != null)) && (setUserRecAcctAssnWithCCATId != null))
             {                
                
                // The following logic fires whenever CCAT records are purged from the system.
                if(!isCCATUpdt)
                 {
                    for(Client_Customer_Account_Team__c objclientCustAcntTeam : [SELECT Id, isCCATSourceChanged__c, User__c, Client__c, Customer__c, CC_Access__c, IsDeleted, Client_Access__c, Client_Customer_Relationship__c, Source__c FROM Client_Customer_Account_Team__c WHERE (Client__c IN: setCCATRelatedClientId OR Customer__c IN: setCCATRelatedCustId) AND (User__c IN: setUserRecAcctAssnWithCCATId) AND (Id NOT IN: setDeletedCCATIds)])
                     { 
                        set<Id> setCCRClientTempIds = new set<Id>();
                        set<Id> setCCRCustomerTempIds = new set<Id>();                                                                                               
                          
                        if(usrIdClientIdCCRMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c)))
                          {
                              setCCRClientTempIds = usrIdClientIdCCRMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c));
                              setCCRClientTempIds.add(objclientCustAcntTeam.Client_Customer_Relationship__c);
                              usrIdClientIdCCRMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), setCCRClientTempIds);
                          }                     
                                         
                        if(usrIdCustIdCCRMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c)))
                          {
                              setCCRCustomerTempIds = usrIdCustIdCCRMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c));
                              setCCRCustomerTempIds.add(objclientCustAcntTeam.Client_Customer_Relationship__c);
                              usrIdCustIdCCRMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), setCCRCustomerTempIds);
                          }
                        
                        list<Client_Customer_Account_Team__c> CCATTemp1List;
                        list<Client_Customer_Account_Team__c> CCATTemp2List;                
                        
                        if(!AcostaConstants.dupCCATsFromCustClientMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c)))
                         {
                            CCATTemp1List = new list<Client_Customer_Account_Team__c>();
                            CCATTemp1List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), CCATTemp1List);
                         }
                        else
                         {
                            CCATTemp1List = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c).substring(0,15));
                            CCATTemp1List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), CCATTemp1List);
                         }
                         
                        if(!AcostaConstants.dupCCATsFromCustClientMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c)))
                         {
                            CCATTemp2List = new list<Client_Customer_Account_Team__c>();
                            CCATTemp2List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), CCATTemp2List);
                         }
                       else
                         {
                            CCATTemp2List = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c).substring(0,15));
                            CCATTemp2List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), CCATTemp2List);
                         }                  
                      }
                 }
                 // The following logic fires whenever CCAT records are updated in the system.
                 // This logic is again to determine how many CCAT records exist for a given user and common client/common customer in the HQ Sales System at any given point of time.
                else
                 {
                     for(Client_Customer_Account_Team__c objclientCustAcntTeam : [SELECT Id, User__c, Client__c, Customer__c, CC_Access__c, IsDeleted, Client_Access__c, isCCATSourceChanged__c, Client_Customer_Relationship__c, Source__c FROM Client_Customer_Account_Team__c WHERE (Client__c IN: setCCATRelatedClientId OR Customer__c IN: setCCATRelatedCustId) AND (User__c IN: setUserRecAcctAssnWithCCATId)])
                      {
                         set<Id> setCCRClientTempIds = new set<Id>();
                         set<Id> setCCRCustomerTempIds = new set<Id>();                                                                                                 
                          
                        if(usrIdClientIdCCRMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c)))
                          {
                              setCCRClientTempIds = usrIdClientIdCCRMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c));
                              setCCRClientTempIds.add(objclientCustAcntTeam.Client_Customer_Relationship__c);
                              usrIdClientIdCCRMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), setCCRClientTempIds);
                          }                     
                                         
                        if(usrIdCustIdCCRMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c)))
                          {
                              setCCRCustomerTempIds = usrIdCustIdCCRMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c));
                              setCCRCustomerTempIds.add(objclientCustAcntTeam.Client_Customer_Relationship__c);
                              usrIdCustIdCCRMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), setCCRCustomerTempIds);
                          }
                        
                        list<Client_Customer_Account_Team__c> CCATTemp1List;
                        list<Client_Customer_Account_Team__c> CCATTemp2List;                
                        
                        if(!AcostaConstants.dupCCATsFromCustClientMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c)))
                         {
                            CCATTemp1List = new list<Client_Customer_Account_Team__c>();
                            CCATTemp1List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), CCATTemp1List);
                         }
                        else
                         {
                            CCATTemp1List = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c).substring(0,15));
                            CCATTemp1List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Client__c), CCATTemp1List);
                         }  
                         
                        if(!AcostaConstants.dupCCATsFromCustClientMap.containsKey(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c)))
                         {
                            CCATTemp2List = new list<Client_Customer_Account_Team__c>();
                            CCATTemp2List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), CCATTemp2List);
                         }
                        else
                         {
                            CCATTemp2List = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c).substring(0,15));
                            CCATTemp2List.add(objclientCustAcntTeam);
                            AcostaConstants.dupCCATsFromCustClientMap.put(String.valueOf(objclientCustAcntTeam.User__c)+String.valueOf(objclientCustAcntTeam.Customer__c), CCATTemp2List);
                         } 
                      }
                 }
             }                      
       
         for(AccountShare share : accountSharesToDelete)    
           {
                // String apex variable to capture the access value to be set on the Client Account based on the accesses determined across CCAT records existing for the user and client account in the system.
                String clientAccessVal = '';
                // String apex variable to capture the access value to be set on the Customer Account based on the accesses determined across CCAT records existing for the user and customer account in the system.
                String customerAccessVal = '';                                
                
                // Here is the logic to determine whether CCAT(s) exist for a user and Client Account in the system.
                // if there are more than 1 CCAT(s) existing in the system, then we need to determine what is the least restrictive or most restrictive access that can be given to Client Account
                // This depends on the no. of CCAT records opening up or closing access to Client Accounts in the system.
                if(usrIdClientIdCCRMap.containsKey(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15)) && (usrIdClientIdCCRMap.get(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15)).size() > 1))                                                                                                                          
                  {                             
                          list<Client_Customer_Account_Team__c> CCATtmpList = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15));                                                                        
                          
                          if((CCATtmpList != null) && !CCATtmpList.isEmpty())
                           {
                             // logic that is fired when CCAT record is updated w.r.t Client Access.
                             // this is a scenario wherein multiple CCAT(s) exist in the system for a common client across CCR(s) and a given user.                              
                             if(isCCATUpdt)
                              {
                                  for(Client_Customer_Account_Team__c CCATRecObj : CCATtmpList)
                                   {                                                                                    
                                        if(CCATRecObj.isCCATSourceChanged__c)
                                         {
                                            clientAccessVal = CCATRecObj.Client_Access__c;
                                            break;
                                         }                                                                      
                                         
                                        if(((clientAccessVal == null) || (clientAccessVal == '')) && (CCATRecObj.Client_Access__c != null) && !CCATRecObj.Client_Access__c.equals(AcostaConstants.noAccess)) 
                                         {
                                            clientAccessVal = CCATRecObj.Client_Access__c;                                      
                                         }                 
                                        else                   
                                         {
                                            
                                            
                                            if(clientAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readAccess))
                                             {
                                                clientAccessVal = CCATRecObj.Client_Access__c;                                          
                                             }
                                             
                                            if(clientAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readWriteAccess))
                                             {
                                                clientAccessVal = CCATRecObj.Client_Access__c;
                                                break;
                                             }                                                                      
                                            
                                            if(clientAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readWriteAccess))
                                             {
                                                clientAccessVal = CCATRecObj.Client_Access__c;
                                                break;
                                             }                                                                                                                                                              
                                         }
                                   }
                                  
                                  // As long as higher level of access is what needs to prevail for a Client Account
                                  // This logical check will ascertain whether a Client Account has to get higher level of access accordingly.
                                  if((clientAccessVal != null) && !clientAccessVal.equals(AcostaConstants.noAccess))                                                                    
                                    {                                                                                                                                                                                                                                                                                       
                                      AccountShare acctShrObj = createAccountShare(share.UserOrGroupId, share.AccountId, clientAccessVal);                                  
                                      accountSharesToReInsrt.add(acctShrObj);
                                    }                                                                                            
                              }
                              // logic that fires when existing CCAT is deleted from the system.
                              // this is a scenario wherein multiple CCAT(s) exist in the system for a common client across CCR(s) and a given user.
                              else
                               {
                                  if((CCATtmpList != null) && !CCATtmpList.isEmpty())
                                   {
                                      for(Client_Customer_Account_Team__c CCATRecObj : CCATtmpList)
                                       {                                                                                                                                                                 
                                            if(((clientAccessVal == null) || (clientAccessVal == '')) && (CCATRecObj.Client_Access__c != null) && !CCATRecObj.Client_Access__c.equals(AcostaConstants.noAccess)) 
                                             {
                                                clientAccessVal = CCATRecObj.Client_Access__c;                                      
                                             }                 
                                            else                   
                                             {
                                                if(clientAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;
                                                 }
                                                 
                                                if(clientAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readWriteAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;
                                                    break;
                                                 }
                                                
                                                if(clientAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.noAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;                                                  
                                                 } 
                                                
                                                if(clientAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readWriteAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;
                                                    break;
                                                 }      
                                                 
                                                if(clientAccessVal.equals(AcostaConstants.readWriteAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.noAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;
                                                 } 
                                                 
                                                if(clientAccessVal.equals(AcostaConstants.readWriteAccess) && (CCATRecObj.Client_Access__c != null) && CCATRecObj.Client_Access__c.equals(AcostaConstants.readAccess))
                                                 {
                                                    clientAccessVal = CCATRecObj.Client_Access__c;
                                                 }                                                                          
                                             }
                                       }
                                      
                                      // As long as higher level of access is what needs to prevail for a Client Account
                                      // This logical check will ascertain whether a Client Account has to get higher level of access accordingly.
                                      if((clientAccessVal != null) && !clientAccessVal.equals(AcostaConstants.noAccess))                                                                    
                                        {                                                                                                                                                                                                                                                                                       
                                          AccountShare acctShrObj = createAccountShare(share.UserOrGroupId, share.AccountId, clientAccessVal);                                  
                                          accountSharesToReInsrt.add(acctShrObj);
                                        }                                                                                            
                                    } 
                               }            
                          }  
                  }                                                                                           
                // Here is the logic to determine whether CCAT(s) exist for a user and Customer Account in the system.
                // if there are more than 1 CCAT(s) existing in the system, then we need to determine what is the least restrictive or most restrictive access that can be given to Customer Account
                // This depends on the no. of CCAT records opening up or closing access to Customer Accounts in the system. 
                 if(usrIdCustIdCCRMap.containsKey(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15)) && (usrIdCustIdCCRMap.get(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15)).size() > 1))                                                                                
                    {                                                                                                                                       
                         list<Client_Customer_Account_Team__c> CCATtmpList = AcostaConstants.dupCCATsFromCustClientMap.get(String.valueOf(share.UserOrGroupId)+String.valueOf(share.AccountId).substring(0,15));                         
                         
                         // logic that is fired when CCAT record is updated w.r.t Customer Access.
                         // this is a scenario wherein multiple CCAT(s) exist in the system for a common customer across CCR(s) and a given user.
                         if(isCCATUpdt)
                          {
                             for(Client_Customer_Account_Team__c CCATRecObj : CCATtmpList)
                                   {                                                                            
                                        if(CCATRecObj.isCCATSourceChanged__c)
                                         {
                                            customerAccessVal = CCATRecObj.CC_Access__c;
                                            break;
                                         }                                                                      
                                         
                                        if(((customerAccessVal == null) || (customerAccessVal == '')) && (CCATRecObj.CC_Access__c != null) && !CCATRecObj.CC_Access__c.equals(AcostaConstants.noAccess)) 
                                         {
                                            customerAccessVal = CCATRecObj.CC_Access__c;                                        
                                         }                 
                                        else                   
                                         {
                                                                                    
                                            if(customerAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readAccess))
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;                                            
                                             }
                                             
                                            if(customerAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readWriteAccess))
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;
                                                break;
                                             }
                                            
                                            if(customerAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.noAccess))
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;
                                             } 
                                            
                                            if(customerAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readWriteAccess))
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;
                                                break;
                                             }                                                                                      
                                             
                                            if(customerAccessVal.equals(AcostaConstants.readWriteAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readAccess))
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;                                             
                                             }                                                                      
                                         }
                                   }
                                  // As long as higher level of access is what needs to prevail for a Customer Account
                                  // This logical check will ascertain whether a Customer Account has to get higher level of access accordingly.
                                  if((customerAccessVal != null) && !customerAccessVal.equals(AcostaConstants.noAccess))                                                                    
                                    {                                                                                                                                                                                                                                                                                       
                                      AccountShare acctShrObj = createAccountShare(share.UserOrGroupId, share.AccountId, customerAccessVal);                                  
                                      accountSharesToReInsrt.add(acctShrObj);
                                    }
                          }
                        // logic that fires when existing CCAT is deleted from the system.
                        // this is a scenario wherein multiple CCAT(s) exist in the system for a common customer across CCR(s) and a given user.
                         else
                          { 
                             if((CCATtmpList != null) && !CCATtmpList.isEmpty())
                                {     
                                      for(Client_Customer_Account_Team__c CCATRecObj : CCATtmpList)
                                       {                                                                                                                                                                                                                   
                                            if(((customerAccessVal == null) || (customerAccessVal == '')) && (CCATRecObj.CC_Access__c != null) && !CCATRecObj.CC_Access__c.equals(AcostaConstants.noAccess)) 
                                             {
                                                customerAccessVal = CCATRecObj.CC_Access__c;                                        
                                             }                 
                                            else                   
                                             {                                                                                                  
                                                if(customerAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                 }
                                                 
                                                if(customerAccessVal.equals(AcostaConstants.noAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readWriteAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                    break;
                                                 }
                                                
                                                if(customerAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readWriteAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                    break;
                                                 }                                                                                                    
                                                 
                                                if(customerAccessVal.equals(AcostaConstants.readAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.noAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                 } 
                                                 
                                                if(customerAccessVal.equals(AcostaConstants.readWriteAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.readAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                 }   
                                                
                                                if(customerAccessVal.equals(AcostaConstants.readWriteAccess) && (CCATRecObj.CC_Access__c != null) && CCATRecObj.CC_Access__c.equals(AcostaConstants.noAccess))
                                                 {
                                                    customerAccessVal = CCATRecObj.CC_Access__c;
                                                 }                          
                                             }                                                                         
                                       }
                                      
                                      // As long as higher level of access is what needs to prevail for a Customer Account
                                      // This logical check will ascertain whether a Customer Account has to get higher level of access accordingly.
                                      if((customerAccessVal != null) && !customerAccessVal.equals(AcostaConstants.noAccess))                                                                             
                                        {                                                                                                                                                   
                                             AccountShare acctShrObj = createAccountShare(share.UserOrGroupId, share.AccountId, customerAccessVal);                                         
                                             accountSharesToReInsrt.add(acctShrObj);
                                        }                                                                  
                                }         
                          }                                  
                     }                                                                                                                                                         
            }             
       try
       {
            if(!accountSharesToDelete.isEmpty())
             {                
                system.debug('737 ### accountSharesToDelete ==> '+accountSharesToDelete);
                database.delete(accountSharesToDelete, false);               
             }    
            
            if(!accountSharesToReInsrt.isEmpty())
             {                  
                database.insert(accountSharesToReInsrt, false); 
             }
       }catch(Exception ex)
       {
            AcostaConstants.logCustomException('ClientCustAcntTeamTriggerHelper','deleteAccountShares',ex.getMessage(),ex.getLineNumber()); 
       }
    }//end deleteAccountShares()

    public void upsertCCRShares(Set<Id> userIds, Set<Id> ccrIds, Map<String,String> compoundKeyToNewAccessMap)
    {
        List<Client_Customer_Relationship__Share> ccrSharesToUpsert = new List<Client_Customer_Relationship__Share>();
        Set<String> compositeKeysThatAreUpdated = new Set<String>();//to keep track of update vs insert

       //Update CCR Shares
       if(!userIds.isEmpty() && !ccrIds.isEmpty())
       {
            for(Client_Customer_Relationship__Share ccrShare: [SELECT AccessLevel ,ParentId ,UserOrGroupId FROM Client_Customer_Relationship__Share WHERE (ParentId IN : ccrIds AND UserOrGroupId IN : userIds)])
            {
                
                if(compoundKeyToNewAccessMap.containsKey(String.valueOf(ccrShare.UserOrGroupId)+CONNECTOR+String.valueOf(ccrShare.ParentId)))
                 {                  
                    String shareLevel = compoundKeyToNewAccessMap.get(String.valueOf(ccrShare.UserOrGroupId)+CONNECTOR+String.valueOf(ccrShare.ParentId));
                    ccrShare.AccessLevel = AcostaConstants.mapAccessLevelShare.get(shareLevel);                    
                    ccrSharesToUpsert.add(ccrShare);
                    compositeKeysThatAreUpdated.add(String.valueOf(ccrShare.UserOrGroupId)+CONNECTOR+String.valueOf(ccrShare.ParentId));
                 }
            }
       }//end empty check
       //Check if any of the shares do not exist already. Create new shares for these.
       if(!compoundKeyToNewAccessMap.isEmpty())
       {
            for(String key: compoundKeyToNewAccessMap.keySet())
            {
                if(!compositeKeysThatAreUpdated.contains(key))
                {
                    List<String> parts = key.split(CONNECTOR);
                    String userId = parts.get(0);
                    String ccrId = parts.get(1);
                    if(!ccrId.startsWith(ccrKeyPrefix))//Don't add if the ID is not for a CCR
                    {
                      continue;
                    }
                    Client_Customer_Relationship__Share ccrShare = createCCRShare(userId, ccrId, compoundKeyToNewAccessMap.get(key));
                    ccrSharesToUpsert.add(ccrShare);
                }
            }
        }//end empty check on map            
       
       try
       {
            if(!ccrSharesToUpsert.isEmpty())
            {
                Database.upsert(ccrSharesToUpsert,false);
            }
        }catch(Exception ex)
        {
            AcostaConstants.logCustomException('ClientCustAcntTeamTriggerHelper','upsertCCRShares',ex.getMessage(),ex.getLineNumber()); 
        }
    }//end upsertCCRShares()

    public void deleteCCRShares(Set<Id> userIds, Set<Id> ccrIds)
    {
        List<Client_Customer_Relationship__Share> ccrSharesToDelete = new List<Client_Customer_Relationship__Share>();
        if(!userIds.isEmpty()
            && !ccrIds.isEmpty())
        {
            ccrSharesToDelete = [SELECT AccessLevel ,ParentId ,UserOrGroupId 
                                                                FROM Client_Customer_Relationship__Share 
                                                                WHERE (ParentId IN : ccrIds 
                                                                        AND UserOrGroupId IN : userIds)];
        }//end empty check
       
        try
        {
            if(!ccrSharesToDelete.isEmpty())
            {
               Database.delete(ccrSharesToDelete,false);
            }
        }catch(Exception ex)
        {
            AcostaConstants.logCustomException('ClientCustAcntTeamTriggerHelper','deleteCCRShares',ex.getMessage(),ex.getLineNumber());  
        }
    }//end deleteCCRShares()        

    public Client_Customer_Relationship__Share createCCRShare(String userId, String ccrId, String ccAccess)
    {
        Client_Customer_Relationship__Share ccrShare =  new Client_Customer_Relationship__Share();
        ccrShare.UserOrGroupId = userId;
        ccrShare.ParentId = ccrId;
        ccrShare.AccessLevel = AcostaConstants.mapAccessLevelShare.get(ccAccess);
        return ccrShare;
    }//end createCCRShare()

    public AccountShare createAccountShare(String userId, String accountId, String accessLevel)
    {
        AccountShare accShare=new AccountShare();
        accShare.UserOrGroupId = userId;
        accShare.AccountId = accountId;
        accShare.AccountAccessLevel = AcostaConstants.mapAccessLevelShare.get(accessLevel);
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        
        return accShare;
    }//end createAccountShare()        
    
   
}