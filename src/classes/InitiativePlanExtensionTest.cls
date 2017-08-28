/**************************************************************************************
Apex Class Name:  InitiativePlanExtensionTest
Version     : 1.0
Created Date    : 2 Sep 2016
Description    : Test class for the class InitiativePlanExtension
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Yashmith Kumar            2 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class InitiativePlanExtensionTest{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Client Selector
     */
    private static testMethod void IPClientSelectorTest() {
        //create the client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 50);
        insert listClientAcc;
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        update listClientAcc;

        // setup the page parameters and select the clients and add them
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('curSelector', 'ClientSelector');
        Test.startTest();
        con.showPopup();
        con.searchCriteriaClient = 'Test Account';
        for(InitiativePlanExtension.FilterWrapper wrap : con.listClientlevelFiltrWrap){
            wrap.checked = true;
        }
        con.searchClientsUI();

        for(InitiativePlanExtension.AccWrapper wrap : con.listClientWrapper){
            wrap.checked = true;
        }
        System.assertEquals(10, con.listClientWrapper.size());
        con.showSelected();
        con.showAll();
        con.addSelected();
        Test.stopTest();
        con.clearFilter();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();
        con.getprev();
        con.getnxt();
        con.gettotalRecs();
        con.getPageNumber();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Customer Selector
     */
    private static testMethod void IPCustSelectorTest() {
        // create client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 50);
        insert listClientAcc;
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        update listClientAcc;

        // setup the page parameters and select the clients and add them.
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('curSelector', 'ClientSelector');
        con.showPopup();
        for(InitiativePlanExtension.AccWrapper wrap : con.listClientWrapper){
            wrap.checked = true;
        }
        con.addSelected();

        //create customer records.
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 50);
        insert listCustAcc;
        for(Account acc : listCustAcc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        update listCustAcc;

        //create cc records
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustAcc);
        insert listCC;

        // setup the page parameters and select the customers and add them.
        System.currentPageReference().getParameters().put('curSelector', 'CustSelector');
        Test.startTest();
        con.showPopup();
        con.searchCriteriaCust = 'Test Account';
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustlevelFiltrWrap){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustTypeFiltrWarp){
            wrap.checked = true;
        }
        con.searchCustomerUI();

        for(InitiativePlanExtension.AccWrapper wrap : con.listcustWrapper){
            wrap.checked = true;
        }
        System.assertEquals(10, con.listcustWrapper.size());
        con.showSelected();
        con.showAll();
        con.addSelected();
        Test.stopTest();
        con.clearFilter();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Initiative Selector
     */
    private static testMethod void IPInitSelectorTest() {
        // create client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 2);
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        Insert listClientAcc;

        // setup the page parameters and select the clients and add them.
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('curSelector', 'ClientSelector');
        con.showPopup();
        for(InitiativePlanExtension.AccWrapper wrap : con.listClientWrapper){
            wrap.checked = true;
        }
        con.addSelected();

        //create L4 customer records.
        List<Account> listCustL4Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 2);
        for(Account acc : listCustL4Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        Insert listCustL4Acc;

        //create L5 customer records
        List<Account> listCustL5Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L5CustomerType, 2);
        for(Account acc : listCustL5Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        Insert listCustL5Acc;

        //insert cc records;
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL4Acc);
        listCC.addAll(UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL5Acc));
        insert listCC;

        // setup the page parameters and select the customers and add them.
        System.currentPageReference().getParameters().put('curSelector', 'CustSelector');
        con.showPopup();
        con.searchCriteriaCust = 'Test Account';
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustlevelFiltrWrap){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustTypeFiltrWarp){
            wrap.checked = true;
        }
        con.searchCustomer();

        for(InitiativePlanExtension.AccWrapper wrap : con.listcustWrapper){
            wrap.checked = true;
        }
        con.showSelected();
        con.showAll();
        con.addSelected();
        Test.startTest();

        //create Strategy, Initiative, Banner Allocation and Sub Banner Allocation records (Both National and Local)
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listClientAcc);
        insert listNS;

        //create a map of client id and national strategy id
        map<Id,Id> mapClientIdNSIs = new Map<Id,Id>();
        for(National_Strategy__c ns : listNS){
            mapClientIdNSIs.put(ns.Client__c,ns.Id);
        }
        List<Local_Strategy__c> listLS = UtilityClassForTestDataSetUp.createLSList(listCC,mapClientIdNSIs);
        insert listLS;
        List<National_Initiative__c> listNI = UtilityClassForTestDataSetUp.createNIList(listNS);
        for(National_Initiative__c ni : listNI){
            ni.Initiative_Start_Date__c = System.Today();
            ni.Initiative_End_Date__c = System.Today() + 10;
            ni.Initiatives__c = 'Assortment / Distribution';
            ni.Objectives__c = 'Item Conversion';
        }
        insert listNI;
        List<Local_Initiative__c> listLI = UtilityClassForTestDataSetUp.createLIList(listLS);
        for(Local_Initiative__c li : listLI){
            li.Initiative_Start_Date__c = System.Today();
            li.Initiative_End_Date__c = System.Today() + 10;
            li.Initiatives__c = 'Forecast';
            li.Objectives__c = 'Volume';
        }
        insert listLI;

        // setup the page parameters and select the customers and add them.
        System.currentPageReference().getParameters().put('curSelector', 'InitSelector');
        con.custVisitInput.Start_Date__c = System.Today();
        con.custVisitInput.End_Date__c = System.Today() + 10;
        con.custVisitInput.Name = 'test visit';
        con.showPopup();

        List<National_Banner_Allocation__c> listNBA = UtilityClassForTestDataSetUp.createNBAList(listNI);
        for(National_Banner_Allocation__c nba : listNBA){
            for(Client_Customer_Relationship__c cc : listCC){
                nba.Client_Customer_Relationship__c = cc.Id;
                nba.Status__c = AcostaConstants.StatusAllocated;
                nba.National_Banner_Allocation_Name__c = 'test nba';
            }
        }
        listNBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listNBA;

        List<Local_Banner_Allocation__c> listLBA = UtilityClassForTestDataSetUp.createLBAList(listLI);
        for(Local_Banner_Allocation__c lba : listLBA){
            for(Client_Customer_Relationship__c cc : listCC){
                lba.Client_Customer_Relationship__c = cc.Id;
                lba.Status__c = AcostaConstants.StatusAllocated;
                lba.Local_Banner_Allocation_Name__c = 'test lba';
            }
        }
        listLBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listLBA;

        List<National_Sub_Banner_Allocation__c> listNSBA = UtilityClassForTestDataSetUp.createNSBAList(listNBA);
        for(National_Sub_Banner_Allocation__c nsba : listNSBA){
            for(Client_Customer_Relationship__c cc : listCC){
                nsba.Client_Customer_Relationship__c = cc.Id;
                nsba.Status__c = AcostaConstants.StatusAllocated;
                nsba.National_Sub_Banner_Allocation_Name__c = 'test nsba';
            }
        }
        listNSBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listNSBA;

        List<Local_Sub_Banner_Allocation__c> listLSBA = UtilityClassForTestDataSetUp.createLSBAList(listLBA);
        for(Local_Sub_Banner_Allocation__c lsba : listLSBA){
            for(Client_Customer_Relationship__c cc : listCC){
                lsba.Client_Customer_Relationship__c = cc.Id;
                lsba.Status__c = AcostaConstants.StatusAllocated;
                lsba.Local_Sub_Banner_Allocation_Name__c = 'test lsba';
            }
        }
        listLSBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listLSBA;

        con.showPopup();
        System.assertEquals(10, con.listInitWrapperOffset.size());
        for(InitiativePlanExtension.FilterWrapper wrap : con.listIniFiltrWrap){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listObjFiltrWrap){
            wrap.checked  = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listBannerFiltrWrap){
            wrap.checked  = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listSBFiltrWrap){
            wrap.checked  = true;
        }

        for(InitiativePlanExtension.InitiativeWrapper wrap : con.listInitWrapper){
            wrap.checked = true;
        }
        con.showSelected();
        con.showAll();
        con.addSelected();

        Test.stopTest();
        con.refreshInitiativeFilter();
        con.refreshObjectiveFilter();
        con.refreshbannerFilter();
        con.refreshSubBannerFilter();
        con.clearFilter();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();
        con.showSelected();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the User Selector
     */
    private static testMethod void IPUserSelectorTest() {
        // create client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 2);
        insert listClientAcc;
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        update listClientAcc;

        // setup the page parameters and select the clients and add them.
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('curSelector', 'ClientSelector');
        con.showPopup();
        for(InitiativePlanExtension.AccWrapper wrap : con.listClientWrapper){
            wrap.checked = true;
        }
        con.addSelected();

        //create L4 customer records.
        List<Account> listCustL4Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 2);
        insert listCustL4Acc;
        for(Account acc : listCustL4Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        update listCustL4Acc;

        //create L5 customer records
        List<Account> listCustL5Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L5CustomerType, 2);
        insert listCustL5Acc;
        for(Account acc : listCustL5Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        update listCustL5Acc;

        //insert cc records;
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL4Acc);
        listCC.addAll(UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL5Acc));
        insert listCC;

        // setup the page parameters and select the customers and add them.
        System.currentPageReference().getParameters().put('curSelector', 'CustSelector');
        con.showPopup();
        con.searchCriteriaCust = 'Test Account';
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustlevelFiltrWrap){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustTypeFiltrWarp){
            wrap.checked = true;
        }
        con.searchCustomer();

        for(InitiativePlanExtension.AccWrapper wrap : con.listcustWrapper){
            wrap.checked = true;
        }
        con.showSelected();
        con.showAll();
        con.addSelected();

        List<User> listUser = UtilityClassForTestDataSetUp.createAdminUserList(10);
        Insert listUser;
        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustL5Acc[0], listUser);
        for(AccountTeamMember atm : listATM){
            atm.TeamMemberRole = 'Acosta Management';
        }
        insert listATM;
        Test.startTest();

        // setup the page parameters and select the usres and add them
        System.currentPageReference().getParameters().put('curSelector', 'UserSelector');
        con.showPopup();

        for(InitiativePlanExtension.FilterWrapper wrap : con.listAccFilter){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listAccTeamFilter){
            wrap.checked = true;
        }
        con.searchCriteria = 'Acosta Management';
        con.searchUserUI();
        System.assertEquals(10, con.listUsrWrapper.size());
        for(InitiativePlanExtension.UserWrapper wrap : con.listUsrWrapper){
            wrap.checked = true;
        }
        con.showSelected();
        con.showAll();
        con.addSelected();
        con.clearFilter();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the View Summary Selector
     */
    private static testMethod void IPViewSummarySelectorTest() {
        // create client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 2);
        insert listClientAcc;
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        update listClientAcc;

        // setup the page parameters and select the clients and add them.
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('curSelector', 'ClientSelector');
        con.showPopup();
        for(InitiativePlanExtension.AccWrapper wrap : con.listClientWrapper){
            wrap.checked = true;
        }
        con.addSelected();

        //create L4 customer records.
        List<Account> listCustL4Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 2);
        insert listCustL4Acc;
        for(Account acc : listCustL4Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        update listCustL4Acc;

        //create L5 customer records
        List<Account> listCustL5Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L5CustomerType, 2);
        insert listCustL5Acc;
        for(Account acc : listCustL5Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        update listCustL5Acc;

        //insert cc records;
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL4Acc);
        listCC.addAll(UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL5Acc));
        insert listCC;

        // setup the page parameters and select the customers and add them.
        System.currentPageReference().getParameters().put('curSelector', 'CustSelector');
        con.showPopup();
        con.searchCriteriaCust = 'Test Account';
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustlevelFiltrWrap){
            wrap.checked = true;
        }
        for(InitiativePlanExtension.FilterWrapper wrap : con.listCustTypeFiltrWarp){
            wrap.checked = true;
        }
        con.searchCustomer();

        for(InitiativePlanExtension.AccWrapper wrap : con.listcustWrapper){
            wrap.checked = true;
        }
        con.showSelected();
        con.showAll();
        con.addSelected();

        Test.startTest();

        // setup the page parameters and select the usres and add them
        System.currentPageReference().getParameters().put('curSelector', 'SummarySelector');
        con.showPopup();

        con.clearFilter();
        con.FirstPage();
        con.previous();
        con.next();
        con.LastPage();

        Test.stopTest();
   }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the edit scenario
     */
    private static testMethod void IPEditTest() {
        Customer_Visit__c initPlan = UtilityClassForTestDataSetUp.createInitiativePlan();
        Insert initPlan;
        // create client records.
        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L3ClientType, 2);
        for(Account acc : listClientAcc){
            acc.Level_Name__c = AcostaConstants.clntChannelLevel;
        }
        Insert listClientAcc;

        //create L4 customer records.
        List<Account> listCustL4Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L4CustomerType, 2);
        for(Account acc : listCustL4Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        Insert listCustL4Acc;

        //create L5 customer records
        List<Account> listCustL5Acc = UtilityClassForTestDataSetUp.CreateAccountList(AcostaConstants.L5CustomerType, 2);
        for(Account acc : listCustL5Acc){
            acc.Level_Name__c = AcostaConstants.custBannerLevelvalue;
            acc.Customer_Type__c = AcostaConstants.custypeDistributer;
        }
        Insert listCustL5Acc;
        //Create Initiative Plan Account Relationship
        List<Customer_Visit_Account_Relationship__c> listInitPlanAccRel = UtilityClassForTestDataSetUp.createInitiativePlanAccRelList(initPlan,listClientAcc);
        listInitPlanAccRel.addAll(UtilityClassForTestDataSetUp.createInitiativePlanAccRelList(initPlan,listCustL4Acc));
        listInitPlanAccRel.addAll(UtilityClassForTestDataSetUp.createInitiativePlanAccRelList(initPlan,listCustL5Acc));
        Insert listInitPlanAccRel;

        //insert cc records;
        List<Client_Customer_Relationship__c> listCC = UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL4Acc);
        listCC.addAll(UtilityClassForTestDataSetUp.createListClientCust(listClientAcc,listCustL5Acc));
        insert listCC;

        //create Strategy, Initiative, Banner Allocation and Sub Banner Allocation records (Both National and Local)
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listClientAcc);
        insert listNS;

        //create a map of client id and national strategy id
        map<Id,Id> mapClientIdNSIs = new Map<Id,Id>();
        for(National_Strategy__c ns : listNS){
            mapClientIdNSIs.put(ns.Client__c,ns.Id);
        }
        List<Local_Strategy__c> listLS = UtilityClassForTestDataSetUp.createLSList(listCC,mapClientIdNSIs);
        insert listLS;
        List<National_Initiative__c> listNI = UtilityClassForTestDataSetUp.createNIList(listNS);
        for(National_Initiative__c ni : listNI){
            ni.Initiative_Start_Date__c = System.Today();
            ni.Initiative_End_Date__c = System.Today() + 10;
            ni.Initiatives__c = 'Assortment / Distribution';
            ni.Objectives__c = 'Item Conversion';
        }
        insert listNI;
        List<Local_Initiative__c> listLI = UtilityClassForTestDataSetUp.createLIList(listLS);
        for(Local_Initiative__c li : listLI){
            li.Initiative_Start_Date__c = System.Today();
            li.Initiative_End_Date__c = System.Today() + 10;
            li.Initiatives__c = 'Forecast';
            li.Objectives__c = 'Volume';
        }
        insert listLI;

        List<National_Banner_Allocation__c> listNBA = UtilityClassForTestDataSetUp.createNBAList(listNI);
        for(National_Banner_Allocation__c nba : listNBA){
            for(Client_Customer_Relationship__c cc : listCC){
                nba.Client_Customer_Relationship__c = cc.Id;
                nba.Status__c = AcostaConstants.StatusAllocated;
                nba.National_Banner_Allocation_Name__c = 'test nba';
            }
        }
        listNBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listNBA;

        List<Local_Banner_Allocation__c> listLBA = UtilityClassForTestDataSetUp.createLBAList(listLI);
        for(Local_Banner_Allocation__c lba : listLBA){
            for(Client_Customer_Relationship__c cc : listCC){
                lba.Client_Customer_Relationship__c = cc.Id;
                lba.Status__c = AcostaConstants.StatusAllocated;
                lba.Local_Banner_Allocation_Name__c = 'test lba';
            }
        }
        listLBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listLBA;

        List<National_Sub_Banner_Allocation__c> listNSBA = UtilityClassForTestDataSetUp.createNSBAList(listNBA);
        for(National_Sub_Banner_Allocation__c nsba : listNSBA){
            for(Client_Customer_Relationship__c cc : listCC){
                nsba.Client_Customer_Relationship__c = cc.Id;
                nsba.Status__c = AcostaConstants.StatusAllocated;
                nsba.National_Sub_Banner_Allocation_Name__c = 'test nsba';
            }
        }
        listNSBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listNSBA;

        List<Local_Sub_Banner_Allocation__c> listLSBA = UtilityClassForTestDataSetUp.createLSBAList(listLBA);
        for(Local_Sub_Banner_Allocation__c lsba : listLSBA){
            for(Client_Customer_Relationship__c cc : listCC){
                lsba.Client_Customer_Relationship__c = cc.Id;
                lsba.Status__c = AcostaConstants.StatusAllocated;
                lsba.Local_Sub_Banner_Allocation_Name__c = 'test lsba';
            }
        }
        listLSBA[0].Status__c = AcostaConstants.StatusUnAllocated;
        insert listLSBA;

        //Create Initiative Plan Initiative Relationship records.
        List<Customer_Visit_Initiative_Relationship__c> listInitPlanInitRel = UtilityClassForTestDataSetUp.createInitiativePlanInitRelList(initPlan, listLI, listNI);
        Insert listInitPlanInitRel;

        // Create Users and ATM
        List<User> listUser = UtilityClassForTestDataSetUp.createAdminUserList(10);
        Insert listUser;
        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listCustL5Acc[0], listUser);
        for(AccountTeamMember atm : listATM){
            atm.TeamMemberRole = 'Acosta Management';
        }
        insert listATM;

        // Create Initiative Plan User Relationship records.
        List<Customer_Visit_User_Relationship__c> listInitPlanUserRel = UtilityClassForTestDataSetUp.createInitiativePlanUserRelList(initPlan,listUser);
        Insert listInitPlanUserRel;

        // setup the page parameters and invoke the constructor
        Test.setCurrentPage(Page.InitiativePlan);
        System.currentPageReference().getParameters().put('custVisitId', initPlan.Id);
        InitiativePlanExtension con = new InitiativePlanExtension(new ApexPages.StandardController(new Customer_Visit__c()));
        System.assertNotEquals(null, con.clientsSelected);
        System.assertNotEquals(null, con.customersSelected);
        System.assertNotEquals(null, con.initiativesSelected);
        System.assertNotEquals(null, con.usersSelected);

        con.saveVisit();
        Customer_Visit__c initPlanSaved = [Select Status__c from Customer_Visit__c where id =: initPlan.Id];
        System.assertEquals(AcostaConstants.statusIPDraft, initPlanSaved.Status__c);

        // user is unselected.
        System.currentPageReference().getParameters().put('curSelector', 'UserSelector');
        con.showPopup();
        con.listUsrWrapper[0].checked = false;
        con.listUsrWrapper[0].checked = false;
        con.addSelected();

        con.submitVisit();
        Customer_Visit__c initPlanSubmitted = [Select Status__c from Customer_Visit__c where id =: initPlan.Id];
        System.assertEquals(AcostaConstants.statusIPSubmitted, initPlanSubmitted.Status__c);
        con.saveAndExit();
        con.exit();
    }
}