/**************************************************************************************
Apex Class Name:  ProductShareClientHierarchyTest
Version     : 1.0 
Created Date    : 8 Jul 2016
Description    : Test class for the batch class ProductShareClientHierarchy
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar            8 Jul 2016              Original Version
*************************************************************************************/
@isTest
private class ProductShareClientHierarchyTest{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario  for the batch class 
     */ 
    private static testMethod void ProductShareClientHierarchyTestInsert() {
        List<Account> listL1Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Master - L1', 1);
        Insert listL1Client;
        List<Account> listL2Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Country - L2', 1);
        listL2Client[0].ParentId = listL1Client[0].Id;
        Insert listL2Client;
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        listL3Client[0].ParentId = listL2Client[0].Id;
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 4);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        Insert listL4Client;
        
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(4);
        insert listUser; 
        List<AccountTeamMember> listATM = new List<AccountTeamMember>();
        
        List<AccountTeamMember> listATML1 = UtilityClassForTestDataSetUp.createATMList(listL1Client[0], listUser);
        listATM.addAll(listATML1); 
        
        List<AccountTeamMember> listATML2 = UtilityClassForTestDataSetUp.createATMList(listL2Client[0], listUser);
        listATM.addAll(listATML2);
        
        List<AccountTeamMember> listATML3 = UtilityClassForTestDataSetUp.createATMList(listL3Client[0], listUser);
        listATM.addAll(listATML3);
        
        List<AccountTeamMember> listATML4 = UtilityClassForTestDataSetUp.createATMList(listL4Client[0], listUser);
        listATM.addAll(listATML4);      
        
        Insert listATM;                  
        
        System.assertEquals(200, listPro.size());
        
        Test.startTest();
        Database.executeBatch(new ProductShareClientHierarchy());
        Test.stopTest();  
        //List<Product__Share> listPShare = [Select Id, ParentID, UserOrGroupId from Product__Share where ParentID in : listPro AND Rowcause != 'Owner'];
        //System.assertEquals(800, listPShare.size());    
    }
    
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm delete scenario  for the batch class
     */ 
    private static testMethod void ProductShareClientHierarchyTestDelete() {
        List<Account> listL1Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Master - L1', 1);
        Insert listL1Client;
        List<Account> listL2Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Country - L2', 1);
        listL2Client[0].ParentId = listL1Client[0].Id;
        Insert listL2Client;
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        listL3Client[0].ParentId = listL2Client[0].Id;
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 4);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        Insert listL4Client;
        
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(4);
        insert listUser; 
        
        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listL1Client[0], listUser);
        insert listATM; 
        
        System.assertEquals(200, listPro.size());
        //List<Product__Share> listPShareExisting = UtilityClassForTestDataSetUp.createProductShareList(listPro, listATM);
        //for(Product__Share pShare : listPShareExisting){
            //pShare.RowCause = Schema.Product__Share.RowCause.AccountTeam__c;
        //}
        //Insert listPShareExisting;
        delete listATM;
        
        Test.startTest();
        Database.executeBatch(new ProductShareClientHierarchy());
        Test.stopTest();  
        //List<Product__Share> listPShare = [Select Id, ParentID, UserOrGroupId from Product__Share where ParentID in : listPro and Rowcause != 'Owner'];
        //System.assertEquals(0, listPShare.size());    
    }    
}