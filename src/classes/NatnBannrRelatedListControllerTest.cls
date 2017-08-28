/**************************************************************************************
Apex Class Name:    NationalBannerRelatedListController
Version     : 1.0
Created Date    : 16 Sep 2016
Description    : Test class for the class   NationalBannerRelatedListController
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Anil Nedunuri            16 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class  NatnBannrRelatedListControllerTest{

//---------------------------------------------------------------------------------------------------------------------

  /**
     * @Description : test method to test the National Banner List
     */

    private static testMethod void NationalBannerListTest() {


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

                      // create the National Initiative records
      List<National_Initiative__c > listNIList = UtilityClassForTestDataSetUp.createNIList(listNSList);
         for(National_Initiative__c niList : listNIList){
                 niList.Strategy__c = listNSList[0].Id;
         }
         insert listNIList;

                 // create National Banner records
            List<National_Banner_Allocation__c> listNBList = UtilityClassForTestDataSetUp.createNBAList(listNIList);
         for(National_Banner_Allocation__c nbList : listNBList){
                 nbList.National_Initiative_Lookup__c = listNIList[0].Id;
                 nbList.Client_Customer_Relationship__c = listCCRec[0].Id;

         }
         insert listNBList;

         // create National Sub-Banner records
            List<National_Sub_Banner_Allocation__c> listNSBList = UtilityClassForTestDataSetUp.createNSBAList(listNBList);
         for(National_Sub_Banner_Allocation__c nsbList : listNSBList){
                 nsbList.National_Banner_Allocation__c = listNBList[0].Id;
                 nsbList.Client_Customer_Relationship__c = listCCRec[0].Id;

         }
         insert listNSBList;
         System.Debug('NationalSubBannerInsert' + listNSBList);

                   // create Local Banner records
            List<Local_Banner_Allocation__c> listLBList = UtilityClassForTestDataSetUp.createLBAList(listLIList);
         for(Local_Banner_Allocation__c lbList : listLBList){
                 lbList.Local_Initiative__c = listLIList[0].Id;
                 lbList.Client_Customer_Relationship__c = listCCRec[0].Id;
                 lbList.Status__c ='Allocated';

         }
         insert listLBList;
         System.Debug('LocalBannerInsert' + listLBList);


        NationalBannerRelatedListController natnBannerReltdList = new NationalBannerRelatedListController(new ApexPages.StandardController(new National_Banner_Allocation__c()));
        PageReference pageRef = Page.LocalBannerAllocationRelatedList;
        pageRef.getParameters().put('currentID', listCCRec[0].Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        natnBannerReltdList.nationalBannerList();
        natnBannerReltdList.deleteNationalBannerAllocation();
        natnBannerReltdList.getCheckpermissions();
        System.assertEquals(5,listNBList.size());
        Test.stopTest();

    }

}