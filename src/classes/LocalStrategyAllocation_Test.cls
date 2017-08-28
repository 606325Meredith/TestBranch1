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
 * Description  :   Test class for the LocalStrategyAllocation  class.
 * 
 * Created By   :   Rahul Nasa 
 * Created Date :   9/19/2016
 */
@isTest(seeAllData=false)
public class LocalStrategyAllocation_Test {

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

        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;
        
        
        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        Local_Strategy__c Localstr1 = new Local_Strategy__c();
        Localstr1.Client_Customer_Relationship__c = cc1.Id;
        Localstr1.National_Strategy__c = str.Id;
        insert Localstr1;
        
        
       
        
        Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;
        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();
        

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper lb : controller.bannerResults.get(ids).nbaWrap) {
                lb.isChecked = true;
                lb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        
    

        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        Integer count = controller.totalSubBannerRecs;
        String brl = controller.bannerResultsList;
        String ssb = controller.selectedSubBanners;
        Account a = controller.accounts;
        controller.getMyCCTCheckboxes();
        controller.selectAllBannersAndSubBanners();
        controller.clearFilters();
        controller.clearAllSelected();
        controller.showSelected();
        controller.showAll();
        controller.next();
        controller.previous();
        controller.FirstPage();
        controller.LastPage();
        controller.getnxt();
        controller.getprev();
        controller.gettotalRecs();
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
        
        
        Local_Strategy__c Localstr1 = new Local_Strategy__c();
        Localstr1.Client_Customer_Relationship__c = cc.Id;
        Localstr1.National_Strategy__c = str.Id;
        insert Localstr1;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
        
        
        Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr1.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    //controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

    controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = '';
    controller.filterList();

    controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = '';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();

    controller.searchedName = '';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();

    controller.searchedName = '';
    controller.lba.System_Customer_Type_Multi__c = '';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';
    controller.filterList();
        

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper lb : controller.bannerResults.get(ids).nbaWrap) {
                lb.isChecked = true;
        lb.proposedTarget = '';
            }
        
        }

         controller.saveAndNewInitiative();
    controller.Exit();
        controller.saveAndExit();
        
    }
    
    
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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
       Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = true;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
       
        insert li;
        
        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();
        controller.filterList();
        

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '12';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '12';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        controller.allocateAndNewInitiative();
        
    }

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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
         Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
       
        insert li;
        
    
        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();


        controller.filterList();
        

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        controller.allocateAndNewInitiative();
    controller.allocateAndExit();
        
    }
    
    
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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
         Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Brand__c = 'test';
       
        insert li;
        
        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();
        controller.filterList();
        

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '45';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        controller.allocateAndNewInitiative();
        
    }

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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
         Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    //controller.nba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }
    

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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;


        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
         Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }

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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
         Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '24';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = false;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_Group__c = 'test';
        
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
    
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    //controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }

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

        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;
        
        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
        Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = true;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
        
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;

         Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
    
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
        
        
    }
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

        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;
        
        
        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
        Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = true;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
        
       
        insert li;
        
     List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Local_Banner_Allocation__c lb : lbas) {

        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lb.Id;
        lbs.add(lsba);
        
    }
    insert lbs;

         Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    //controller.searchedName = 'test';
    //controller.nba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '11';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '11';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }

                       
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
        
        Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
       Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = true;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
        
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lbas[0].Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '11';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }

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
         Local_Strategy__c Localstr = new Local_Strategy__c();
        Localstr.Client_Customer_Relationship__c = cc.Id;
        Localstr.National_Strategy__c = str.Id;
        insert Localstr;

        Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc1.Id;
        cc1.Status__c = 'Active';
        insert cc1;
        
        
        //Initiative data
        Local_Initiative__c li = new Local_Initiative__c();
        li.Target__c = '';
        li.Local_Strategy__c = Localstr.Id;
        li.Has_a_Target__c = true;
        li.Unit_of_Measure__c  = 'Percent';
        li.Product_SKU__c = 'test';
        
       
        insert li;
        
    List<Local_Banner_Allocation__c> lbas = new List<Local_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {

        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
        lba.Client_Customer_Relationship__c = cc.Id;
        lbas.add(lba);
    
    }
    insert lbas;

    List<Local_Sub_Banner_Allocation__c> lbs = new List<Local_Sub_Banner_Allocation__c>();

    for(Integer i=1;i<=200;i++) {


        Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
        lsba.System_Account_Id__c = acc2.Id;
        lsba.Client_Customer_Relationship__c = cc.Id;
        lsba.Local_Banner_Allocation__c = lbas[0].Id;
        lbs.add(lsba);
        
    }
    insert lbs;


        Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
        lba.Allocated_Target__c = '33';
        lba.Proposed_Target__c = '45';
        lba.Local_Initiative__c = li.Id;
        lba.System_Account_Name__c = acc.Name;
        lba.System_Account_Id__c = acc2.id;
     lba.Client_Customer_Relationship__c = cc.Id;
        insert lba;

    Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c ();
    lsba.System_Account_Id__c = acc2.Id;
    lsba.Client_Customer_Relationship__c = cc.Id;
    lsba.Local_Banner_Allocation__c = lba.Id;
    insert lsba;
        
        PageReference pageRef = Page.LocalStrategyAllocation;
        pageRef.getParameters().put('initiativeId', li.id);
        Test.setCurrentPage(pageRef);
        
        LocalStrategyAllocation controller = new LocalStrategyAllocation();

    controller.searchedName = 'test';
    controller.lba.System_Customer_Type_Multi__c = 'Retailer (Self-Dist);Retailer (Indirect);Distributor;Wholesaler;Distributor + Wholesaler;';
    controller.lba.System_Customer_Sub_Type__c = 'Outlet;CONUS;Drug;Institution;';

        controller.filterList();

        for(Id ids : controller.bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
            controller.bannerResults.get(ids).checked = true;
            controller.bannerResults.get(ids).proposed = '11';

        for(LocalStrategyAllocation.NBAWrapper nb : controller.bannerResults.get(ids).nbaWrap) {
                nb.isChecked = true;
        nb.proposedTarget = '';
            }
        
        }

        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        
        LocalStrategyAllocation.updateAllocated( li.Id, controller.bannerResults.values());
        controller.saveUnallocated();
        controller.Exit();
        controller.saveAndExit();
        
    }
                       
    
}