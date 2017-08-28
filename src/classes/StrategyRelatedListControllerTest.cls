/**************************************************************************************
Apex Class Name:    StrategyRelatedListController
Version     : 1.0 
Created Date    : 10 Sep 2016
Description    : Test class for the class   StrategyRelatedListController
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anil Nedunuri            10 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class  StrategyRelatedListControllerTest{

//---------------------------------------------------------------------------------------------------------------------

  /**
     * @Description : test method to test the National Initiative List
     */ 
         
    private static testMethod void NationalInitiativeListTest() {
    
                //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);        
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;

                // create the National Strategy records        
         List<National_Strategy__c> listNSList = UtilityClassForTestDataSetUp.createNSList(listL4Client);
         for(National_Strategy__c nsList : listNSList){
                 nsList.Name = 'Test NS-Natioanl Strategy';
                 nsList.Client__c = listL4Client[0].Id;
         }
         insert listNSList;

                 // create the National Initiative records    
         List<National_Initiative__c > listNIList = UtilityClassForTestDataSetUp.createNIList(listNSList);
         for(National_Initiative__c niList : listNIList){
                 niList.Strategy__c = listNSList[0].Id;
         }
         insert listNIList;
        
        
        
        StrategyRelatedListController stgReltdList = new StrategyRelatedListController(new ApexPages.StandardController(new National_Strategy__c()));
        Test.setCurrentPage(Page.StrategyRelatedListPage); 
        System.currentPageReference().getParameters().put('currentID','listNSList[0].Id');
        Test.startTest();    
        stgReltdList.initiativeList();
        stgReltdList.allocate();
        stgReltdList.viewDetails();
        stgReltdList.newInitiative();
        stgReltdList.deleteInitiatives();
        stgReltdList.getCheckpermissions();
        System.assertEquals(5,listNIList.size());
        Test.stopTest();
       
    }

}