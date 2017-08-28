/**************************************************************************************
Apex Class Name:    LocalInitiativeReltdListContrlr
Version     : 1.0 
Created Date    : 16 Sep 2016
Description    : Test class for the class   LocalInitiativeReltdListContrlr
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anil Nedunuri            16 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class  LocalInitvRelatedListControllerTest{

//---------------------------------------------------------------------------------------------------------------------

  /**
     * @Description : test method to test the National Initiative List
     */ 
         
    private static testMethod void LocalInitiativeListTest() {
    
    
                    //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 1);        
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4ClientType, 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
    
                //create the customer records.
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 1);        
        Insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L5CustomerType, 5);
        for(Account acc : listL5Customer){
            acc.ParentId = listL4Customer[0].Id;
        }
        insert listL5Customer;
        
                //create the CC records.
        List<Client_Customer_Relationship__c> listCCRec = UtilityClassForTestDataSetUp.createListClientCust(listL4Client,listL5Customer);
        for(Client_Customer_Relationship__c lsCC : listCCRec){
                lsCC.Client__c = listL4Client[0].Id;
                lsCC.Customer__c = listL5Customer[0].Id;
        }
        insert listCCRec;
        
                        // create the National Strategy records        
         List<National_Strategy__c> listNSList = UtilityClassForTestDataSetUp.createNSList(listL5Customer);
         for(National_Strategy__c nsList : listNSList){
                 nsList.Name = 'Test NS-Natioanl Strategy';
                 nsList.Client__c = listL5Customer[0].Id;
         }
         insert listNSList;
         
          map<Id,Id> mapClientIdNSIs = new Map<Id,Id>();        
          for(National_Strategy__c ns : listNSList){
                 mapClientIdNSIs.put(ns.Client__c,ns.Id);
          }

                // create the Local Strategy records        
         List<Local_Strategy__c> listLSList = UtilityClassForTestDataSetUp.createLSList(listCCRec,mapClientIdNSIs);
         for(Local_Strategy__c lsList : listLSList){
                 lsList.Name = 'Test Local Strategy';
                 lsList.Client_Customer_Relationship__c = listCCRec[0].Id;
                 lsList.National_Strategy__c = listNSList[0].Id;
                 
         }
         insert listLSList; 
         
         
                 // create the Local Initiative records    
      List<Local_Initiative__c> listLIList = UtilityClassForTestDataSetUp.createLIList(listLSList);
         for(Local_Initiative__c liList : listLIList){
                 liList.Local_Strategy__c= listLSList[0].Id;
         }
         insert listLIList;
         
          
        LocalInitiativeReltdListContrlr lcStgReltdList = new LocalInitiativeReltdListContrlr(new ApexPages.StandardController(new Local_Strategy__c()));
        Test.setCurrentPage(Page.LocalStrategyRelatedList); 
        System.currentPageReference().getParameters().put('currentID','listLSList.Id');
        Test.startTest();    
        lcStgReltdList.initiativeList();
        lcStgReltdList.allocate();
        lcStgReltdList.viewDetails();
        lcStgReltdList.newInitiative();
        lcStgReltdList.deleteInitiatives();
        lcStgReltdList.getCheckpermissions();
        System.assertEquals(25,listLIList.size());
        Test.stopTest();
       
    }

}