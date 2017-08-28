/*****************************************************************************************
Class Name: ClientCustomerRelationshipTriggerTest
Purpose: Test class for CCR object trigger
******************************************************************************************
Version         DateModified         ModifiedBy                          Change
1.0             19/04/2017           Rakesh Ramaswamy(PwC)               Initial Development
1.1             20/04/2017           Rakesh Ramaswamy(PwC)               Line #95 to include clone check on CCR Instantiation.
1.2             21/04/2017           Rakesh Ramaswamy(PwC)               Inclusion of comments for better test class code readability.
******************************************************************************************/
@isTest
private class ClientCustomerRelationshipTriggerTest
{
    static testMethod void changeCCROwnership()
     {               
        //creating user list comprising of 5 user records in no.
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(5);
        insert listUser;
     
        //creating client account records (5) in no. for the CCR
        list<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 5);   
        insert listClientAcc;
        
        // creating customer account records (5) in no. for the CCR
        list<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listCustAcc;
        
        // List collection to insert ATM(s) for each of the Customer specific Accounts created as test data.
        list<AccountTeamMember> acctAllTMList = new list<AccountTeamMember>();
        
        for(Account acctObj : listCustAcc)
          {
            list<AccountTeamMember> acctTMList = UtilityClassForTestDataSetUp.createATMList(acctObj, listUser);
            acctAllTMList.addAll(acctTMList);
          }
          
        insert acctAllTMList;
        
        // There will be totally (25) CCR records in the system for (5) Client Accounts and (5) Customer Accounts in the system.
        list<Client_Customer_Relationship__c> listAllCCRRecs = new list<Client_Customer_Relationship__c>();
              
        // creating CCR records in for different client account and customer account combinations.
        for(Account clientAcct : listClientAcc)
         {           
            list<Client_Customer_Relationship__c> lstCCRRecs = UtilityClassForTestDataSetUp.createClientCustList(clientAcct, listCustAcc);
            listAllCCRRecs.addAll(lstCCRRecs);
         }
         
        insert listAllCCRRecs;        
        
        set<Id> CCRInsertedRecIds = new set<Id>();
        
          for(Client_Customer_Relationship__c CCRRecObj : listAllCCRRecs)
           {
               CCRInsertedRecIds.add(CCRRecObj.Id);
           }
        
       // Querying back all the CCR records that were inserted as test data.
       // Reason for this is because CreatedbyId and OwnerId fields are null soon after CCR test data insertion.
       // In order to be able to invoke CCR trigger logic around retaining share records for CCR, the CCR records will have to be queried back again.
       list<Client_Customer_Relationship__c> CCRTempList = [SELECT Id, OwnerId, Status__c, CreatedById, Customer__c, Client__c FROM Client_Customer_Relationship__c WHERE Id IN: CCRInsertedRecIds];        
        // Assert check to determine whether 25 CCR records have been inserted successfully as test data for (5 x 5) Client vs. Customer combinations.        
        system.assertEquals(25, listAllCCRRecs.size());                                
        
        // Adding the users list to the customer account team.
        list<AccountTeamMember> listAllCustAcctATMs = new list<AccountTeamMember>();
        
        for(Account custAcctObj : listCustAcc)
         {
            list<AccountTeamMember> listCustAcctATMs = UtilityClassForTestDataSetUp.createATMList(custAcctObj, listUser);
            listAllCustAcctATMs.addAll(listCustAcctATMs);
         }
         
        // inserting the Customer Account ATM(s)
        insert listAllCustAcctATMs;
        
        // A Set collection to capture all the CCR record Id(s).
        set<Id> CCRIdSet = new set<Id>();
        
        for(Client_Customer_Relationship__c ccrRecObj : CCRTempList)
         {
            system.debug('55 ### ccrRecObj ==> '+ccrRecObj);
            CCRIdSet.add(ccrRecObj.Id);
         }                              
          
         // A list collection to capture CCR records prior to change to help prepare the oldMap with the prior to change values on CCR         
         list<Client_Customer_Relationship__c> CCRTemp2List = new list<Client_Customer_Relationship__c>();
         
         for(Client_Customer_Relationship__c CCRObj : CCRTempList)
          {
              CCRTemp2List.add(CCRObj);
          }
         // A Map collection to capture the old values of CCR records that have been updated w.r.t ownership.
         // Key of the map is the record Id of the CCR(s).
         // Value pair is the respective CCR record that had ownership updates done.
         map<Id, Client_Customer_Relationship__c> oldCCRValMap = new map<Id, Client_Customer_Relationship__c>();
         
         for(Client_Customer_Relationship__c CCRTempObj : CCRTemp2List)
          {
              if(!oldCCRValMap.containsKey(CCRTempObj.Id))
               {
                   Client_Customer_Relationship__c CCRTempObj2 = CCRTempObj.clone();
                   oldCCRValMap.put(CCRTempObj.Id, CCRTempObj2);
               }
          }                  
      
        // Running Client Customer ATM Process batch job.
        // Batch job that runs in Batch Job profile user context to create CCAT records for each of the users in the user list.
        // Source of the CCAT(s) will be 'Customer' only.
        Test.startTest();        
        system.RunAs(listUser[1])
         {
            ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
            database.executeBatch(objCCAP, 200); 
         }         
        Test.stopTest();        
        
        // List collection to capture CCAT records that have been created by the batch job to be updated in terms of opening up the access to CCR from CCAT records.
        list<Client_Customer_Account_Team__c> CCATTempUpdtList = new list<Client_Customer_Account_Team__c>();
        // Updating Client Customer Access and Client Access for CCAT(s) with  Source: Customer.
        for(Client_Customer_Account_Team__c CCATTempRecObj : [SELECT Id, Name, CC_Access__c, Client_Access__c, Client_Customer_Access__c, Client_Customer_Relationship__c FROM Client_Customer_Account_Team__c WHERE Client_Customer_Relationship__c IN: CCRIdSet])
         {
            CCATTempRecObj.Client_Customer_Access__c = AcostaConstants.readAccess;
            CCATTempRecObj.Client_Access__c = AcostaConstants.readWriteAccess;
            CCATTempUpdtList.add(CCATTempRecObj);
         }
        // update DML issued on CCAT list.        
        update CCATTempUpdtList;
        
        //updating owner       
        list<Client_Customer_Relationship__c> CCROwnerUpdtList = new list<Client_Customer_Relationship__c>();
        list<User> usrUptRecObj = [SELECT Id, FirstName, LastName FROM User WHERE isActive = true LIMIT 5];
        
        for(Client_Customer_Relationship__c CCRObj : CCRTempList)
         {                                                 
            CCRObj.OwnerId = usrUptRecObj.get(3).Id;           
            CCROwnerUpdtList.add(CCRObj);
         }                         
         
         // Handler method instantiation..
         ClientCustomerRelationshipTriggerHandler CCRTrigHandler = new ClientCustomerRelationshipTriggerHandler();
         // Respective handler methods invoked in unit testin context for methods written in before update and after update contexts on CCR table/object in HQ Sales system. 
         CCRTrigHandler.executeOnBeforeUpdate(CCROwnerUpdtList, oldCCRValMap);
         CCRTrigHandler.executeOnAfterUpdate();
        
        // Assert check to determine whether 125 share records get created for 5 users for each of the 25 CCR(s) getting created as test data.              
        system.AssertEquals((listUser.size()*25),AcostaConstants.lstCCRShareToInsert.size());
     }
}