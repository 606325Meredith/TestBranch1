/**************************************************************************************
Apex Class Name:  ClientCustomerATMProcessTest
Version     : 1.0
Created Date    : 6 Jun 2016
Description    : Test class for the batch class ClientCustomerATMProcess
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Yashmith Kumar            6 Jun 2016              Original Version
*************************************************************************************/
@isTest
private class ClientCustomerATMProcessTest{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario for the batch class- Account Team in Client account
     */
    private static testMethod void ClientCustomerATMProcessClientInsertTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 31);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 31);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(30);
        insert listUser;

        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATM;

        System.assertEquals(30, listATM.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c in : listCC];
        System.assertEquals(930, listCCATM.size());
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario for the batch class- Account Team in Customer account
     */
    private static testMethod void ClientCustomerATMProcessCustInsertTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(101);
        insert listUser;

        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustAcc[0], listUser);
        insert listATM;

        System.assertEquals(101, listATM.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c in : listCC];
        System.assertEquals(101, listCCATM.size());
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm delete scenario for the batch class
     */
    private static testMethod void ClientCustomerATMProcessDeleteTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(101);
        insert listUser;

        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATM;

        List<Client_Customer_Account_Team__c> listCCATMNew = UtilityClassForTestDataSetUp.createCCATM(listCC[0], listATM, 'Client');

        Insert listCCATMNew;

        System.assertEquals(101,listCCATMNew.size());

        Delete listATM;

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c in : listCC];
        System.assertEquals(0, listCCATM.size());
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario, when same user is present in client and customer side
     */
    private static testMethod void ClientCustomerATMProcessDuplicateUserInsertTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 31);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 31);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(30);
        insert listUser;

        List<AccountTeamMember> listATMCust = UtilityClassForTestDataSetUp.createATMList(listCustAcc[0], listUser);
        insert listATMCust;

        List<AccountTeamMember> listATMClient = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATMClient;

        Client_Customer_Relationship__c rel = [Select id from Client_Customer_Relationship__c where Client__c =: listClientAcc[0].Id AND Customer__c =: listCustAcc[0].Id];
        System.assertEquals(true, rel.Id != null);

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: rel.Id];
        System.assertEquals(30, listCCATM.size());
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario, when same user is already present in the cc atm for a particular cc record.
     */
    private static testMethod void ClientCustomerATMProcessExistingDuplicateUserInsertTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 31);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 31);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(30);
        insert listUser;

        List<AccountTeamMember> listATMCust = UtilityClassForTestDataSetUp.createATMList(listCustAcc[0], listUser);
        insert listATMCust;

        List<Client_Customer_Account_Team__c> listCCATMNew = UtilityClassForTestDataSetUp.createCCATM(listCC[0], listATMCust, 'Customer');
        Insert listCCATMNew;

        List<AccountTeamMember> listATMClient = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATMClient;

        System.AssertEquals(30, listUser.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
        List<Client_Customer_Account_Team__c> listCCATM = [Select id from Client_Customer_Account_Team__c where Client_Customer_Relationship__c =: listCC[0].Id];
        System.assertEquals(30, listCCATM.size());
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario, when the common use is deleted from client account
     */
    private static testMethod void ClientCustomerATMProcessExistingDuplicateUserClientDeleteTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(50);
        insert listUser;

        List<AccountTeamMember> listATMCust = UtilityClassForTestDataSetUp.createATMList(listCustAcc[0], listUser);
        insert listATMCust;

        List<Client_Customer_Account_Team__c> listCCATMNew1 = UtilityClassForTestDataSetUp.createCCATM(listCC[0], listATMCust, 'Customer');
        Insert listCCATMNew1;

        List<AccountTeamMember> listATMClient = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATMClient;

        List<Client_Customer_Account_Team__c> listCCATMNew2 = UtilityClassForTestDataSetUp.createCCATM(listCC[0], listATMClient, 'Client');
        Insert listCCATMNew2;

        Delete listATMClient;

        System.assertEquals(50,listUser.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the atm insert scenario, when the common use is deleted from customer account
     */
    private static testMethod void ClientCustomerATMProcessExistingDuplicateUserCustDeleteTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 31);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 31);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;

        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(30);
        insert listUser;

        List<AccountTeamMember> listATMCust = UtilityClassForTestDataSetUp.createATMList(listCustAcc[0], listUser);
        insert listATMCust;

        Client_Customer_Relationship__c rel = [Select id from Client_Customer_Relationship__c where Client__c =: listClientAcc[0].Id AND Customer__c =: listCustAcc[0].Id];

        List<Client_Customer_Account_Team__c> listCCATMNew1 = UtilityClassForTestDataSetUp.createCCATM(rel, listATMCust, 'Customer');
        Insert listCCATMNew1;

        List<AccountTeamMember> listATMClient = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATMClient;

        List<Client_Customer_Account_Team__c> listCCATMNew2 = UtilityClassForTestDataSetUp.createCCATM(rel, listATMClient, 'Client');
        Insert listCCATMNew2;

        Delete listATMCust;

        System.assertEquals(30,listUser.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Test method to cover the exception scenario
     */
    private static testMethod void ClientCustomerATMProcessExceptionTest() {
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;

        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createClientCustList(listClientAcc[0], listCustAcc);
        insert listCC;
        for(Client_Customer_Relationship__c rel : listCC){
            rel.CLient__C = null;
        }
        update listCC;
        AcostaConstants.logCustomException('test', 'test', 'error', 0);
        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(50);
        insert listUser;

        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATM;

        System.assertEquals(50, listATM.size());

        Test.startTest();
        Database.executeBatch(new ClientCustomerATMProcess());
        Test.stopTest();
    }
}