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
/**
 * Description  :   Test class for the ProductSelectorController1  class.
 *
 * Created By   :   Abhishek Tripathi
 *
 * Created Date :   9/16/2016
 */
@isTest(seeAllData=false)
public class ProductSelectorController1_Test {

    //unit test method
    static testMethod void testMethod1() {

//Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'Test acc';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc2.Id;
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = true;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Product_SKU__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;
        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();


        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '33';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '222';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();


    controller.FirstPage();
    controller.next();
    controller.previous();

    controller.LastPage();
    controller.getprev();
    controller.getnxt();
    controller.gettotalRecs();
    controller.getPageNumber();


        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        Integer count = controller.totalSubBannerRecs;
        String brl = controller.bannerResultsList;
        String ssb = controller.selectedSubBanners;
        controller.getMyCCTCheckboxes();
        controller.selectAllBannersAndSubBanners();
        controller.selectAllBanners();
        controller.clearFilters();
        controller.clearAllSelected();
        controller.showSelected();
        controller.showAll();
        controller.allocateAllValue = '12';
        controller.applyTargetToSelected();
    }


    //unit test method
    static testMethod void testMethod12() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Product_SKU__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(National_Banner_Allocation__c nb : nbas) {

        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nb.Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

    controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = '';
    controller.filterList();

    controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = '';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();

    controller.searchedName = '';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();

    controller.searchedName = '';
    controller.nba.System_Customer_Type_Multi__c = '';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();


        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        controller.saveAndNewInitiative();
    controller.Exit();
        controller.saveAndExit();

    }//end testMethod1()


    //unit test method
    static testMethod void testMethod13() {

        //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'Test acc';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc2.Id;
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
        ni.Has_a_Target__c = false;
    ni.Product_Group__c = 'test group';
        ni.Unit_of_Measure__c  = 'Percent';
        insert ni;

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();
        controller.filterList();


        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '12';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '12';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        controller.allocateAndNewInitiative();

    }//end testMethod13()

    //unit test method
    static testMethod void testMethod15() {

        //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'Test acc';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc2.Id;
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Product_SKU__c = 'test';

        insert ni;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();


        controller.filterList();


        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        controller.allocateAndNewInitiative();
    controller.allocateAndExit();

    }//end testMethod15()


    //unit test method
    static testMethod void testMethod14() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'Test acc';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc2.Id;
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = true;
        ni.Unit_of_Measure__c  = 'Percent';
        insert ni;

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();
        controller.filterList();


        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '45';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        controller.allocateAndNewInitiative();

    }//end testMethod14()

    //unit test method
    static testMethod void testMethod16() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
        acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Product_SKU__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(National_Banner_Allocation__c nb : nbas) {

        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nb.Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod16()


//unit test method
    static testMethod void testMethod17() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Product_SKU__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(National_Banner_Allocation__c nb : nbas) {

        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nb.Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod17()

    //unit test method
    static testMethod void testMethod18() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nbas[0].Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod18

//unit test method
    static testMethod void testMethod19() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nbas[0].Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod19

    //unit test method
    static testMethod void testMethod110() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = true;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod110


    //unit test method
    static testMethod void testMethod111() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '12';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod111()

    //unit test method
    static testMethod void testMethod112() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = true;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nbas[0].Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '11';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '11';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod112()


//unit test method
    static testMethod void testMethod113() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = false;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nbas[0].Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '11';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod113()

    //unit test method
    static testMethod void testMethod114() {

    //Customer Name record for L4
        Account acc3 = new Account();
        acc3.Name = 'Test acc';
        acc3.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc3;


        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'test';
    acc.Customer_Type__c = 'Distributor';
    acc.Customer_Sub_Type__c = 'CONUS';
    acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

    //Customer Name record for Event
        Account acc2 = new Account();
        acc2.Name = 'test';
    acc2.Customer_Type__c = 'Distributor';
    acc2.Customer_Sub_Type__c = 'CONUS';
    acc2.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc2;

    //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'test';
    acc1.ParentId = acc2.Id;
    acc1.Customer_Type__c = 'Distributor';
    acc1.Customer_Sub_Type__c = 'CONUS';
    acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc2.Id;
        cc.Status__c = 'Active';
        insert cc;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;


        //Initiative data
        National_Initiative__c ni = new National_Initiative__c();
        ni.Target__c = '24';
        ni.Strategy__c = str.Id;
    ni.Has_a_Target__c = true;
        ni.Unit_of_Measure__c  = 'Percent';
    ni.Brand__c = 'test';

        insert ni;

    List<National_Banner_Allocation__c> nbas = new List<National_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
        nba.Client_Customer_Relationship__c = cc.Id;
        nbas.add(nba);

    }
    insert nbas;

    List<National_Sub_Banner_Allocation__c> nbs = new List<National_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
        nsba.System_Account_Id__c = acc2.Id;
        nsba.Client_Customer_Relationship__c = cc.Id;
        nsba.National_Banner_Allocation__c = nbas[0].Id;
        nbs.add(nsba);

    }
    insert nbs;


        National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
        nba.Allocated_non_Editable__c = '33';
        nba.Proposed_editable__c = '45';
        nba.National_Initiative_Lookup__c = ni.Id;
        nba.System_Account_Name__c = acc.Name;
        nba.System_Account_Id__c = acc2.id;
     nba.Client_Customer_Relationship__c = cc.Id;
        insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.System_Account_Id__c = acc2.Id;
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    insert nsba;

        PageReference pageRef = Page.BannerUI1;
        pageRef.getParameters().put('initiativeId', ni.id);
        Test.setCurrentPage(pageRef);

        ProductSelectorController1 controller = new ProductSelectorController1();

    controller.searchedName = 'test';
    controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {

            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '11';

        for(ProductSelectorController1.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }

        }

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();

        ProductSelectorController1.updateAllocated( ni.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();

    }//end testMethod114()





}