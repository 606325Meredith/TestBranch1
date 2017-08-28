/*****************************************************************************************
Class Name: ClientCustomerProcessTCScenariosTest
Purpose: Test class for client customer process with specific business scenarions
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             13/04/2017           Mohit/Suman              Initial Development
1.1             17/04/2017           Rakesh Ramaswamy         Added TC-386, TC-387 and TC-399
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class ClientCustomerProcessTCScenariosTest
{
  /******************************************************
    Method Name: StoryNo314TC386
    Test Case ID: TC-00386
    Test Case Description: Removing (deleting) a user from Customer Account Team where they are on both Client and Customer Account Team.
    ******************************************************/
    static testMethod void StoryNo314TC386(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
    
    system.assertEquals(1, listAllCCRs.size());
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
    // Adding users as ATMs to the Client according to Test Script 380.
        for(integer j = 0; j < listClientAcc.size(); j++)
     {      
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
         }   
        
        // Creating Account Team Member for Customer Account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.addAll(listUser);
        
        for(integer j = 0; j < listCustAcc.size(); j++)
     {
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[j].AccountAccessLevel = 'Read';
            lstAllATMs.addall(listATM);
         }   
        
        //inserting all ATM
        insert lstAllATMs;
        
         //testing scenario starting
        test.startTest();
        
    //executing batch as batch profile user
        system.runAs(listUser[0])
         {
            ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
            Database.executeBatch(objCCAP, 200);         
         }     
        test.stopTest();
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client-Customer'];
       
        // verifying total number of CCAT
        system.AssertEquals(1, lstCCAT.size());        
        System.AssertEquals(AcostaConstants.readWriteAccess, lstCCAT[0].Client_Access__c);
        System.AssertEquals(AcostaConstants.readAccess, lstCCAT[0].CC_Access__c);
        System.AssertEquals(AcostaConstants.readWriteAccess, lstCCAT[0].Client_Customer_Access__c);        
    
    //updating Client access to Read from No Access
    // CCAT records associated to Customer Accounts.
        list<Client_Customer_Account_Team__c> lstcustAcctCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];    
    list<Client_Customer_Account_Team__c> ccatUpdtList = new list<Client_Customer_Account_Team__c>();
    
    for(Client_Customer_Account_Team__c ccatRecObj : lstcustAcctCCAT)
     {
        ccatRecObj.Client_Access__c = AcostaConstants.readAccess;
        ccatRecObj.CC_Access__c = AcostaConstants.readWriteAccess;
        ccatRecObj.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
        ccatUpdtList.add(ccatRecObj);
     }
    
    system.runAs(listUser[0])
     {
      update ccatUpdtList;
     }
    
    system.AssertEquals(AcostaConstants.readAccess, ccatUpdtList[0].Client_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].CC_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].Client_Customer_Access__c);  
    
    // Access ATM associated with Customer Account and provide Client Access and Client Customer Access.
    list<AccountTeamMember> custAcctATMList = [SELECT AccountId, AccountAccessLevel FROM AccountTeamMember WHERE AccountId = :listAcc[1].Id];
    // This list will return 2 records because Customer Account has two ATMs added.    
    system.assertEquals(2, custAcctATMList.size());
    
    delete custAcctATMList;        
        
    //executing batch as batch profile user
        system.runAs(listUser[0])
     {
      ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
      Database.executeBatch(objCCAP, 200);         
         }        
    
    // CCAT records associated to Customer Accounts.
        List<Client_Customer_Account_Team__c> lstcustAcctCCATtmp = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
    // when ATM are deleted from customer corresponding CCAT(s) also have to be deleted on the CCR.
    // This list returns only one because one of the CCAT As Source: 'Customer' is getting deleted due to ATM deletions.
    system.assertEquals(1, lstcustAcctCCATtmp.size());    
    }    
    
    /******************************************************
    Method Name: StoryNo314TC387
    Test Case ID: TC-00387
    Test Case Description: Removing (deleting) a user from Customer Account Team where they are on both Client and Customer Account Team.
    ******************************************************/
    static testMethod void StoryNo314TC387(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
    
        system.assertEquals(1, listAllCCRs.size());
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        // Adding users as ATMs to the Client according to Test Script 380.
        for(integer j = 0; j < listClientAcc.size(); j++)
        {      
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[j].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        // Creating Account Team Member for Customer Account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);        
        for(integer j = 0; j < listCustAcc.size(); j++)
        {
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[j].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            system.runAs(listUser[1])
            {
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP, 200);         
            }     
        test.stopTest();
       
        // updating client customer access to Read/Write from no access.
        // updating client access to Read/Write from no access. 
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
       
        // verifying total number of CCAT
        system.AssertEquals(1, lstCCAT.size());        
        System.AssertEquals(AcostaConstants.noAccess, lstCCAT[0].Client_Access__c);
        System.AssertEquals(AcostaConstants.readWriteAccess, lstCCAT[0].CC_Access__c);
        System.AssertEquals(AcostaConstants.noAccess, lstCCAT[0].Client_Customer_Access__c);        
    
        //updating Client access to Read from No Access
        //updating CCR access to Read/Write from No Access    
        list<Client_Customer_Account_Team__c> ccatUpdtList = new list<Client_Customer_Account_Team__c>();
        // Access ATM associated with Client Account and provide Client Access and Client Customer Access.
        for(Client_Customer_Account_Team__c ccatRecObj : lstCCAT)
         {
            ccatRecObj.Client_Access__c = AcostaConstants.readAccess;
            ccatRecObj.CC_Access__c = AcostaConstants.readWriteAccess;
            ccatRecObj.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
            ccatUpdtList.add(ccatRecObj);
         }
    
        system.runAs(listUser[0])
        {
            update ccatUpdtList;
        }
    
        system.AssertEquals(AcostaConstants.readAccess, ccatUpdtList[0].Client_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].CC_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].Client_Customer_Access__c);  
    
    
        list<AccountTeamMember> clntAcctATMList = [SELECT AccountId, AccountAccessLevel FROM AccountTeamMember WHERE AccountId = :listAcc[0].Id];
        // This list will return 2 records because Customer Account has two ATMs added.    
        system.assertEquals(1, clntAcctATMList.size());
        // Removing Client Account Team Member according to Script 386.
        delete clntAcctATMList;        
            
        //executing batch as batch profile user
        system.runAs(listUser[0])
        {
            ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
            Database.executeBatch(objCCAP, 200);         
        }        
        
        // CCAT records associated to Customer Accounts.
        List<Client_Customer_Account_Team__c> lstclntAcctCCATtmp = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client'];
        // when ATM are deleted from customer corresponding CCAT(s) also have to be deleted on the CCR.
        // This list returns only one because one of the CCAT As Source: 'Customer' is getting deleted due to ATM deletions.
        system.assertEquals(1, lstclntAcctCCATtmp.size());    
    }
    
    /******************************************************
    Method Name: StoryNo314TC399
    Test Case ID: TC-00399
    Test Case Description: When CCAT is edited w.r.t a user on one CCR to "No Access". Across multiple CCR records.
    ******************************************************/
    static testMethod void StoryNo314TC399(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 2);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
    
        system.assertEquals(2, listAllCCRs.size());
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        // Adding users as ATMs to the Client according to Test Script 380.
        for(integer j = 0; j < listClientAcc.size(); j++)
        {      
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[j].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        // Creating Account Team Member for Customer Account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);        
        for(integer j = 0; j < listCustAcc.size(); j++)
        {
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            system.runAs(listUser[1])
            {
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP, 200);         
            }     
        test.stopTest();
       
        // updating client customer access to Read/Write from no access.
        // updating client access to Read/Write from no access. 
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
       
        // verifying total number of CCAT
        system.AssertEquals(2, lstCCAT.size());        
        System.AssertEquals(AcostaConstants.noAccess, lstCCAT[0].Client_Access__c);
        System.AssertEquals(AcostaConstants.readWriteAccess, lstCCAT[0].CC_Access__c);
        System.AssertEquals(AcostaConstants.noAccess, lstCCAT[0].Client_Customer_Access__c);        
    
        //updating Client access to Read from No Access
        //updating CCR access to Read/Write from No Access    
        list<Client_Customer_Account_Team__c> ccatUpdtList = new list<Client_Customer_Account_Team__c>();
        // Access ATM associated with Client Account and provide Client Access and Client Customer Access.
        for(Client_Customer_Account_Team__c ccatRecObj : lstCCAT)
         {
            ccatRecObj.Client_Access__c = AcostaConstants.readAccess;
            ccatRecObj.CC_Access__c = AcostaConstants.readWriteAccess;
            ccatRecObj.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
            ccatUpdtList.add(ccatRecObj);
         }
    
        system.assertEquals(2,ccatUpdtList.size());
    
        system.runAs(listUser[0])
        {
            update ccatUpdtList;
        }
    
        system.AssertEquals(AcostaConstants.readAccess, ccatUpdtList[0].Client_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].CC_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[0].Client_Customer_Access__c); 
        system.AssertEquals(AcostaConstants.readAccess, ccatUpdtList[1].Client_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[1].CC_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[1].Client_Customer_Access__c);                              
        
        ccatUpdtList[1].Client_Access__c = AcostaConstants.noAccess;
        ccatUpdtList[1].Client_Customer_Access__c = AcostaConstants.noAccess;
        
        system.runAs(listUser[0])
        {
            update ccatUpdtList;
        }
        
        // CCAT records associated to Customer Accounts.
        List<Client_Customer_Account_Team__c> lstcustAcctCCATtmp = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
        // when ATM are deleted from customer corresponding CCAT(s) also have to be deleted on the CCR.
        // This list returns only one because one of the CCAT As Source: 'Customer' is getting deleted due to ATM deletions.
        system.assertEquals(2, lstcustAcctCCATtmp.size());          
        system.AssertEquals(AcostaConstants.noAccess, ccatUpdtList[1].Client_Access__c);
        system.AssertEquals(AcostaConstants.readWriteAccess, ccatUpdtList[1].CC_Access__c);
        system.AssertEquals(AcostaConstants.noAccess, ccatUpdtList[1].Client_Customer_Access__c);             
    }
    
    /******************************************************
    Method Name: StoryNo314TC393
    Test Case ID: TC-00393
    Test Case Description: Execute Batch Job
    ******************************************************/
    static testMethod void StoryNo314TC393(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 2);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(5);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], listUser);
            lstAllATMs.addall(listATM);
        }       
        insert lstAllATMs;
        
         ID jobID;
         
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                jobID = Database.executeBatch(objCCAP,200);         
            }
        test.stopTest();  
        
        AsyncApexJob jobStatus = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: jobID ];        
        System.AssertEquals('Completed',jobStatus.Status);
    }

    /******************************************************
    Method Name: StoryNo314TC380
    Test Case ID: TC-00380
    Test Case Description: Adding user to Client Account Team
    ******************************************************/
    static testMethod void StoryNo314TC380(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 2);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(5);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], listUser);
            lstAllATMs.addall(listATM);
        }       
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }
         test.stopTest();         
    
        //verifying the number of CCR inserted for client customer combination
        System.AssertEquals(10,listAllCCRs.size());
        System.AssertEquals(50,[Select count() from Client_Customer_Account_Team__c]);
        
        //querying total number of account share for a client account. Querying only specific row cause to filter out owner
        List<AccountShare> lstAccountShare = [Select ID, AccountID, AccountAccessLevel, UserorGroupID, RowCause from AccountShare where AccountID=:listClientAcc[0].ID and RowCause = 'Team'];

        //number fo account share for a client account and total of users should be same
        System.AssertEquals(listUser.size(),lstAccountShare.size()); 
    }
    
    /******************************************************
    Method Name: StoryNo314TC381
    Test Case ID: TC-00381
    Test Case Description: Adding user to Customer Account Team
    ******************************************************/
    static testMethod void StoryNo314TC381(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //creating account team member for customer account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);
        
        for(integer j = 0; j < listCustAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }
        test.stopTest(); 
        
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c];
        
        //verifying total number of CCAT
        System.AssertEquals(2,lstCCAT.size());
        
        //Checking all the access for CCAT
        for(Client_Customer_Account_Team__c ccat : lstCCAT){
            if(ccat.Source__c == 'Client'){
                System.AssertEquals('Read/Write',ccat.Client_access__c);
                System.AssertEquals('Read/Write',ccat.Client_Customer_Access__c );
                System.AssertEquals('Read',ccat.CC_Access__c);                
            }
            else if(ccat.Source__c == 'Customer'){
                System.AssertEquals('No Access',ccat.Client_access__c);
                System.AssertEquals('No Access',ccat.Client_Customer_Access__c );
                System.AssertEquals('Read',ccat.CC_Access__c);
            }
        }                         
    }
    
    /******************************************************
    Method Name: StoryNo314TC382
    Test Case ID: TC-00382
    Test Case Description:  Editing a user’s permission on a Client Customer Relationship Account Team
    ******************************************************/
    static testMethod void StoryNo314TC382(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //creating account team member for customer account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);
        
        for(integer j = 0; j < listCustAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
         //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }     
        test.stopTest();
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
        
        //verifying total number of CCAT
        System.AssertEquals(1,lstCCAT.size());
        
        //Updating CCR access
        lstCCAT[0].Client_Customer_Access__c = 'Read/Write';
        update lstCCAT; 
        
        //checking if user has access on CCR
        System.RunAs(listUser[1]){
            List<Client_Customer_Relationship__c> lstAllCCR = [Select ID from Client_Customer_Relationship__c];
            System.AssertEquals(1,lstAllCCR.size());
        }   
    }
    
    /******************************************************
    Method Name: StoryNo314TC384
    Test Case ID: TC-00384
    Test Case Description: Removing (deleting) a user from a Customer Account Team
    ******************************************************/
    static testMethod void StoryNo314TC384(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
                       
        //creating account team member for customer account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>(); 
        for(integer j = 0; j < listCustAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;        
        
        //executing batch handler as to create CCAT
        System.runAs(listUser[0]){
            ClientCustomerATMProcessHandler objCCAP = new ClientCustomerATMProcessHandler();
            objCCAP.CCATInsertUpdtDeleteHandler(listAllCCRs,Date.Today());         
        }             
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
        
        //verifying total number of CCAT
        System.AssertEquals(1,lstCCAT.size());     
        
        //deleting account team member 
        delete lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing the job again to delete CCAT 
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }  
        test.stopTest();        
        
        //checking if CCAT is delete
        List<Client_Customer_Account_Team__c> lstCCAT1 = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
        
        //verifying total number of CCAT
        System.AssertEquals(0,lstCCAT1.size());
    }
    
    /******************************************************
    Method Name: StoryNo314TC385
    Test Case ID: TC-00385
    Test Case Description: Removing (deleting) a user from a Client Account Team
    ******************************************************/
    static testMethod void StoryNo314TC385(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
                       
        //creating account team member for customer account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);
        
        //creating atm for customer account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;        
        
        //executing batch handler as to create CCAT
        System.runAs(listUser[0]){
            ClientCustomerATMProcessHandler objCCAP = new ClientCustomerATMProcessHandler();
            objCCAP.CCATInsertUpdtDeleteHandler(listAllCCRs,Date.Today());         
        }             
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client'];
        
        //verifying total number of CCAT
        System.AssertEquals(1,lstCCAT.size());     
        
        //deleting account team member 
        delete lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing the job again to delete CCAT 
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }  
        test.stopTest();        
        
        //checking if CCAT is delete
        List<Client_Customer_Account_Team__c> lstCCAT1 = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client'];
          
        //verifying total number of CCAT
        System.AssertEquals(0,lstCCAT1.size());
    }   
    
    /******************************************************
    Method Name: StoryNo314TC391
    Test Case ID: TC-00391
    Test Case Description: Adding a user to both Customer & Client account team within the same batch period
    ******************************************************/
    static testMethod void StoryNo314TC391(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[0]);
        
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //creating account team member for customer account
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[0]);
        
        for(integer j = 0; j < listCustAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            listATM[0].AccountAccessLevel = 'Edit';
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
         //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }     
        test.stopTest();
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client-Customer'];
       
        //verifying total number of CCAT
        System.AssertEquals(1,lstCCAT.size());
        
        System.AssertEquals('Read/Write',lstCCAT[0].Client_Access__c);
        System.AssertEquals('Read/Write',lstCCAT[0].CC_Access__c);
        System.AssertEquals('Read/Write',lstCCAT[0].Client_Customer_Access__c);
    }
    
    /******************************************************
    Method Name: StoryNo314TC392
    Test Case ID: TC-00392
    Test Case Description: Adding a user to both Customer & Client account team on different batch cycles
    ******************************************************/
    static testMethod void StoryNo314TC392(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
         //testing scenario starting
        test.startTest();
            //creating account team member for client account
            List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
            List<User> lstClientUser = new List<User>();
            lstClientUser.add(listUser[0]);
            
            for(integer j = 0; j < listClientAcc.size(); j++){
                List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
                listATM[0].AccountAccessLevel = 'Edit';
                lstAllATMs.addall(listATM);
            }          
        
            //inserting all ATM
            insert lstAllATMs;          
            
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }  
            
            //creating account team member for customer account
            List<AccountTeamMember> lstAllATM1s = new List<AccountTeamMember>();     
            List<User> lstCustomerUser = new List<User>();
            lstCustomerUser.add(listUser[0]);
            
            for(integer j = 0; j < listCustAcc.size(); j++){
                List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
                listATM[0].AccountAccessLevel = 'Edit';
                lstAllATM1s.addall(listATM);
            }   
        
            //insert customer atm
            insert lstAllATM1s;
            
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }  
        test.stopTest();
       
        //updating customer access to Read/Write from Read
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client-Customer'];
       
        //verifying total number of CCAT
        System.AssertEquals(1,lstCCAT.size());
        
        System.AssertEquals('Read/Write',lstCCAT[0].Client_Access__c);
        System.AssertEquals('Read/Write',lstCCAT[0].CC_Access__c);
        System.AssertEquals('Read/Write',lstCCAT[0].Client_Customer_Access__c);
    }
    
    /******************************************************
    Method Name: StoryNo314TC398_1
    Test Case ID: TC-00398
    Test Case Description: Change an Account Owner. This is for owner change on client account.
    ******************************************************/
    static testMethod void StoryNo314TC398_1(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
                
        //creating account team member for customer account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstCustomerUser = new List<User>();
        lstCustomerUser.add(listUser[1]);
        
        for(integer j = 0; j < listCustAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[j], lstCustomerUser);
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }
        test.stopTest(); 
        
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Customer'];
        
        //verifying total number of CCAT and access level
        System.AssertEquals(1,lstCCAT.size());
        System.AssertEquals('No Access',lstCCAT[0].Client_Access__c);
        
        //updating client access on CCAT to read
        lstCCAT[0].Client_Access__c = 'Read';
        update lstCCAT;
        
        //verifying if access is right
        System.AssertEquals('Read',lstCCAT[0].Client_Access__c);
        
        //checking account share before changing owner on client account
        List<AccountShare> lstAccShare = [Select ID,AccountAccessLevel,AccountID from AccountShare where RowCause='Manual' And AccountID =:listClientAcc[0].ID];
        System.AssertEquals(1,lstAccShare.size());
        System.AssertEquals('Read',lstAccShare[0].AccountAccessLevel);
        
        //changing owner on client account
        listClientAcc[0].OwnerID = listUser[0].ID;
        update listClientAcc;
        
        //checking account share for client account after owner is changed
        List<AccountShare> lstAccShare1 = [Select ID,AccountAccessLevel,AccountID from AccountShare where RowCause='Manual' And AccountID =:listClientAcc[0].ID];
        System.AssertEquals(lstAccShare.size(),lstAccShare1.size());
        System.AssertEquals(lstAccShare[0].AccountAccessLevel,lstAccShare1[0].AccountAccessLevel);
    }
    
    /******************************************************
    Method Name: StoryNo314TC398_2
    Test Case ID: TC-00398
    Test Case Description: Change an Account Owner. This is for owner change on customer account.
    ******************************************************/
    static testMethod void StoryNo314TC398_2(){
        //creating client account
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);    
        
        //customer account
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 1);
        
        //inserting account list
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        //inserting users
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(2);
        insert listUser;
        
        //creating CCR between client and customer
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        for(Integer i = 0;i < listClientAcc.size();i++)
        {
            list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
            listAllCCRs.addAll(listCC);
        }
        insert listAllCCRs;
        
                
        //creating account team member for client account
        List<AccountTeamMember> lstAllATMs = new List<AccountTeamMember>();     
        List<User> lstClientUser = new List<User>();
        lstClientUser.add(listUser[1]);
        
        for(integer j = 0; j < listClientAcc.size(); j++){
            List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[j], lstClientUser);
            lstAllATMs.addall(listATM);
        }   
        
        //inserting all ATM
        insert lstAllATMs;
        
        //testing scenario starting
        test.startTest();
            //executing batch as batch profile user
            System.runAs(listUser[0]){
                ClientCustomerATMProcess objCCAP = new ClientCustomerATMProcess();
                Database.executeBatch(objCCAP,200);         
            }
        test.stopTest(); 
        
        List<Client_Customer_Account_Team__c> lstCCAT = [Select ID,Client__c,Customer__c,Source__c,Client_Access__c,CC_Access__c,Client_Customer_Access__c from Client_Customer_Account_Team__c where Source__c = 'Client'];
        
        System.Debug('check list values ## '+lstCCAT);
        
        //verifying total number of CCAT and access level
        System.AssertEquals(1,lstCCAT.size());
        System.AssertEquals('Read',lstCCAT[0].CC_Access__c);
        
        //updating customer access on CCAT to read
        lstCCAT[0].CC_Access__c = 'Read/Write';
        update lstCCAT;
        
        //verifying if access is right
        System.AssertEquals('Read/Write',lstCCAT[0].CC_Access__c);
        
        //checking account share before changing owner on customer account
        List<AccountShare> lstAccShare = [Select ID,AccountAccessLevel,AccountID from AccountShare where RowCause='Manual' And AccountID =:listCustAcc[0].ID];
        System.AssertEquals(1,lstAccShare.size());
        System.AssertEquals('Edit',lstAccShare[0].AccountAccessLevel);
        
        //changing owner on customer account
        listCustAcc[0].OwnerID = listUser[0].ID;
        update listCustAcc;
        
        //checking account share for customer account after owner is changed
        List<AccountShare> lstAccShare1 = [Select ID,AccountAccessLevel,AccountID from AccountShare where RowCause='Manual' And AccountID =:listCustAcc[0].ID];
        System.AssertEquals(lstAccShare.size(),lstAccShare1.size());
        System.AssertEquals(lstAccShare[0].AccountAccessLevel,lstAccShare1[0].AccountAccessLevel);
    }
}