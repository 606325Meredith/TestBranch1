@isTest
private class CustomObjectSharingBatchTest
{
	@isTest
	static void shareProductsToClientMasterTest()
	{
		List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);        
        insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client;
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        insert listCustAcc ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        insert listPro;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(4);
        insert listUser; 
          
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listL4Client[0], listCustAcc);
        insert listCC;       
       
        
        
        List<Client_Customer_Account_Team__c> listCCTCust = UtilityClassForTestDataSetUp.createClientCustTeamList(listCC[0], listUser,AcostaConstants.sourceCustomer );       
        insert listCCTCust ; 
        
        System.debug('listPro----'+listPro);
        System.debug('listL3Client----'+listL3Client);
        System.debug('listL4Client----'+listL4Client);
        System.debug('listUser----'+listUser);


        //List<Product__Share> listProductShareDel = UtilityClassForTestDataSetUp.createProductShareList(listPro,listUser);   
        //insert listProductShareDel;      
        
        listCCTCust[0].Client_Access__c = 'Read/Write';
        listCCTCust[0].Client_Customer_Access__c = 'Read/Write';
        update listCCTCust[0];
        
      
        Test.startTest(); 
        	Database.executeBatch(new CustomObjectSharingBatch(),100);
        Test.stopTest();   
        
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: listCC[0].Id];
        System.assertEquals(4, listCCATM.size());
	}


	@isTest
	static void testDeletedCCAT()
	{
		List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);        
        insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client;
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        insert listCustAcc ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        insert listPro;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(4);
        insert listUser; 
          
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listL4Client[0], listCustAcc);
        insert listCC;       
       
        
        
        List<Client_Customer_Account_Team__c> listCCTCust = UtilityClassForTestDataSetUp.createClientCustTeamList(listCC[0], listUser,AcostaConstants.sourceCustomer );       
        insert listCCTCust ; 
        
        System.debug('listPro----'+listPro);
        System.debug('listL3Client----'+listL3Client);
        System.debug('listL4Client----'+listL4Client);
        System.debug('listUser----'+listUser);
        

        listCCTCust[0].Client_Access__c = 'Read/Write';
        listCCTCust[0].Client_Customer_Access__c = 'Read/Write';
        update listCCTCust[0];
       
        delete listCCTCust[0];
        Test.startTest(); 
        	Database.executeBatch(new CustomObjectSharingBatch(),100);
        Test.stopTest();   
        
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: listCC[0].Id];
        System.assertEquals(3, listCCATM.size());
	}
}