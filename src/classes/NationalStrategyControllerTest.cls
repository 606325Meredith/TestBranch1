/**************************************************************************************
Apex Class Name:  NationalStrategyControllerTest
Version     : 1.0
Created Date    : 2 Sep 2016
Description    : Test class for the class NationalStrategyController
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rahul Nasa                  15 Sep 2016            Original Version
*************************************************************************************/
@isTest
private class NationalStrategyControllerTest{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the National Strategy Controller

     */
    private static testMethod void NationalStrategyControllerSaveandExitInitiativeTest() {
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
        system.debug('listPro-->' + listPro.size());
        system.debug('listPro-->' + listPro[0].Account__c);

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('ClientId', listL3Client[0].Id);
        NationalStrategyController con =new NationalStrategyController();
        Test.setCurrentPage(Page.NationalStrategyHeader);
        con.nationalStrategy.Name ='Test NS';
        con.nationalStrategy.Year__c ='2016';
        con.nationalStrategy.Strategy_Period_Start__c = system.Today();
        con.nationalStrategy.Strategy_Period_End__c = system.Today();
        con.SaveNationalStrategy();
        con.SaveAndCreateStrategyItem();
        con.nationalStrategy.Status__c = 'New';
        System.assertNotequals(null,con.SaveNationalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.nationalStrategy.Id-->' + con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        NationalStrategyController conInitiative =new NationalStrategyController();
        conInitiative.showPopUp();
        List<NationalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<NationalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(NationalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<NationalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(NationalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
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

        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
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
        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        List<NationalStrategyController.DepartmentWrapper> ListPGDepartment = conInitiative.getPGDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListPGDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doPGDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListPGCategory = conInitiative.getPGCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListPGCategory)
        {
             cw.checked = true;
        }
        List<NationalStrategyController.BrandWrapper> ListPGBrand = conInitiative.getPGBrandOptions();
        for(NationalStrategyController.BrandWrapper bw : ListPGBrand)
        {
             bw.checked = true;
        }
        conInitiative.doPGBrandActionSupport();
        conInitiative.catParam = null;
        conInitiative.doPGBrandActionSupport();
        List<NationalStrategyController.DepartmentWrapper> ListPGDepartment1 = conInitiative.getPGDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListPGDepartment1)
        {
             dw.checked = true;
        }
        conInitiative.doPGDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListPGCategory1 = conInitiative.getPGCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListPGCategory1)
        {
             cw.checked = true;
        }
        conInitiative.doPGCatActionSupport();
        conInitiative.brandParam = null;
        conInitiative.doPGBrandActionSupport();
        conInitiative.doPGCatActionSupport();
        List<NationalStrategyController.ProductGroupWrapper> ListPGProductGroup = conInitiative.getPGProductGroupOptions();
        for(NationalStrategyController.ProductGroupWrapper pgw : ListPGProductGroup)
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
        conInitiative.nationalInitiative.Initiatives__c = 'Forecast';
        conInitiative.nationalInitiative.Objectives__c = 'Volume';
        conInitiative.nationalInitiative.Priority__c = 'High';
        conInitiative.nationalInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandExitInitiative();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandExitInitiative();

        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandExitInitiative();

        Test.stopTest();
    }

    private static testMethod void NationalStrategyControllerSaveandAllocateTest() {
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
        system.debug('listPro-->' + listPro.size());
        system.debug('listPro-->' + listPro[0].Account__c);

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('ClientId', listL3Client[0].Id);
        NationalStrategyController con =new NationalStrategyController();
        Test.setCurrentPage(Page.NationalStrategyHeader);
        con.nationalStrategy.Name ='Test NS';
        con.nationalStrategy.Year__c ='2016';
        con.nationalStrategy.Strategy_Period_Start__c = system.Today();
        con.nationalStrategy.Strategy_Period_End__c = system.Today();
        con.SaveNationalStrategy();
        con.SaveAndCreateStrategyItem();
        con.nationalStrategy.Status__c = 'New';
        System.assertNotequals(null,con.SaveNationalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.nationalStrategy.Id-->' + con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        NationalStrategyController conInitiative =new NationalStrategyController();
        conInitiative.showPopUp();
        List<NationalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<NationalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(NationalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<NationalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(NationalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
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

        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
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
        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
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
        conInitiative.SaveandAllocate();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.nationalInitiative.Initiatives__c = 'Forecast';
        conInitiative.nationalInitiative.Objectives__c = 'Volume';
        conInitiative.nationalInitiative.Priority__c = 'High';
        conInitiative.nationalInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandAllocate();

        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandAllocate();

        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandAllocate();
        conInitiative.Exit();
        conInitiative.ExitHeader();

        Test.stopTest();
    }


    private static testMethod void NationalStrategyControllerSaveandNewTest() {
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
        system.debug('listPro-->' + listPro.size());
        system.debug('listPro-->' + listPro[0].Account__c);

        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('ClientId', listL3Client[0].Id);
        NationalStrategyController con =new NationalStrategyController();
        Test.setCurrentPage(Page.NationalStrategyHeader);
        con.nationalStrategy.Name ='Test NS';
        con.nationalStrategy.Year__c ='2016';
        con.nationalStrategy.Strategy_Period_Start__c = system.Today();
        con.nationalStrategy.Strategy_Period_End__c = system.Today();
        con.SaveNationalStrategy();
        con.SaveAndCreateStrategyItem();
        con.nationalStrategy.Status__c = 'New';
        System.assertNotequals(null,con.SaveNationalStrategy());
        System.assertNotequals(null,con.SaveAndCreateStrategyItem());
        system.debug('con.nationalStrategy.Id-->' + con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('strategyID', con.nationalStrategy.Id);
        System.currentPageReference().getParameters().put('ClientId', null);
        NationalStrategyController conInitiative =new NationalStrategyController();
        conInitiative.showPopUp();
        List<NationalStrategyController.DepartmentWrapper> ListDepartment = conInitiative.getDepartmentOptions();
        system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListDepartment)
        {
             dw.checked = true;
        }
        conInitiative.doDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListCategory = conInitiative.getCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListCategory)
        {
             cw.checked = true;
        }
        List<NationalStrategyController.BrandWrapper> ListBrand = conInitiative.getBrandOptions();
        for(NationalStrategyController.BrandWrapper bw : ListBrand)
        {
             bw.checked = true;
        }
        conInitiative.doBrandActionSupport();
        conInitiative.doCatActionSupport();
        List<NationalStrategyController.ProductGroupWrapper> ListProductGroup = conInitiative.getProductGroupOptions();
        for(NationalStrategyController.ProductGroupWrapper pgw : ListProductGroup)
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

        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
            wrap.checked = true;
        }
        conInitiative.searchAcc();
        conInitiative.gettotalRecs();
        conInitiative.gettotalBannerRecs();
        conInitiative.getPageNumber();


        conInitiative.AddSelected();
        for(NationalStrategyController.ProductWrapper wrap : conInitiative.searchResults){
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

        List<NationalStrategyController.DepartmentWrapper> ListBrandDepartment = conInitiative.getBrandDepartmentOptions();
        //system.debug('ListDepartment--->' + ListDepartment);
        for(NationalStrategyController.DepartmentWrapper dw : ListBrandDepartment )
        {
             dw.checked = true;
        }
        conInitiative.doBrandDepActionSupport();
        List<NationalStrategyController.CategoryWrapper> ListBrandCategory = conInitiative.getBrandCategoryOptions();
        for(NationalStrategyController.CategoryWrapper cw : ListBrandCategory )
        {
             cw.checked = true;
        }
        conInitiative.doBrandCatActionSupport();
        List<NationalStrategyController.BrandWrapper> ListBrandBrand = conInitiative.getBrandBrandOptions();
        for(NationalStrategyController.BrandWrapper bw : ListBrandBrand )
        {
             bw.checked = true;
        }

        conInitiative.doBrandBrandActionSupport();

        conInitiative.SaveandNew();
        conInitiative.bonusChecked = 'No';
        conInitiative.hastarget = 'No';
        conInitiative.nationalInitiative.Initiatives__c = 'Forecast';
        conInitiative.nationalInitiative.Objectives__c = 'Volume';
        //conInitiative.nationalInitiative.Objectives__c = 'Shippers/Displays';
        conInitiative.nationalInitiative.Priority__c = 'High';
        conInitiative.nationalInitiative.Initiative_Start_Date__c  = system.Today();
        //conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();

        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.productsselected = null;
        conInitiative.nationalInitiative.Initiative_End_Date__c = system.Today();
        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'Brand';
        conInitiative.SaveandNew();
        conInitiative.RadioSelection = 'ProductSKU';
        conInitiative.SaveandNew();

        Test.stopTest();
    }

    private static testMethod void NationalStrategyControllerNITest() {
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
        System.currentPageReference().getParameters().put('ClientId', listL3Client[0].Id);
        NationalStrategyController con =new NationalStrategyController();

        con.nationalStrategy.Name ='Test NS';
        con.nationalStrategy.Year__c ='2016';
        con.nationalStrategy.Strategy_Period_Start__c = system.Today();
        con.nationalStrategy.Strategy_Period_End__c = system.Today();
        con.nationalStrategy.Status__c = 'New';
        con.SaveNationalStrategy();
        National_Initiative__c  NI = UtilityClassForTestDataSetUp.createNI(con.nationalStrategy.Id);
        Insert NI;
        // setup the page parameters and select the clients and add them
        Test.startTest();
        System.currentPageReference().getParameters().put('id', NI.Id);
        NationalStrategyController conNS =new NationalStrategyController();
    }

}