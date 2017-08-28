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
 * Description  :   Test class for the InitiativeDispositionExtn class.
 *
 * Created By   :   Abhishek Tripathi
 *
 * Created Date :   9/14/2016
 */
@isTest(seeAllData=false)
public class InitiativeDispositionExtn_Test {

//unit test method
    static testMethod void testMethod1() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc1.Id;
        insert str;


        National_Initiative__c ni = new National_Initiative__c();
        ni.Strategy__c = str.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        National_Initiative__c ni1 = new National_Initiative__c();
        ni1.Strategy__c = str.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;


        Customer_Visit_Initiative_Relationship__c cvIR = new Customer_Visit_Initiative_Relationship__c();
        cvIR.National_Initiative__c = ni.Id;
        cvIR.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR1;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc1.Id;
        cc.Customer__c = acc.Id;
        insert cc;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        System.debug(':::' + controller.evnt);

        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createDisposition();

        controller.saveAndExit();

    }

    //unit test method
    static testMethod void testMethod12() {


    //What Id
        Customer_Visit__c cvm = new Customer_Visit__c();
        cvm.Name = 'Test 22';
        cvm.RecordTypeId = [Select Id From RecordType Where Name = 'Master' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cvm;

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
    cv.Master__c = cvm.Id;
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc1.Id;
        insert str;


        National_Initiative__c ni = new National_Initiative__c();
        ni.Strategy__c = str.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        National_Initiative__c ni1 = new National_Initiative__c();
        ni1.Strategy__c = str.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;


        Customer_Visit_Initiative_Relationship__c cvIR = new Customer_Visit_Initiative_Relationship__c();
        cvIR.National_Initiative__c = ni.Id;
        cvIR.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR1;

        Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
    nba.National_Initiative_Lookup__c = ni.Id;
    nba.Status__c = 'Allocated';
    nba.Client_Customer_Relationship__c = cc.Id;
    insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    nsba.Status__c = 'Unallocated';
    insert nsba;

    National_Banner_Allocation__c nba1 = new National_Banner_Allocation__c();
    nba1.National_Initiative_Lookup__c = ni.Id;
    nba1.Status__c = 'Allocated';
    nba1.Client_Customer_Relationship__c = cc.Id;
    insert nba1;

    National_Sub_Banner_Allocation__c nsba1 = new National_Sub_Banner_Allocation__c();
    nsba1.Client_Customer_Relationship__c = cc.Id;
    nsba1.National_Banner_Allocation__c = nba1.Id;
    nsba1.Status__c = 'Allocated';
    insert nsba1;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        System.debug(':::' + controller.evnt);

        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createDisposition();

        controller.saveAndExit();

    }

    //unit test method
    static testMethod void testMethod13() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;


        National_Initiative__c ni = new National_Initiative__c();
        ni.Strategy__c = str.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        National_Initiative__c ni1 = new National_Initiative__c();
        ni1.Strategy__c = str.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;


        Customer_Visit_Initiative_Relationship__c cvIR = new Customer_Visit_Initiative_Relationship__c();
        cvIR.National_Initiative__c = ni.Id;
        cvIR.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR1;


    National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
    nba.National_Initiative_Lookup__c = ni.Id;
    nba.Status__c = 'Allocated';
    nba.Client_Customer_Relationship__c = cc.Id;
    insert nba;

    National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.National_Banner_Allocation__c = nba.Id;
    nsba.Status__c = 'Unallocated';
    insert nsba;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        //System.debug(':::' + controller.idsNationalInitiative);

        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createDisposition();

        controller.saveAndExit();

    }


    //unit test method
    static testMethod void testMethod14() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

    //Customer Name record for Event
        Account acc0 = new Account();
        acc0.Name = 'Test acc';
        acc0.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc0;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc.Id;
        insert cc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

    National_Strategy__c str1 = new National_Strategy__c();
        str1.Client__c = acc0.Id;
        insert str1;


        National_Initiative__c ni = new National_Initiative__c();
        ni.Strategy__c = str.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        National_Initiative__c ni1 = new National_Initiative__c();
        ni1.Strategy__c = str1.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;


    National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
    nba.National_Initiative_Lookup__c = ni.Id;
    nba.Status__c = 'Unallocated';
    nba.Client_Customer_Relationship__c = cc.Id;
    insert nba;



        Customer_Visit_Initiative_Relationship__c cvIR = new Customer_Visit_Initiative_Relationship__c();
        cvIR.National_Initiative__c = ni.Id;
        cvIR.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR1;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        //System.debug(':::' + controller.idsNationalInitiative);

        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createDisposition();

        controller.saveAndExit();

    }

//unit test method
    static testMethod void testMethod15() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

    //Customer Name record for Event
        Account acc0 = new Account();
        acc0.Name = 'Test acc';
        acc0.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc0;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc.Id;
        insert cc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

    National_Strategy__c str1 = new National_Strategy__c();
        str1.Client__c = acc0.Id;
        insert str1;


        National_Initiative__c ni = new National_Initiative__c();
        ni.Strategy__c = str.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        National_Initiative__c ni1 = new National_Initiative__c();
        ni1.Strategy__c = str1.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;

        Customer_Visit_Initiative_Relationship__c cvIR = new Customer_Visit_Initiative_Relationship__c();
        cvIR.National_Initiative__c = ni.Id;
        cvIR.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        //cvIR.Local_Initiative__c = ;
        insert cvIR1;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        //System.debug(':::' + controller.idsNationalInitiative);

        controller.initDesposition.Overal_Status__c = 'In Progress';
    for(itemWrapper it : Controller.listOfItems) {

        it.cved.Status__c = 'Pending';
        it.cved.Pending_Reason__c = '';

    }
        controller.createDisposition();

        controller.saveAndExit();

    }

    //unit test method
    static testMethod void testMethod2() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc1.Id;
        insert str;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc1.Id;
        cc.Customer__c = acc.Id;
        insert cc;

    Local_Strategy__c lstr = new local_Strategy__c();
        lstr.National_Strategy__c = str.Id;
    lstr.Client_Customer_Relationship__c = cc.Id;
        insert lstr;

        Local_Initiative__c ni = new Local_Initiative__c();
        ni.Local_Strategy__c = lstr.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

        Local_Initiative__c ni1 = new Local_Initiative__c();
        ni1.Local_Strategy__c = lstr.Id;
        ni1.Objectives__c = 'Grow';
        ni1.Initiatives__c = 'Sales';
        insert ni1;

        Customer_Visit_Initiative_Relationship__c cvIR2 = new Customer_Visit_Initiative_Relationship__c();
        //cvIR2.National_Initiative__c = ni1.Id;
        cvIR2.Customer_Visit__c = cv.Id;
        cvIR2.Local_Initiative__c = ni1.Id;
        insert cvIR2;

        Customer_Visit_Initiative_Relationship__c cvIR1 = new Customer_Visit_Initiative_Relationship__c();
        //cvIR1.National_Initiative__c = ni1.Id;
        cvIR1.Customer_Visit__c = cv.Id;
        cvIR1.Local_Initiative__c = ni.Id;
        insert cvIR1;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;


        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

        controller.createBannerAndSubBannerForInitiative();
        System.debug(':::' + controller.evnt);

        controller.initDesposition.Overal_Status__c = 'In Progress';
    for(itemWrapper it : Controller.listOfItems) {

        it.cved.Status__c = 'Rejected';
        it.cved.Rejected_Reason__c = '';

    }

        controller.createDisposition();

        controller.saveAndExit();

    }

    //unit test method
    static testMethod void testMethod21() {

        //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

        National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc1.Id;
        insert str;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    Local_Strategy__c lstr = new local_Strategy__c();
        lstr.National_Strategy__c = str.Id;
    lstr.Client_Customer_Relationship__c = cc.Id;
        insert lstr;

        Local_Initiative__c ni = new Local_Initiative__c();
        ni.Local_Strategy__c = lstr.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

    Customer_Visit_Initiative_Relationship__c cvIR2 = new Customer_Visit_Initiative_Relationship__c();
        cvIR2.Customer_Visit__c = cv.Id;
        cvIR2.Local_Initiative__c = ni.Id;
        insert cvIR2;

        Local_Banner_Allocation__c nba = new Local_Banner_Allocation__c();
    nba.Local_Initiative__c = ni.Id;
    nba.Status__c = 'Allocated';
    nba.Client_Customer_Relationship__c = cc.Id;
    insert nba;

    Local_Sub_Banner_Allocation__c nsba = new Local_Sub_Banner_Allocation__c();
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.Local_Banner_Allocation__c = nba.Id;
    nsba.Status__c = 'Unallocated';
    insert nsba;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;

        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );
        controller.initDesposition.Overal_Status__c = Constant.STATUS_COMPLETED;

    for(itemWrapper it : Controller.listOfItems) {

        it.cved.Status__c = Constant.STATUS_ALLOCATED;
        it.cved.Customer_Code__c = '';
        //it.cved.Retail_Availability_Date__c  = date.today();

    }

    controller.createBannerAndSubBannerForInitiative();

        controller.createDisposition();
        controller.saveAndExit();

    }

    //unit test method
    static testMethod void testMethod22() {

         //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

    //Customer Name record for Event
        Account acc0 = new Account();
        acc0.Name = 'Test acc';
        acc0.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc0;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc.Id;
        insert cc1;

    National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

    National_Strategy__c str1 = new National_Strategy__c();
        str1.Client__c = acc0.Id;
        insert str1;

    Local_Strategy__c lstr = new local_Strategy__c();
        lstr.National_Strategy__c = str.Id;
    lstr.Client_Customer_Relationship__c = cc.Id;
        insert lstr;

        Local_Initiative__c ni = new Local_Initiative__c();
        ni.Local_Strategy__c = lstr.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

    Customer_Visit_Initiative_Relationship__c cvIR2 = new Customer_Visit_Initiative_Relationship__c();
        cvIR2.Customer_Visit__c = cv.Id;
        cvIR2.Local_Initiative__c = ni.Id;
        insert cvIR2;

        Local_Banner_Allocation__c nba = new Local_Banner_Allocation__c();
    nba.Local_Initiative__c = ni.Id;
    nba.Status__c = 'unallocated';
    nba.Client_Customer_Relationship__c = cc.Id;
    insert nba;

    Local_Sub_Banner_Allocation__c nsba = new Local_Sub_Banner_Allocation__c();
    nsba.Client_Customer_Relationship__c = cc.Id;
    nsba.Local_Banner_Allocation__c = nba.Id;
    nsba.Status__c = 'Unallocated';
    insert nsba;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
        tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;

        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );
        controller.createBannerAndSubBannerForInitiative();

    for(itemWrapper it : Controller.listOfItems) {

        it.cved.Status__c = 'Rejected';
        it.cved.Rejected_Reason__c = 'Other';
    }

        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createDisposition();
        controller.saveAndExit();
    }

    //unit test method
    static testMethod void testMethod23() {

         //What Id
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'Test';
        cv.RecordTypeId = [Select Id From RecordType Where Name = 'Refine' AND sObjectType = 'Customer_Visit__c'].Id;
        insert cv;

    //Customer Name record for Event
        Account acc0 = new Account();
        acc0.Name = 'Test acc';
        acc0.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc0;

        //Customer Name record for Event
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Banner - L4'].Id;
        insert acc;

        //Customer Name record for L4
        Account acc1 = new Account();
        acc1.Name = 'Test acc';
    acc1.ParentId = acc.Id;
        acc1.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Account' and Name = 'Customer - Sub Banner - L5'].Id;
        insert acc1;

    Client_Customer_Relationship__c cc = new Client_Customer_Relationship__c();
        cc.Client__c = acc.Id;
        cc.Customer__c = acc1.Id;
        insert cc;

    Client_Customer_Relationship__c cc1 = new Client_Customer_Relationship__c();
        cc1.Client__c = acc.Id;
        cc1.Customer__c = acc.Id;
        insert cc1;

    National_Strategy__c str = new National_Strategy__c();
        str.Client__c = acc.Id;
        insert str;

    National_Strategy__c str1 = new National_Strategy__c();
        str1.Client__c = acc0.Id;
        insert str1;

    Local_Strategy__c lstr = new local_Strategy__c();
        lstr.National_Strategy__c = str.Id;
    lstr.Client_Customer_Relationship__c = cc.Id;
        insert lstr;

        Local_Initiative__c ni = new Local_Initiative__c();
        ni.Local_Strategy__c = lstr.Id;
        ni.Objectives__c = 'Fix the Mix';
        ni.Initiatives__c = 'Assortment / Distribution';
        insert ni;

    Customer_Visit_Initiative_Relationship__c cvIR2 = new Customer_Visit_Initiative_Relationship__c();
        cvIR2.Customer_Visit__c = cv.Id;
        cvIR2.Local_Initiative__c = ni.Id;
        insert cvIR2;

        Event tsk = new Event();
        tsk.Description_Internal_Only__c = 'Test data';
        tsk.WhatId = cv.Id;
        tsk.StartDateTime = System.now();
    tsk.Customer_Name__c = acc1.Id;
        tsk.DurationInMinutes = 34;

        insert tsk;

        PageReference pageRef = Page.InitiativeDisposition;
        pageRef.getParameters().put('Id', tsk.id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(tsk);

        //Controller
        InitiativeDispositionExtn controller = new InitiativeDispositionExtn(sc );

    for(itemWrapper it : Controller.listOfItems) {

        it.cved.Status__c = 'Pending';
        //it.pendingCommnent = 'test';
        it.cved.Pending_Reason__c = 'Other';
    }


        controller.initDesposition.Overal_Status__c = 'In Progress';
        controller.createBannerAndSubBannerForInitiative();

        controller.createDisposition();



    controller.exit();
        //controller.saveAndExit();

    }
}