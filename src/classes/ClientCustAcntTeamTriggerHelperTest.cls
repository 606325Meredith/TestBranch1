/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*
* ClientCustAcntTeamTriggerHelperTest
* @description      : Test class for ClientCustAcntTeamTriggerHelper Class
* @author           : Rahul
* @createddate      : May 30, 2016
* @lastmodified     : May 30, 2016
* @last modified by :   
*/
@isTest
private class ClientCustAcntTeamTriggerHelperTest 
 {
    static testMethod void shareProductsToClientMasterTest() 
     {   
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);    
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        list<Client_Customer_Relationship__c> listAllCCRs = new list<Client_Customer_Relationship__c>();
        
        for(Integer i = 0;i < 2;i++)
         {
          list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[i], listCustAcc);
           listAllCCRs.addAll(listCC);
         }
         
         insert listAllCCRs;
        
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(5);
        insert listUser;
        
        Test.startTest(); 
        list<Client_Customer_Account_Team__c> listAllCCTClient = new list<Client_Customer_Account_Team__c>();
        list<Client_Customer_Account_Team__c> listAllCCTTmp1Client = new list<Client_Customer_Account_Team__c>();
        list<Client_Customer_Account_Team__c> listAllCCTTmp2Client = new list<Client_Customer_Account_Team__c>();
        
       // system.RunAs(listUser[0])
         // {
          for(Integer j = 0; j < listAllCCRs.size();j++)
           {
            list<Client_Customer_Account_Team__c> listCCTClient = UtilityClassForTestDataSetUp.createClientCustTeamList(listAllCCRs[j], listUser, AcostaConstants.sourceClient);          
            listAllCCTClient.addAll(listCCTClient);
           }
  
      // if(listAllCCTClient.size() > 10000)
      // {
          for(Client_Customer_Account_Team__c CCATtempObj : listAllCCTClient)
           {
             if(listAllCCTTmp1Client.size() < 100)
              {
                listAllCCTTmp1Client.add(CCATtempObj);
              }
             else
             {
               listAllCCTTmp2Client.add(CCATtempObj);
             }
           }  
      // }                                         
          
         system.debug('81 $$$ listAllCCTTmp1Client.size() ==> '+listAllCCTTmp1Client.size());
         system.RunAs(listUser[1])
          {              
              insert listAllCCTTmp1Client;
          }
         
         system.RunAs(listUser[2])
          { 
            insert listAllCCTTmp2Client;
          }
          
          List<Client_Customer_Relationship__Share> listClientCustRelShare = UtilityClassForTestDataSetUp.createClientCustShareList(listAllCCRs, listUser);   
          insert listClientCustRelShare; 
                  
          List<AccountShare> listClientShare = UtilityClassForTestDataSetUp.createaccountShareList(listClientAcc, listUser);   
          insert listClientShare; 
          
          List<AccountShare> listCustShare = UtilityClassForTestDataSetUp.createaccountShareList(listCustAcc, listUser);   
          insert listCustShare; 
                        
          listAllCCTTmp1Client[0].CC_Access__c = 'No Access';
          listAllCCTTmp1Client[0].Client_Customer_Access__c = 'No Access';
          update listAllCCTTmp1Client[0];
                         
          listAllCCTTmp2Client[1].CC_Access__c = 'Read/Write';
          listAllCCTTmp2Client[1].Client_Customer_Access__c = 'Read/Write';
          update listAllCCTTmp2Client[1]; 
                         
          listAllCCTTmp1Client[2].CC_Access__c = 'Read';
          listAllCCTTmp1Client[2].Client_Customer_Access__c = 'Read';
          update listAllCCTTmp1Client[2];
  
      list<Client_Customer_Account_Team__c> listAllCCTCust = new list<Client_Customer_Account_Team__c>();
                               
          for(Integer i = 0;i < listAllCCRs.size();i++)
           {
             list<Client_Customer_Account_Team__c> listCCTCust = UtilityClassForTestDataSetUp.createClientCustTeamList(listAllCCRs[i], listUser, AcostaConstants.sourceCustomer);  
             listAllCCTCust.addAll(listCCTCust);
           }
                           
          insert listAllCCTCust;
            
          listAllCCTCust[0].Client_Access__c = 'No Access';
          listAllCCTCust[0].Client_Customer_Access__c = 'No Access';
          update listAllCCTCust[0];
          
          listAllCCTCust[1].Client_Access__c = 'Read/Write';
          listAllCCTCust[1].Client_Customer_Access__c = 'Read/Write';
          update listAllCCTCust[1];
          
          listAllCCTCust[2].Client_Access__c = 'Read';
          listAllCCTCust[2].Client_Customer_Access__c = 'Read';
          update listAllCCTCust[2];
          
          delete listAllCCTClient[0];
          delete listAllCCTCust[0];
          
          Test.stopTest();   
          
          set<ID> allCCRIdSet = new set<ID>();
          
          for(Client_Customer_Relationship__c CCRObj : listAllCCRs)
           {
             allCCRIdSet.add(CCRObj.Id);
           }
          
          list<Client_Customer_Account_Team__c> listCCATM  = new list<Client_Customer_Account_Team__c>();
           
          for(Client_Customer_Account_Team__c CCATTmpObj : [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: allCCRIdSet])
           {
             listCCATM.add(CCATTmpObj);
           }
           system.assertEquals(1018, listCCATM.size());  
     //  }              
    }
    
     private static testMethod void productSharingInsertTest()
      {        
        list<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);        
        insert listL3Client;
        
        list<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client)
         {
            acc.ParentId = listL3Client[0].Id;
         }
         
        insert listL4Client;
        
        list<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        insert listCustAcc ;
        
        list<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        insert listPro;
        
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(4);
        insert listUser; 
          
        list<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listCustAcc);
        insert listCC;       
               
        Test.startTest(); 
        list<Client_Customer_Account_Team__c> listCCTCust = UtilityClassForTestDataSetUp.createClientCustTeamList(listCC[0], listUser,AcostaConstants.sourceCustomer);       
        insert listCCTCust ; 
        
        //List<Product__Share> listProductShareDel = UtilityClassForTestDataSetUp.createProductShareList(listPro,listUser);   
        //insert listProductShareDel;      
        
        listCCTCust[0].Client_Access__c = 'No Access';
        listCCTCust[0].Client_Customer_Access__c = 'No Access';
        update listCCTCust[0];
        
        listCCTCust[0].Client_Access__c = 'Read/Write';
        listCCTCust[0].Client_Customer_Access__c = 'Read/Write';
        update listCCTCust[0];
        
        listCCTCust[0].Client_Access__c = 'Read';
        listCCTCust[0].Client_Customer_Access__c = 'Read';
        update listCCTCust[0];
        
        listCCTCust[0].Client_Access__c = 'No Access';
        listCCTCust[0].Client_Customer_Access__c = 'No Access';
        update listCCTCust[0];
        
        listCCTCust[0].Client_Access__c = 'Read';
        listCCTCust[0].Client_Customer_Access__c = 'Read';
        update listCCTCust[0];
                        
        delete listCCTCust[0];
        Test.stopTest(); 
        //string strProductShrDelJSON = Json.Serialize(listProductShareDel );
        
        list<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: listCC[0].Id];
        System.assertEquals(3, listCCATM.size());              
    }
}