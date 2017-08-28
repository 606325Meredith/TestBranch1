/**************************************************************************************
Apex Class Name:  InitiativeRefineExtensionTest
Version     : 1.0 
Created Date    : 20 Sep 2016
Description    : Test class for the class InitiativeRefineExtension
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar            20 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class InitiativeRefineExtensionTest{
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Refine Extension : new record creation.
     */ 
    private static testMethod void IRInitTestNewRecTest() {
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
        Test.setCurrentPage(Page.InitiativeRefine);
        System.currentPageReference().getParameters().put('masterPlanId', initPlan.Id);   
        InitiativeRefineExtension con = new InitiativeRefineExtension(new ApexPages.StandardController(new Customer_Visit__c()));  

        con.custVisitInput.Start_Date__c = System.Today();
        con.custVisitInput.End_Date__c = System.Today() + 10;   
        con.custVisitInput.Name = 'test visit refine';         
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
        Test.startTest();
        con.showPopup();   
        System.assertEquals(10, con.listInitWrapperOffset.size());     
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listIniFiltrWrap){
            wrap.checked = true;
        } 
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listObjFiltrWrap){
            wrap.checked  = true;
        }  
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listBannerFiltrWrap){
            wrap.checked  = true;
        }
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listSBFiltrWrap){
            wrap.checked  = true;
        }  
        
        for(InitiativeRefineExtension.InitiativeWrapper wrap : con.listInitWrapper){
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

        System.assertNotEquals(null, con.initiativesSelected);      
        
        con.saveRefine();
        con.saveAndExitRefine();
        con.saveAndScheduleRefine();
        con.exit();               
    } 
    
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the Refine Extension : editing the existing refine record.
     */ 
    private static testMethod void IRInitTestExistingRecTest() {
        Customer_Visit__c initPlan = UtilityClassForTestDataSetUp.createInitiativePlan(); 
        initPlan.RecordTypeId = AcostaConstants.getIPRecordTypeId('Refine');
        Insert initPlan; 

        /*Customer_Visit__c initPlanmaster = UtilityClassForTestDataSetUp.createInitiativePlan(); 
        initPlan.RecordTypeId = AcostaConstants.getIPRecordTypeId('Master');
        initPlan.Name = 'Test Init Plan Master';
        initPlan.Start_Date__c = System.Today() + 1;
        initPlan.End_Date__c = System.Today() + 4;
        Insert initPlanMaster;*/
        
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
        
        //Create Initiative Plan Initiative Relationship records.
        List<Customer_Visit_Initiative_Relationship__c> listInitPlanInitRel = UtilityClassForTestDataSetUp.createInitiativePlanInitRelList(initPlan, listLI, listNI);     
        Insert listInitPlanInitRel;    
        
        // setup the page parameters and invoke the constructor
        Test.setCurrentPage(Page.InitiativeRefine);
        System.currentPageReference().getParameters().put('masterPlanId', initPlan.Id);
        System.currentPageReference().getParameters().put('refinePlanId', initPlan.Id);   
        InitiativeRefineExtension con = new InitiativeRefineExtension(new ApexPages.StandardController(new Customer_Visit__c()));  

        con.custVisitInput.Start_Date__c = System.Today();
        con.custVisitInput.End_Date__c = System.Today() + 10;   
        con.custVisitInput.Name = 'test visit refine';         
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
        Test.startTest();
        con.showPopup();   
        System.assertEquals(10, con.listInitWrapperOffset.size());     
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listIniFiltrWrap){
            wrap.checked = true;
        } 
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listObjFiltrWrap){
            wrap.checked  = true;
        }  
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listBannerFiltrWrap){
            wrap.checked  = true;
        }
        for(InitiativeRefineExtension.FilterWrapper wrap : con.listSBFiltrWrap){
            wrap.checked  = true;
        }  
        
        for(InitiativeRefineExtension.InitiativeWrapper wrap : con.listInitWrapper){
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
        con.getprev();
        con.getnxt();
        con.gettotalRecs();
        con.getPageNumber();               
    }     
}