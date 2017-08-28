/**************************************************************************************
Apex Class Name:  LocalStrategyControllerTest
Version     : 1.0
Created Date    : 2 Sep 2016
Description    : Test class for the class LocalStrategyController
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rahul Nasa                  15 Sep 2016            Original Version
*************************************************************************************/
@isTest
private class LocalStrategyControllerTest{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Local Strategy Controller

     */
    private static testMethod void LocalStrategyControllerSaveandExitInitiativeTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;


        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();
        System.assertNotequals(null,con.SaveLocalStrategy());
        System.assertNotequals(null,con.SaveLocalStrategy());

        System.currentPageReference().getParameters().put('strategyID', con.localStrategy.Id);
        System.currentPageReference().getParameters().put('CCRelId', null);
        LocalStrategyController  conInitiative =new LocalStrategyController();
        conInitiative.showPopUp();
        List<LocalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.getunitOfMeasureOptions();
        conInitiative.getStatusOptions();
        conInitiative.getpriorityOptions();
        conInitiative.getunitOfMeasureOptions();
        conInitiative.getcoreFlexOptions();
        conInitiative.getnewItemOptions();
        conInitiative.searchAccounts();
        List<string> listUOM = new List<string>();
        listUOM.add('PN - Pounds Net');
        List<string> listCoreFlex = new List<string>();
        listCoreFlex.add('Core');
        List<string> listItemValue = new List<string>();
        listItemValue.add('Yes');
        conInitiative.listUnitOfMeasure = listUOM;
        conInitiative.listCoreFlex = listCoreFlex ;
        conInitiative.listItemValue = listItemValue ;
        conInitiative.searchCriteriaProd = 'test';

        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.FirstPage();
        conInitiative.LastPage();
        conInitiative.getPrev();
        conInitiative.FirstPage();
        conInitiative.next();
        conInitiative.FirstPage();
        conInitiative.getnxt();
        conInitiative.ClearSelection();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.ChangeRadio();

        conInitiative.AddSelected();
        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        List<LocalStrategyController.DepartmentWrapper> ListPGDepartment = conInitiative.getPGDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListPGDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doPGDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListPGCategory = conInitiative.getPGCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListPGCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListPGBrand = conInitiative.getPGBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListPGBrand)
        {
             bw.checked = true;
        }
        conInitiative.doPGBrandActionSupport();
        conInitiative.catParam = null;
        conInitiative.doPGBrandActionSupport();
        List<LocalStrategyController.DepartmentWrapper> ListPGDepartment1 = conInitiative.getPGDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListPGDepartment1)
        {
             dw.checked = true;
        }
        conInitiative.doPGDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListPGCategory1 = conInitiative.getPGCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListPGCategory1)
        {
             cw.checked = true;
        }
        conInitiative.doPGCatActionSupport();
        conInitiative.brandParam = null;
        conInitiative.doPGBrandActionSupport();
        conInitiative.doPGCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListPGProductGroup = conInitiative.getPGProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListPGProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.doPGPGActionSupport();

        conInitiative.showSelected();
        conInitiative.ClearFilters();
        conInitiative.AddSelected();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.bonusChecked = 'Yes';
        conInitiative.hastarget = 'Yes';
        conInitiative.SaveandExitInitiative();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.localInitiative.Initiatives__c = 'Forecast';
        conInitiative.localInitiative.Objectives__c = 'Volume';
        conInitiative.localInitiative.Priority__c = 'High';
        conInitiative.localInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.localInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandExitInitiative();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.localInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandExitInitiative();
        List<Local_Initiative__c> ListLI = new List<Local_Initiative__c>();
        ListLI.add(conInitiative.localInitiative);
        update ListLI;
        List<Local_Banner_Allocation__c> ListLBA = UtilityClassForTestDataSetUp.createLBAList(ListLI);
        for(Local_Banner_Allocation__c lba : ListLBA )
        {
            lba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLBA ;
        List<Local_Sub_Banner_Allocation__c> ListLSBA = UtilityClassForTestDataSetUp.createLSBAList(ListLBA );
        for(Local_Sub_Banner_Allocation__c lsba : ListLSBA)
        {
            lsba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLSBA ;
        conInitiative.SaveandExitInitiative();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandExitInitiative();

        Test.stopTest();
    }

    private static testMethod void LocalStrategyControllerSaveandAllocateBannerTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();
        System.assertNotequals(null,con.SavelocalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.localStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        LocalStrategyController conInitiative =new LocalStrategyController();
        conInitiative.showPopUp();
        List<LocalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.getunitOfMeasureOptions();
        conInitiative.getStatusOptions();
        conInitiative.getpriorityOptions();
        conInitiative.getunitOfMeasureOptions();
        conInitiative.getcoreFlexOptions();
        conInitiative.getnewItemOptions();
        conInitiative.searchAccounts();
        List<string> listUOM = new List<string>();
        listUOM.add('PN - Pounds Net');
        List<string> listCoreFlex = new List<string>();
        listCoreFlex.add('Core');
        List<string> listItemValue = new List<string>();
        listItemValue.add('Yes');
        conInitiative.listUnitOfMeasure = listUOM;
        conInitiative.listCoreFlex = listCoreFlex ;
        conInitiative.listItemValue = listItemValue ;
        conInitiative.searchCriteriaProd = 'test';

        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.FirstPage();
        conInitiative.LastPage();
        conInitiative.getPrev();
        conInitiative.FirstPage();
        conInitiative.next();
        conInitiative.FirstPage();
        conInitiative.getnxt();
        conInitiative.ClearSelection();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.ChangeRadio();

        conInitiative.AddSelected();
        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.showSelected();
        conInitiative.ClearFilters();
        conInitiative.AddSelected();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.bonusChecked = 'Yes';
        conInitiative.hastarget = 'Yes';
        conInitiative.SaveandAllocateBanner();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.localInitiative.Initiatives__c = 'Forecast';
        conInitiative.localInitiative.Objectives__c = 'Volume';
        conInitiative.localInitiative.Priority__c = 'High';
        conInitiative.localInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.localInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandAllocateBanner();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.localInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandAllocateBanner();

        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandAllocateBanner();
        conInitiative.Exit();
        conInitiative.ExitHeader();

        Test.stopTest();
    }

    private static testMethod void LocalStrategyControllerSaveandAllocateSubBannerTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();
        System.assertNotequals(null,con.SavelocalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.localStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        LocalStrategyController conInitiative =new LocalStrategyController();
        conInitiative.showPopUp();
        List<LocalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.getunitOfMeasureOptions();
        conInitiative.getStatusOptions();
        conInitiative.getpriorityOptions();
        conInitiative.getunitOfMeasureOptions();
        conInitiative.getcoreFlexOptions();
        conInitiative.getnewItemOptions();
        conInitiative.searchAccounts();
        List<string> listUOM = new List<string>();
        listUOM.add('PN - Pounds Net');
        List<string> listCoreFlex = new List<string>();
        listCoreFlex.add('Core');
        List<string> listItemValue = new List<string>();
        listItemValue.add('Yes');
        conInitiative.listUnitOfMeasure = listUOM;
        conInitiative.listCoreFlex = listCoreFlex ;
        conInitiative.listItemValue = listItemValue ;
        conInitiative.searchCriteriaProd = 'test';

        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.FirstPage();
        conInitiative.LastPage();
        conInitiative.getPrev();
        conInitiative.FirstPage();
        conInitiative.next();
        conInitiative.FirstPage();
        conInitiative.getnxt();
        conInitiative.ClearSelection();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.ChangeRadio();

        conInitiative.AddSelected();
        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.showSelected();
        conInitiative.ClearFilters();
        conInitiative.AddSelected();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.bonusChecked = 'Yes';
        conInitiative.hastarget = 'Yes';
        conInitiative.SaveandAllocateSubBanner();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.localInitiative.Initiatives__c = 'Forecast';
        conInitiative.localInitiative.Objectives__c = 'Volume';
        conInitiative.localInitiative.Priority__c = 'High';
        conInitiative.localInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.localInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandAllocateSubBanner();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.localInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandAllocateSubBanner();

        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandAllocateSubBanner();
        conInitiative.Exit();
        conInitiative.ExitHeader();

        Test.stopTest();
    }

    private static testMethod void LocalStrategyControllerSaveandAllocateBannerandExitTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();
        System.assertNotequals(null,con.SavelocalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.localStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        LocalStrategyController conInitiative =new LocalStrategyController();
        conInitiative.showPopUp();
        List<LocalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.getunitOfMeasureOptions();
        conInitiative.getStatusOptions();
        conInitiative.getpriorityOptions();
        conInitiative.getunitOfMeasureOptions();
        conInitiative.getcoreFlexOptions();
        conInitiative.getnewItemOptions();
        conInitiative.searchAccounts();
        List<string> listUOM = new List<string>();
        listUOM.add('PN - Pounds Net');
        List<string> listCoreFlex = new List<string>();
        listCoreFlex.add('Core');
        List<string> listItemValue = new List<string>();
        listItemValue.add('Yes');
        conInitiative.listUnitOfMeasure = listUOM;
        conInitiative.listCoreFlex = listCoreFlex ;
        conInitiative.listItemValue = listItemValue ;
        conInitiative.searchCriteriaProd = 'test';

        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.FirstPage();
        conInitiative.LastPage();
        conInitiative.getPrev();
        conInitiative.FirstPage();
        conInitiative.next();
        conInitiative.FirstPage();
        conInitiative.getnxt();
        conInitiative.ClearSelection();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'None';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.ChangeRadio();

        conInitiative.AddSelected();
        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.showSelected();
        conInitiative.ClearFilters();
        conInitiative.AddSelected();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.bonusChecked = 'Yes';
        conInitiative.hastarget = 'Yes';
        conInitiative.SaveandAllocateBannerandExit();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.localInitiative.Initiatives__c = 'Forecast';
        conInitiative.localInitiative.Objectives__c = 'Volume';
        conInitiative.localInitiative.Priority__c = 'High';
        conInitiative.localInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.localInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandAllocateBannerandExit();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.localInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandAllocateBannerandExit();
        List<Local_Initiative__c> ListLI = new List<Local_Initiative__c>();
        ListLI.add(conInitiative.localInitiative);
        update ListLI;
        List<Local_Banner_Allocation__c> ListLBA = UtilityClassForTestDataSetUp.createLBAList(ListLI);
        for(Local_Banner_Allocation__c lba : ListLBA )
        {
            lba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLBA ;
        List<Local_Sub_Banner_Allocation__c> ListLSBA = UtilityClassForTestDataSetUp.createLSBAList(ListLBA );
        for(Local_Sub_Banner_Allocation__c lsba : ListLSBA)
        {
            lsba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLSBA ;
        conInitiative.SaveandAllocateBannerandExit();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandAllocateBannerandExit();
        conInitiative.Exit();
        conInitiative.ExitHeader();

        Test.stopTest();
    }

    private static testMethod void LocalStrategyControllerSaveandNewTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();
        System.assertNotequals(null,con.SavelocalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.localStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        LocalStrategyController conInitiative =new LocalStrategyController();
        conInitiative.showPopUp();
        List<LocalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<LocalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<LocalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(LocalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
        {
             pgw.checked = true;
             break;
        }

        conInitiative.doProductUomSKUSupport();
        conInitiative.doProductCoreFlexSKUSupport();
        conInitiative.doProductItemSKUSupport();
        conInitiative.doProductPGSKUSupport();

        conInitiative.getunitOfMeasureOptions();
        conInitiative.getStatusOptions();
        conInitiative.getpriorityOptions();
        conInitiative.getunitOfMeasureOptions();
        conInitiative.getcoreFlexOptions();
        conInitiative.getnewItemOptions();
        conInitiative.searchAccounts();
        List<string> listUOM = new List<string>();
        listUOM.add('PN - Pounds Net');
        List<string> listCoreFlex = new List<string>();
        listCoreFlex.add('Core');
        List<string> listItemValue = new List<string>();
        listItemValue.add('Yes');
        conInitiative.listUnitOfMeasure = listUOM;
        conInitiative.listCoreFlex = listCoreFlex ;
        conInitiative.listItemValue = listItemValue ;
        conInitiative.searchCriteriaProd = 'test';

        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.gettotalRecs();

        conInitiative.getPageNumber();


        conInitiative.AddSelected();
        for(LocalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.showSelected();
        conInitiative.next();
        conInitiative.previous();
        conInitiative.ClearFilters();
        conInitiative.AddSelected();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.ChangeRadio();
        conInitiative.RadioSelection = 'ProductGroup';
        conInitiative.ChangeRadio();
        conInitiative.bonusChecked = 'Yes';
        conInitiative.hastarget = 'Yes';

        List<LocalStrategyController.DepartmentWrapper> ListBrandDepartment = conInitiative.getBrandDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(LocalStrategyController.DepartmentWrapper dw : ListBrandDepartment )
        {
             dw.checked = true;
        }
        conInitiative.doBrandDepActionSupport();
        List<LocalStrategyController.CategoryWrapper> ListBrandCategory = conInitiative.getBrandCategoryOptions();
        for(LocalStrategyController.CategoryWrapper cw : ListBrandCategory )
        {
             cw.checked = true;
        }
        conInitiative.doBrandCatActionSupport();
        List<LocalStrategyController.BrandWrapper> ListBrandBrand = conInitiative.getBrandBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrandBrand )
        {
             bw.checked = true;
        }

        conInitiative.doBrandBrandActionSupport();

        conInitiative.SaveandNew();
        conInitiative.catParam = null;
        conInitiative.depParam = null;
        List<LocalStrategyController.BrandWrapper> ListBrandBrand1 = conInitiative.getBrandBrandOptions();
        for(LocalStrategyController.BrandWrapper bw : ListBrandBrand1 )
        {
             bw.checked = true;
        }
        conInitiative.SaveandNew();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.localInitiative.Initiatives__c = 'Forecast';
        conInitiative.localInitiative.Objectives__c = 'Volume';
        //conInitiative.localInitiative.Objectives__c = 'Shippers/Displays';
        conInitiative.localInitiative.Priority__c = 'High';
        conInitiative.localInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.localInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.localInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.SaveandNew();

        Test.stopTest();
    }

    private static testMethod void LocalStrategyControllerLITest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;
        for(Client_Customer_Relationship__c ccr : listCCRL5)
        {
           ccr.Parent_Relationship__c = listCCRL4[0].Id;
        }

        // setup the page parameters and select the clients and add them

        System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();


        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        Local_Initiative__c  LI = UtilityClassForTestDataSetUp.createLI(con.localStrategy.Id);
        Insert LI;
        LI.Product_SKU__c ='test';
        LI.Brand__c ='test';
        LI.Product_Group__c ='test';
        update LI;
        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('id', LI.Id);
        LocalStrategyController conNS =new LocalStrategyController();
        //conNS.SaveUnAllocatedBannerwithoutsharing(listCCRL5[0],LI);
        Test.StopTest();

    }

    private static testMethod void LocalStrategyControllerSaveUnAllbannerwithSharingTest() {

        //create the client records.
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        List<Product__C> listPro = UtilityClassForTestDataSetUp.createProducts(listL4Client, 50);
        Insert listPro;
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);
        insert listL5Customer;

        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );
        insert listCCRL5;
        for(Client_Customer_Relationship__c ccr : listCCRL5)
        {
           ccr.Parent_Relationship__c = listCCRL4[0].Id;
        }
        update listCCRL5;

        // setup the page parameters and select the clients and add them
        system.debug('listCCRL5[0]1-->' + listCCRL5[0]);
        System.currentPageReference().getParameters().put('CCRelId', listCCRL5[0].Id);
        LocalStrategyController con =new LocalStrategyController();
        con.getNSOptions();
        con.NSValue = listNS[0].Id;
        con.localStrategy.Name ='Test LS';
        con.localStrategy.Year__c ='2016';
        con.localStrategy.Strategy_Period_Start__c = system.Today();
        con.localStrategy.Strategy_Period_End__c = system.Today();
        con.localStrategy.Status__c = 'New';
        con.SaveLocalStrategy();



        system.debug('con.localStrategy.Id-->' + con.localStrategy.Id);
        List<Local_Initiative__c> ListLI = new List<Local_Initiative__c>();
        Local_Initiative__c  LI = UtilityClassForTestDataSetUp.createLI(con.localStrategy.Id);
        ListLI.add(LI);
        Insert ListLI;
        //con.SaveUnAllocatedBannerwithoutsharing(listCCRL5[0],LI);
        //con.SaveAllocatedBannerwithoutsharing(listCCRL5[0],LI);
        List<Local_Banner_Allocation__c> ListLBA = UtilityClassForTestDataSetUp.createLBAList(ListLI);
        for(Local_Banner_Allocation__c lba : ListLBA )
        {
            lba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLBA ;
        List<Local_Sub_Banner_Allocation__c> ListLSBA = UtilityClassForTestDataSetUp.createLSBAList(ListLBA );
        for(Local_Sub_Banner_Allocation__c lsba : ListLSBA)
        {
            lsba.Client_Customer_Relationship__c = listCCRL5[0].Id;
        }
        Insert ListLSBA ;


        // setup the page parameters and select the clients and add them
        Test.startTest();
        system.debug('listCCRL5[0]-->' + listCCRL5[0]);
        con.SaveUnAllocatedBannerwithoutsharing(listCCRL5[0],LI);
        con.SaveAllocatedBannerwithoutsharing(listCCRL5[0],LI);

        Test.StopTest();
    }

}