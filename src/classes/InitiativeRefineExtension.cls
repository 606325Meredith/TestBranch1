/**************************************************************************************
Apex Class Name:  InitiativeRefineExtension
Version     : 1.0
Created Date    : 25 Jul 2016
Description    : Controller class for the Initiative plan visit page. User will select multiple Clients/ Customers/ Initiatives/ Account Team Members to create a customer visit.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Yashmith Kumar        25 Jul 2016             Original Version
*************************************************************************************/
public without sharing class InitiativeRefineExtension{
    //varibales for Initiative selection
    public String initiativesSelected{get;set;}
    public Set<String> initiativesSelectedName{get;set;}
    Map<id,String> mapSelectedInitiatives;
    Map<id,String> mapSelectedInitObjectives;
    Set<Id> setSelectedInitiatives;
    String subBannerQueryNational;
    String initQueryNational;
    String subBannerQueryLocal;
    String initQueryLocal;
    public List<InitiativeWrapper> listInitWrapper;
    public List<InitiativeWrapper> listInitWrapperSelected;
    public List<InitiativeWrapper> listInitWrapperOffset{get;set;}
    public List<FilterWrapper> listIniFiltrWrap{get;set;}
    public List<FilterWrapper> listIniFiltrWrapAll;
    public List<FilterWrapper> listObjFiltrWrap{get;set;}
    public List<FilterWrapper> listObjFiltrWrapAll;
    public List<FilterWrapper> listObjFiltrWrapFiltered;
    public List<FilterWrapper> listBannerFiltrWrap{get;set;}
    public List<FilterWrapper> listBannerFiltrWrapAll;
    public List<FilterWrapper> listSBFiltrWrap{get;set;}
    public List<FilterWrapper> listSBFiltrWrapAll;
    public List<FilterWrapper> listSBFiltrWrapFiltered;
    public List<FilterWrapper> listBonusFiltrWrap{get;set;}
    public List<FilterWrapper> listPriorityFiltrWrap{get;set;}
    public List<FilterWrapper> listAllocationFiltrWrap{get;set;}
    Set<String> setSelectedInitiativesFiltr;
    Set<String> setSelectedObjectivesFiltr;
    Set<String> setSelectedBannerFiltr;
    Set<String> setSelectedSubBannerFiltr;
    Set<String> setSelectedBonusFiltr;
    Set<String> setSelectedPriorityFiltr;
    Set<String> setSelectedAllocationFiltr;
    Public Set<String> showSelectedInitiativesFiltr{get;set;}
    Public Set<String> showSelectedObjectivesFiltr{get;set;}
    Public Set<String> showSelectedBannerFiltr{get;set;}
    Public Set<String> showSelectedSubBannerFiltr{get;set;}
    Public Set<String> showSelectedBonusFiltr{get;set;}
    Public Set<String> showSelectedPriorityFiltr{get;set;}
    Public Set<String> showSelectedAllocationFiltr{get;set;}
    public Set<Id> setNIId;
    public Set<Id> setLIId;
    public Set<Id> setNBAId;
    public Set<Id> setLBAId;
    public Set<Id> setNSBAId;
    public Set<Id> setLSBAId;
    Set<Id> setMasterNIId;
    Set<Id> setMasterLIId;

    //variables for pagination
    public integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize= Integer.valueOf(System.Label.Page_Limit_For_Selector);
    public Integer totalPages{get;set;}
    public Integer page{get;set;}

    // generic variables
    public Customer_Visit__c custVisit;
    public Customer_Visit__c custVisitInput{get;set;}
    public Boolean isSaved{get;set;}
    public Id refinePlanId;
    Boolean showSelected = false;
    Set<Id> setSelectedClients;
    Map<id,String> mapSelectedClients;
    Set<Id> setSelectedCustomers;
    Set<Id> setAdditionalL4L5Customers;
    Map<id,String> mapSelectedCustomers;
    Set<Id> setSelectedInitiativesMaster;
    Id masterPlanId;
    Map<Id,String> mapCustomerType = new Map<Id,String>();
    Map<Id,Set<Id>> mapClientCustL4 = new Map<Id,Set<Id>>();
    Map<Id,Set<Id>> mapClientCustL5 = new Map<Id,Set<Id>>();
    Set<Id> setCCId = new Set<Id>();
    Map<String,Id> mapInitClientCustL4Local = new Map<String,Id>();
    Map<String,Id> mapInitClientCustL5Local = new Map<String,Id>();
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : public constructor
     */
    public InitiativeRefineExtension(ApexPages.StandardController con){
        try{
        isSaved = false;
        custVisitInput = new Customer_Visit__c();
        mapSelectedClients = new Map<Id,String>();
        setSelectedClients = new Set<Id>();
        mapSelectedCustomers = new Map<Id,String>();
        setSelectedCustomers = new Set<Id>();
        setAdditionalL4L5Customers = new Set<Id>();
        setSelectedInitiatives = new Set<Id>();
        mapSelectedInitiatives = new Map<Id,String>();
        initiativesSelected = '';
        setNIId = new Set<Id>();
        setLIId = new Set<Id>();
        setNBAId = new Set<Id>();
        setLBAId = new Set<Id>();
        setNSBAId = new Set<Id>();
        setLSBAId = new Set<Id>();
        setMasterNIId = new Set<Id>();
        setMasterLIId = new Set<Id>();

        // Get the master plan id
        if(ApexPages.currentPage().getParameters().get('masterPlanId') != null){
            masterPlanId = ApexPages.currentPage().getParameters().get('masterPlanId');
            // Pull the existing Account Relationship records.
            for(Customer_Visit_Account_Relationship__c cvar : [Select Account__c, Account__r.Name, Account__r.RecordType.Name from Customer_Visit_Account_Relationship__c where Customer_Visit__c =: masterPlanId]){
                if(cvar.Account__r.RecordType.Name.equalsIgnoreCase(AcostaConstants.L3ClientType) || cvar.Account__r.RecordType.Name.equalsIgnoreCase(AcostaConstants.L4ClientType)){
                    setSelectedClients.add(cvar.Account__c);
                    mapSelectedClients.put(cvar.Account__c, cvar.Account__r.Name);
                }
                else{
                    setSelectedCustomers.add(cvar.Account__c);
                    mapSelectedCustomers.put(cvar.Account__c, cvar.Account__r.Name);
                    mapCustomerType.put(cvar.Account__c,cvar.Account__r.RecordType.Name);
                }
            }
            // Pull the master Initiative Relation records.
            for(Customer_Visit_Initiative_Relationship__c  cvir : [Select Local_Initiative__c,Local_Initiative__r.Name, National_Initiative__c, National_Initiative__r.Name from Customer_Visit_Initiative_Relationship__c where Customer_Visit__c =: masterPlanId]){
                if(cvir.National_Initiative__c != null){
                    setMasterNIId.add(cvir.National_Initiative__c);
                }
                else{
                    setMasterLIId.add(cvir.Local_Initiative__c);
                }
            }

            // Pull the additional customers from L4 / L5. This is required for the Local Initiative display criteria.
            for(Account acc : [Select ParentId,RecordType.Name, (Select Id from ChildAccounts) from Account where Id in : setSelectedCustomers]){
                if(acc.RecordType.Name != null && acc.RecordType.Name.equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                    for(Account account : acc.ChildAccounts){
                        setAdditionalL4L5Customers.add(account.Id);
                    }
                }
                else{
                    setAdditionalL4L5Customers.add(acc.ParentId);
                }
            }

            mapClientCustL4.clear();
            mapClientCustL5.clear();
            // Loop through the CC records, which are resulting based on the Client / Customer selection and construct a map to identify the unallocated Initiatives.
            for(Client_Customer_Relationship__c CC : [Select Id, Name, Client__c, Customer__c from Client_Customer_Relationship__c where Client__c in : setSelectedClients AND (Customer__c in : setSelectedCustomers OR Customer__c in : setAdditionalL4L5Customers)]){
                if(setSelectedClients.contains(cc.Client__c) && (setSelectedCustomers.contains(cc.Customer__c) || setAdditionalL4L5Customers.contains(cc.Customer__c))){
                    setCCId.add(cc.Id);
                    if(!setAdditionalL4L5Customers.contains(cc.Customer__c) || setSelectedCustomers.contains(cc.Customer__c)){
                    if(mapCustomerType.get(cc.Customer__c) != null && mapCustomerType.get(cc.Customer__c).equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                        if(mapClientCustL4.containsKey(cc.Client__c)){
                            mapClientCustL4.get(cc.Client__c).add(cc.Customer__c);
                        }
                        else{
                            mapClientCustL4.put(cc.Client__c, new Set<Id>{cc.Customer__c});
                        }
                    }
                    else{
                        if(mapClientCustL5.containsKey(cc.Client__c)){
                             mapClientCustL5.get(cc.Client__c).add(cc.Customer__c);
                        }
                        else{
                            mapClientCustL5.put(cc.Client__c, new Set<Id>{cc.Customer__c});
                        }
                    }
                    }
                }
            }
        }

        // Check if user is editing the existing record.
        if(ApexPages.currentPage().getParameters().get('refinePlanId') != null){
            refinePlanId = ApexPages.currentPage().getParameters().get('refinePlanId');
            Customer_Visit__c refinePlanExisting = [Select Name, Start_Date__c, End_Date__c from Customer_Visit__c where Id =: refinePlanId];
            custVisit = refinePlanExisting;
            custVisitInput.Name = refinePlanExisting.Name;
            custVisitInput.Start_Date__c = refinePlanExisting.Start_Date__c;
            custVisitInput.End_Date__c = refinePlanExisting.End_Date__c;
            for(Customer_Visit_Initiative_Relationship__c  cvir : [Select Local_Initiative__c,Local_Initiative__r.Name, National_Initiative__c, National_Initiative__r.Name from Customer_Visit_Initiative_Relationship__c where Customer_Visit__c =: refinePlanId]){
                if(cvir.National_Initiative__c != null){
                    setSelectedInitiatives.add(cvir.National_Initiative__c);
                    mapSelectedInitiatives.put(cvir.National_Initiative__c, cvir.National_Initiative__r.Name);
                    initiativesSelected += cvir.National_Initiative__r.Name +' | ';
                }
                else{
                    setSelectedInitiatives.add(cvir.Local_Initiative__c);
                    mapSelectedInitiatives.put(cvir.Local_Initiative__c, cvir.Local_Initiative__r.Name);
                    initiativesSelected += cvir.Local_Initiative__r.Name +' | ';
                }
            }
            initiativesSelected = (mapSelectedInitiatives.size() == 0 ?'':initiativesSelected.substring(0,initiativesSelected.length() -1));
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }


//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to search for the Initiatives
     */
    public void searchInitiative(){
        showSelectedInitiativesFiltr = new Set<String>();
        showSelectedObjectivesFiltr = new Set<String>();
        showSelectedBannerFiltr = new Set<String>();
        showSelectedSubBannerFiltr = new Set<String>();
        showSelectedBonusFiltr = new Set<String>();
        showSelectedPriorityFiltr = new Set<String>();
        showSelectedAllocationFiltr = new Set<String>();

        try{
        Date startDate=custVisitInput.Start_Date__c;
        Date endDate=custVisitInput.End_Date__c;
        if(setCCId.size() > 0 && startDate != null && endDate != null){
            initQueryNational = 'Select Name, Initiatives__c, Objectives__c,Strategy__r.Client__c,Strategy__r.Client__r.Name, Product_SKU__c, Product_Group__c, Brand__c, Target__c, Unit_of_Measure__c, Bonus_Eligibility__c, Comments__c, Priority__c, (Select National_Banner_Allocation_Name__c, Status__c, Allocated_non_Editable__c,Client_Customer_Relationship__r.Customer__c from National_Banner_Allocations1__r where Client_Customer_Relationship__c in : setCCId';
            initQueryLocal = 'Select Name, Initiatives__c, Objectives__c,Local_Strategy__r.Client_Customer_Relationship__r.Client__c,  Local_Strategy__r.Client_Customer_Relationship__r.Customer__c, Local_Strategy__r.Client_Customer_Relationship__r.Client__r.Name, Product_SKU__c, Product_Group__c, Brand__c, Target__c, Unit_of_Measure__c, Bonus_Eligibility__c, Comments__c, Priority__c, (Select Local_Banner_Allocation_Name__c, Status__c, Allocated_Target__c, Client_Customer_Relationship__r.Customer__c, Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c from Local_Banner_Allocations__r where Client_Customer_Relationship__c in : setCCId';
            setSelectedBannerFiltr = new Set<String>();
            for(FilterWrapper wrap : listBannerFiltrWrap){
                if(wrap.checked){
                    setSelectedBannerFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedBannerFiltr.size() >0){
                initQueryNational+= ' AND National_Banner_Allocation_Name__c in : setSelectedBannerFiltr';
                initQueryLocal+=' AND Local_Banner_Allocation_Name__c in : setSelectedBannerFiltr';
                showSelectedBannerFiltr = setSelectedBannerFiltr;
            }
            if (showSelectedBannerFiltr.isEmpty()) showSelectedBannerFiltr.add('No Values Selected');

            initQueryNational += ')from National_Initiative__c where Id in : setMasterNIId AND Initiative_Start_Date__c != NULL AND Initiative_End_Date__c != NULL AND (NOT (Initiative_Start_Date__c >:endDate OR Initiative_End_Date__c <:startDate))';
            initQueryLocal += ')from Local_Initiative__c where Id in : setMasterLIId AND Initiative_Start_Date__c != NULL AND Initiative_End_Date__c != NULL AND (NOT (Initiative_Start_Date__c >:endDate OR Initiative_End_Date__c <:startDate))';

            setSelectedInitiativesFiltr = new Set<String>();
            for(FilterWrapper wrap : listIniFiltrWrap){
                if(wrap.checked){
                    setSelectedInitiativesFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedInitiativesFiltr.size() >0){
                initQueryNational+= ' AND Initiatives__c in : setSelectedInitiativesFiltr';
                initQueryLocal+=' AND Initiatives__c in : setSelectedInitiativesFiltr';
                showSelectedInitiativesFiltr = setSelectedInitiativesFiltr;
            }
            if (showSelectedInitiativesFiltr.isEmpty()) showSelectedInitiativesFiltr.add('No Values Selected');

            setSelectedObjectivesFiltr = new Set<String>();
            for(FilterWrapper wrap : listObjFiltrWrap){
                if(wrap.checked){
                    setSelectedObjectivesFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedObjectivesFiltr.size() >0){
                initQueryNational+= ' AND Objectives__c in : setSelectedObjectivesFiltr';
                initQueryLocal+=' AND Objectives__c in : setSelectedObjectivesFiltr';
                showSelectedObjectivesFiltr = setSelectedObjectivesFiltr;
            }
            if (showSelectedObjectivesFiltr.isEmpty()) showSelectedObjectivesFiltr.add('No Values Selected');

            setSelectedBonusFiltr = new Set<String>();
            Set<Boolean> setSelectedBonusFiltrBool = new Set<Boolean>();
            for(FilterWrapper wrap : listBonusFiltrWrap){
                if(wrap.checked){
                    setSelectedBonusFiltr.add(wrap.filtrValue);
                    if(wrap.filtrValue.equalsIgnoreCase('true')){
                        setSelectedBonusFiltrBool.add(true);
                        showSelectedBonusFiltr.add('Yes');
                    }
                    else{
                        setSelectedBonusFiltrBool.add(false);
                        showSelectedBonusFiltr.add('No');
                    }
                }
            }
            if(setSelectedBonusFiltr.size() >0){
                initQueryNational+= ' AND Bonus_Eligibility__c in : setSelectedBonusFiltrBool';
                initQueryLocal+=' AND Bonus_Eligibility__c in : setSelectedBonusFiltrBool';
                //showSelectedBonusFiltr = setSelectedBonusFiltr;
            }
            if (showSelectedBonusFiltr.isEmpty()) showSelectedBonusFiltr.add('No Values Selected');

            setSelectedPriorityFiltr = new Set<String>();
            for(FilterWrapper wrap : listPriorityFiltrWrap){
                if(wrap.checked){
                    setSelectedPriorityFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedPriorityFiltr.size() >0){
                initQueryNational+= ' AND Priority__c in : setSelectedPriorityFiltr';
                initQueryLocal+=' AND Priority__c in : setSelectedPriorityFiltr';
                showSelectedPriorityFiltr = setSelectedPriorityFiltr;
            }
            if (showSelectedPriorityFiltr.isEmpty()) showSelectedPriorityFiltr.add('No Values Selected');

            setSelectedAllocationFiltr = new Set<String>();
            for(FilterWrapper wrap : listAllocationFiltrWrap){
                if(wrap.checked){
                    setSelectedAllocationFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedAllocationFiltr.size() > 0) {
                showSelectedAllocationFiltr = setSelectedAllocationFiltr;
            }
            if (showSelectedAllocationFiltr.isEmpty()) showSelectedAllocationFiltr.add('No Values Selected');

            Map<Id, National_Initiative__c> mapNI = new Map<Id,National_Initiative__c>((List<National_Initiative__c>)Database.query(initQueryNational));
            Set<Id> setNIIdAll = mapNI.keySet();
            Map<Id, Local_Initiative__c> mapLI = new Map<Id, Local_Initiative__c>((List<Local_Initiative__c>)Database.query(initQueryLocal));
            Set<Id> setLIIdAll = mapLI.keySet();
            subBannerQueryNational = 'Select National_Sub_Banner_Allocation_Name__c, National_Banner_Allocation__r.National_Banner_Allocation_Name__c, Status__c, National_Banner_Allocation__r.Name, National_Banner_Allocation__r.National_Initiative_Lookup__r.Name, National_Banner_Allocation__r.National_Initiative_Lookup__r.Initiatives__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Objectives__c, Client_Customer_Relationship__r.Client__c, Client_Customer_Relationship__r.Client__r.Name, National_Banner_Allocation__r.National_Initiative_Lookup__r.Strategy__r.Client__r.Name, Client_Customer_Relationship__r.Customer__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Product_SKU__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Product_Group__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Brand__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Target__c, Allocated_Target__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Unit_of_Measure__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Bonus_Eligibility__c, National_Banner_Allocation__r.National_Initiative_Lookup__r.Comments__c from National_Sub_Banner_Allocation__c where National_Banner_Allocation__r.National_Initiative_Lookup__c in : setNiIdAll AND Client_Customer_Relationship__c in : setCCId';
            subBannerQueryLocal = 'Select Local_Sub_Banner_Allocation_Name__c, Local_Banner_Allocation__r.Local_Banner_Allocation_Name__c, Status__c, Local_Banner_Allocation__r.Name, Local_Banner_Allocation__r.Local_Initiative__r.Name, Local_Banner_Allocation__r.Local_Initiative__r.Initiatives__c, Local_Banner_Allocation__r.Local_Initiative__r.Objectives__c, Client_Customer_Relationship__r.Client__c, Client_Customer_Relationship__r.Client__r.Name, Local_Banner_Allocation__r.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Client__r.Name, Client_Customer_Relationship__r.Customer__c, Local_Banner_Allocation__r.Local_Initiative__r.Product_SKU__c, Local_Banner_Allocation__r.Local_Initiative__r.Product_Group__c, Local_Banner_Allocation__r.Local_Initiative__r.Brand__c, Local_Banner_Allocation__r.Local_Initiative__r.Target__c, Allocated_Traget__c, Local_Banner_Allocation__r.Local_Initiative__r.Unit_of_Measure__c, Local_Banner_Allocation__r.Local_Initiative__r.Bonus_Eligibility__c, Local_Banner_Allocation__r.Local_Initiative__r.Comments__c, Local_Banner_Allocation__r.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c from Local_Sub_Banner_Allocation__c where Local_Banner_Allocation__r.Local_Initiative__c in : setLIIdAll AND Client_Customer_Relationship__c in : setCCId';
            setSelectedSubBannerFiltr = new Set<String>();
            for(FilterWrapper wrap : listSBFiltrWrap){
                if(wrap.checked){
                    setSelectedSubBannerFiltr.add(wrap.filtrValue);
                }
            }
            if(setSelectedSubBannerFiltr.size() >0){
                subBannerQueryNational+= ' AND National_Sub_Banner_Allocation_Name__c in : setSelectedSubBannerFiltr';
                subBannerQueryLocal+=' AND Local_Sub_Banner_Allocation_Name__c in : setSelectedSubBannerFiltr';
                showSelectedSubBannerFiltr = setSelectedSubBannerFiltr;
            }
            if (showSelectedSubBannerFiltr.isEmpty()) showSelectedSubBannerFiltr.add('No Values Selected');

            List<National_Sub_Banner_Allocation__c> listNSBA = Database.query(subBannerQueryNational);
            List<Local_Sub_Banner_Allocation__c> listLSBA = Database.query(subBannerQueryLocal);
            Map<Id, List<National_Sub_Banner_Allocation__c>> mapNINSBA = new Map<Id, List<National_Sub_Banner_Allocation__c>>();
            Map<Id, List<Local_Sub_Banner_Allocation__c>> mapLILSBA = new Map<Id, List<Local_Sub_Banner_Allocation__c>>();

            // Construct a map of National Initiative and National Banner Allocation
            for(National_Sub_Banner_Allocation__c nsba : listNSBA){
                if(mapNINSBA.containsKey(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c)){
                    mapNINSBA.get(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c).add(nsba);
                }
                else{
                    mapNINSBA.put(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c, new List<National_Sub_Banner_Allocation__c>{nsba});
                }
            }
            //Construct a map of Local Initiative and Local Sub Banner Allocation
            for(Local_Sub_Banner_Allocation__c lsba : listLSBA){
                if(mapLILSBA.containsKey(lsba.Local_Banner_Allocation__r.Local_Initiative__c)){
                    mapLILSBA.get(lsba.Local_Banner_Allocation__r.Local_Initiative__c).add(lsba);
                }
                else{
                    mapLILSBA.put(lsba.Local_Banner_Allocation__r.Local_Initiative__c, new List<Local_Sub_Banner_Allocation__c>{lsba});
                }
            }
            listInitWrapper = new List<InitiativeWrapper>();
            Map<String, InitiativeWrapper> mapInitWrapperAllocated = new Map<String, InitiativeWrapper>();
            Map<String, InitiativeWrapper> mapInitWrapperUnAllocated = new Map<String, InitiativeWrapper>();

            // Loop through National Initiative and capture allocated / unallocated Initiatives for Banner
            for(National_Initiative__c ni : mapNI.values()){
                Boolean unAllocated = false;
                Set<Id> setCustId = new Set<Id>();
                for(National_Banner_Allocation__c nba : ni.National_Banner_Allocations1__r){
                    if(nba.Status__c != null && nba.Status__c.equalsIgnoreCase(AcostaConstants.StatusAllocated) && setSelectedCustomers.contains(nba.Client_Customer_Relationship__r.Customer__c)){
                        InitiativeWrapper wrap = initWrapNI(ni);
                        wrap.Id = String.valueOf(ni.Id)+String.valueOf(nba.Id);
                        wrap.banner = nba.National_Banner_Allocation_Name__c;
                        wrap.target = nba.Allocated_non_Editable__c;
                        mapInitWrapperAllocated.put(wrap.Id,wrap);
                        setNBAId.add(nba.Id);
                        setNIId.add(ni.Id);
                    }
                    else if((nba.Status__c != null && (nba.Status__c.equals(AcostaConstants.StatusUnAllocated) || nba.Status__c.equals(AcostaConstants.StatusNew))) && setSelectedCustomers.contains(nba.Client_Customer_Relationship__r.Customer__c)){
                        mapInitWrapperUnAllocated.put(initWrapNI(ni).Id,initWrapNI(ni));
                        setNIId.add(ni.Id);
                    }
                    setCustId.add(nba.Client_Customer_Relationship__r.Customer__c);
                }
                if(ni.Strategy__r.Client__c != null && mapClientCustL4.get(ni.Strategy__r.Client__c) != null){
                    for(Id custId : mapClientCustL4.get(ni.Strategy__r.Client__c)){
                        if(!setCustId.contains(custId) && !setAdditionalL4L5Customers.contains(custId)){
                            unAllocated = true;
                        }
                    }
                }
                if(unAllocated){
                    mapInitWrapperUnAllocated.put(initWrapNI(ni).Id,initWrapNI(ni));
                    setNIId.add(ni.Id);
                }
                if(ni.National_Banner_Allocations1__r.size()  == 0 && mapClientCustL4.get(ni.Strategy__r.Client__c) != null){
                    mapInitWrapperUnAllocated.put(initWrapNI(ni).Id,initWrapNI(ni));
                    setNIId.add(ni.Id);
                }
            }

            // Loop through Local Initiative and capture allocated / unallocated Initiatives for Banner
            for(Local_Initiative__c li : mapLI.values()){
                Boolean unAllocated = false;
                Set<Id> setCustId = new Set<Id>();
                if(mapCustomerType.get(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c) != null && mapCustomerType.get(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                    mapInitClientCustL4Local.put(String.valueOf(li.Id) + String.valueOf(li.Local_Strategy__r.Client_Customer_Relationship__r.Client__c), li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c);
                }
                for(Local_Banner_Allocation__c lba : li.Local_Banner_Allocations__r){
                    if(lba.Status__c != null && lba.Status__c.equalsIgnoreCase(AcostaConstants.StatusAllocated) && setSelectedCustomers.contains(lba.Client_Customer_Relationship__r.Customer__c)){
                        InitiativeWrapper wrap = initWrapLI(li);
                        wrap.Id = String.valueOf(li.Id)+String.valueOf(lba.Id);
                        wrap.banner = lba.Local_Banner_Allocation_Name__c;
                        wrap.target = lba.Allocated_Target__c;
                        mapInitWrapperAllocated.put(wrap.Id,wrap);
                        setLBAId.add(lba.Id);
                        setLIId.add(li.Id);
                    }
                    else if((lba.Status__c != null && (lba.Status__c.equals(AcostaConstants.StatusUnAllocated) || lba.Status__c.equals(AcostaConstants.StatusNew))) && setSelectedCustomers.contains(lba.Client_Customer_Relationship__r.Customer__c) && setSelectedCustomers.contains(lba.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c) && mapCustomerType.get(lba.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                        InitiativeWrapper wrap = initWrapLI(li);
                        mapInitWrapperUnAllocated.put(wrap.Id,wrap);
                        setLIId.add(li.Id);
                    }
                    setCustId.add(lba.Client_Customer_Relationship__r.Customer__c);
                }
                if(li.Local_Strategy__r.Client_Customer_Relationship__r.Client__c != null && mapInitClientCustL4Local.get(li.Local_Strategy__r.Client_Customer_Relationship__r.Client__c) != null && setSelectedCustomers.contains(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c)  && mapCustomerType.get(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                    if(!setCustId.contains(mapInitClientCustL4Local.get(String.valueOf(li.Id) + String.valueOf(li.Local_Strategy__r.Client_Customer_Relationship__r.Client__c)))){
                        unAllocated = true;
                    }
                }
                if(unAllocated){
                    InitiativeWrapper wrap = initWrapLI(li);
                    mapInitWrapperUnAllocated.put(wrap.Id,wrap);
                    setLIId.add(li.Id);
                }

                if(li.Local_Banner_Allocations__r.size() == 0 && mapInitClientCustL4Local.get(String.valueOf(li.Id) + String.valueOf(li.Local_Strategy__r.Client_Customer_Relationship__r.Client__c)) != null && setSelectedCustomers.contains(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c)  && mapCustomerType.get(li.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L4CustomerType)){
                    InitiativeWrapper wrap = initWrapLI(li);
                    mapInitWrapperUnAllocated.put(wrap.Id,wrap);
                    setLIId.add(li.Id);
                }
            }

            // Loop through National Initiative and capture allocated / unallocated Initiatives for Sub Banner.
            for(Id idNI : mapNI.keySet()){
                Boolean unAllocated = false;
                Set<Id> setCustId = new Set<Id>();
                if(mapNINSBA.get(idNI) != null){
                    for(National_Sub_Banner_Allocation__c nsba : mapNINSBA.get(idNI)){
                        if(nsba.Status__c != null && nsba.Status__c.equalsIgnoreCase(AcostaConstants.StatusAllocated) && setSelectedCustomers.contains(nsba.Client_Customer_Relationship__r.Customer__c)){
                            /*if(mapInitWrapperAllocated.containsKey(String.valueOf(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c)+String.valueOf(nsba.National_Banner_Allocation__c))){
                                mapInitWrapperAllocated.remove(String.valueOf(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c)+String.valueOf(nsba.National_Banner_Allocation__c));
                            }*/
                            InitiativeWrapper wrap = initWrapNSBA(nsba);
                            wrap.Id = String.valueOf(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Id)+String.valueOf(nsba.National_Banner_Allocation__r.Id)+String.valueOf(nsba.Id);
                            wrap.banner = nsba.National_Banner_Allocation__r.National_Banner_Allocation_Name__c;
                            wrap.subBanner = nsba.National_Sub_Banner_Allocation_Name__c;
                            wrap.target = nsba.Allocated_Target__c;
                            mapInitWrapperAllocated.put(wrap.Id,wrap);
                            setNSBAId.add(nsba.Id);
                            setNIId.add(initWrapNSBA(nsba).Id);
                        }
                        else if((nsba.Status__c != null && (nsba.Status__c.equals(AcostaConstants.StatusUnAllocated) || nsba.Status__c.equals(AcostaConstants.StatusNew))) && setSelectedCustomers.contains(nsba.Client_Customer_Relationship__r.Customer__c) && !mapInitWrapperUnAllocated.containsKey(nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Id)){
                            mapInitWrapperUnAllocated.put(initWrapNSBA(nsba).Id, initWrapNSBA(nsba));
                            setNIId.add(initWrapNSBA(nsba).Id);
                        }
                        setCustId.add(nsba.Client_Customer_Relationship__r.Customer__c);
                    }
                }

                if(mapNI.get(idNI).Strategy__r.Client__c != null && mapClientCustL5.get(mapNI.get(idNI).Strategy__r.Client__c) != null){
                    for(Id custId : mapClientCustL5.get(mapNI.get(idNI).Strategy__r.Client__c)){
                        if(!setCustId.contains(custId) && !setAdditionalL4L5Customers.contains(custId)){
                            unAllocated = true;
                        }
                    }
                }
                if(unAllocated){
                    mapInitWrapperUnAllocated.put(initWrapNI(mapNI.get(idNI)).Id,initWrapNI(mapNI.get(idNI)));
                    setNIId.add(idNI);
                }

                if(mapNINSBA.get(idNI)  == null && mapClientCustL5.get(mapNI.get(idNI).Strategy__r.Client__c) != null){
                    mapInitWrapperUnAllocated.put(initWrapNI(mapNI.get(idNI)).Id,initWrapNI(mapNI.get(idNI)));
                    setNIId.add(idNI);
                }

            }

            // Loop through Local Initiative and capture allocated / unallocated Initiatives for Sub Banner.
            for(Id idLI : mapLI.keySet()){
                Boolean unAllocated = false;
                Set<Id> setCustId = new Set<Id>();
                if(mapCustomerType.get(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c) != null && mapCustomerType.get(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L5CustomerType)){
                    Id custIdLI = mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c;
                    mapInitClientCustL5Local.put(String.valueOf(idLI) + String.valueOf(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Client__c), custIdLI);
                }
                if(mapLILSBA.get(idLI) != null){
                    for(Local_Sub_Banner_Allocation__c lsba : mapLILSBA.get(idLI)){
                        if(lsba.Status__c != null &&  lsba.Status__c.equalsIgnoreCase(AcostaConstants.StatusAllocated) && setSelectedCustomers.contains(lsba.Client_Customer_Relationship__r.Customer__c)){
                            /*if(mapInitWrapperAllocated.containsKey(String.valueOf(lsba.Local_Banner_Allocation__r.Local_Initiative__c)+String.valueOf(lsba.Local_Banner_Allocation__c))){
                                mapInitWrapperAllocated.remove(String.valueOf(lsba.Local_Banner_Allocation__r.Local_Initiative__c)+String.valueOf(lsba.Local_Banner_Allocation__c));
                            }*/
                            InitiativeWrapper wrap = initWrapLSBA(lsba);
                            wrap.Id = String.valueOf(lsba.Local_Banner_Allocation__r.Local_Initiative__r.Id)+String.valueOf(lsba.Local_Banner_Allocation__r.Id)+String.valueOf(lsba.Id);
                            wrap.banner = lsba.Local_Banner_Allocation__r.Local_Banner_Allocation_Name__c;
                            wrap.subBanner = lsba.Local_Sub_Banner_Allocation_Name__c ;
                            wrap.target = lsba.Allocated_Traget__c;
                            mapInitWrapperAllocated.put(wrap.Id,wrap);
                            setLSBAId.add(lsba.Id);
                            setLIId.add(initWrapLSBA(lsba).Id);
                        }
                        else if((lsba.Status__c != null && (lsba.Status__c.equals(AcostaConstants.StatusUnAllocated) || lsba.Status__c.equals(AcostaConstants.StatusNew))) && setSelectedCustomers.contains(lsba.Client_Customer_Relationship__r.Customer__c) && !mapInitWrapperUnAllocated.containsKey(lsba.Local_Banner_Allocation__r.Local_Initiative__r.Id) && setSelectedCustomers.contains(lsba.Local_Banner_Allocation__r.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c)  && mapCustomerType.get(lsba.Local_Banner_Allocation__r.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L5CustomerType)){
                            InitiativeWrapper wrap = initWrapLSBA(lsba);
                            mapInitWrapperUnAllocated.put(wrap.Id, wrap);
                            setLIId.add(initWrapLSBA(lsba).Id);
                        }
                        setCustId.add(lsba.Client_Customer_Relationship__r.Customer__c);
                    }
                }

                if(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Client__c != null && mapInitClientCustL5Local.get(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Client__c) != null && setSelectedCustomers.contains(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c)  && mapCustomerType.get(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L5CustomerType)){
                    if(!setCustId.contains(mapInitClientCustL5Local.get(String.valueOf(idLI) + String.valueOf(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Client__c)))){
                        unAllocated = true;
                    }
                }

                if(unAllocated){
                    InitiativeWrapper wrap = initWrapLI(mapLI.get(idLI));
                    mapInitWrapperUnAllocated.put(wrap.Id,wrap);
                    setLIId.add(idLI);
                }

                if(mapLILSBA.get(idLI) == null && mapInitClientCustL5Local.get(String.valueOf(idLI) + String.valueOf(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Client__c)) != null && setSelectedCustomers.contains(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c)  && mapCustomerType.get(mapLI.get(idLI).Local_Strategy__r.Client_Customer_Relationship__r.Customer__c).equalsIgnoreCase(AcostaConstants.L5CustomerType)){
                    InitiativeWrapper wrap = initWrapLI(mapLI.get(idLI));
                    mapInitWrapperUnAllocated.put(wrap.Id,wrap);
                    setLIId.add(idLI);
                }
            }

            if(mapInitWrapperAllocated.values().size()>0 && (setSelectedAllocationFiltr.size() == 0 || (setSelectedAllocationFiltr.size() > 0 && setSelectedAllocationFiltr.contains(AcostaConstants.StatusAllocated)))){
                listInitWrapper.addAll(new List<InitiativeWrapper>(mapInitWrapperAllocated.values()));
            }
            if(mapInitWrapperUnAllocated.values().size()>0 && setSelectedSubBannerFiltr.size() == 0 && setSelectedBannerFiltr.size() == 0  && (setSelectedAllocationFiltr.size() == 0 || (setSelectedAllocationFiltr.size() > 0 && (setSelectedAllocationFiltr.contains(AcostaConstants.StatusUnAllocated) || setSelectedAllocationFiltr.contains(AcostaConstants.StatusNew))))){
                listInitWrapper.addAll(new List<InitiativeWrapper>(mapInitWrapperUnAllocated.values()));
            }

            totalRecs = (listInitWrapper !=null && listInitWrapper.size()>0)?listInitWrapper.size():0;
            for(InitiativeWrapper wrap : listInitWrapper){
                if(setSelectedInitiatives != null && setSelectedInitiatives.contains(wrap.initId)){
                    wrap.checked=true;
                }
            }
            listInitWrapperOffset = new List<InitiativeWrapper>();
            Integer count = (listInitWrapper.size() > LimitSize ?  LimitSize : listInitWrapper.size());
            OffsetSize = 0;
            for(Integer i = OffsetSize;i < count;i++){
                listInitWrapperOffset.add(listInitWrapper.get(i));
            }
        }
        else{
            listInitWrapperOffset = new List<InitiativeWrapper>();
        }
        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to show the selected items.
     */
    public void showSelected(){
        try{
        showSelected = true;
        OffsetSize = 0;
        listInitWrapperSelected = new List<InitiativeWrapper>();
        for(InitiativeWrapper wrap : listInitWrapper){
            if(wrap.checked){
                listInitWrapperSelected.add(wrap);
            }
        }
        listInitWrapperOffset.clear();
        Integer count = (listInitWrapperSelected.size() > LimitSize ?  LimitSize : listInitWrapperSelected.size());
        OffsetSize = 0;
        for(Integer i = OffsetSize;i < count;i++){
            listInitWrapperOffset.add(listInitWrapperSelected.get(i));
        }
        totalRecs = (listInitWrapperSelected !=null && listInitWrapperSelected.size()>0)?listInitWrapperSelected.size():0;
        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to show all the items
     */
    public void showAll(){
        try{
        showSelected = false;
        OffsetSize = 0;
        listInitWrapperOffset.clear();
        Integer count = (listInitWrapper.size() > LimitSize ?  LimitSize : listInitWrapper.size());
        OffsetSize = 0;
        for(Integer i = OffsetSize;i < count;i++){
            listInitWrapperOffset.add(listInitWrapper.get(i));
        }
        totalRecs = (listInitWrapper !=null && listInitWrapper.size()>0)?listInitWrapper.size():0;
        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to show add the selected items to the selector.
     */
    public void addSelected(){
        try{
        setSelectedInitiatives.clear();
        mapSelectedInitiatives.clear();
        initiativesSelectedName = new Set<String>();
        mapSelectedInitObjectives = new Map<Id,String>();
        for(InitiativeWrapper wrap : listInitWrapper){
            if(wrap.checked){
                setSelectedInitiatives.add(wrap.initId);
                mapSelectedInitiatives.put(wrap.initId, wrap.initName);
                String uniqueName = wrap.initName+' ('+wrap.objectives+')';
                mapSelectedInitObjectives.put(wrap.initId,uniqueName);
            }
        }

        for (String init : mapSelectedInitObjectives.Values()){
            initiativesSelectedName.add(init);
        }

        for(Id id : mapSelectedInitiatives.keySet()){
            initiativesSelected += mapSelectedInitiatives.get(id) +' | ';
        }
        initiativesSelected = (mapSelectedInitiatives.size() == 0 ?'':initiativesSelected.substring(0,initiativesSelected.length() -1));
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to clear the filters.
     */
    public void clearFilter(){
        try{
        listIniFiltrWrap.clear();
        for(FilterWrapper wrap : listIniFiltrWrapAll){
            wrap.checked=false;
        }
        if(listIniFiltrWrapAll.size() > 0){
            listIniFiltrWrap.addAll(listIniFiltrWrapAll);
        }
        listObjFiltrWrap.clear();
        for(FilterWrapper wrap : listObjFiltrWrapAll){
            wrap.checked=false;
        }
        if(listObjFiltrWrapAll.size() > 0){
            listObjFiltrWrap.addAll(listObjFiltrWrapAll);
        }
        listBannerFiltrWrap.clear();
        for(FilterWrapper wrap : listBannerFiltrWrapAll){
            wrap.checked=false;
        }
        if(listBannerFiltrWrapAll.size() > 0){
            listBannerFiltrWrap.addAll(listBannerFiltrWrapAll);
        }
        listSBFiltrWrap.clear();
        for(FilterWrapper wrap : listSBFiltrWrapAll){
            wrap.checked=false;
        }
        if(listSBFiltrWrapAll.size() > 0){
            listSBFiltrWrap.addAll(listSBFiltrWrapAll);
        }
        for(FilterWrapper wrap : listBonusFiltrWrap){
            wrap.checked=false;
        }
        for(FilterWrapper wrap : listPriorityFiltrWrap){
            wrap.checked=false;
        }
        for(FilterWrapper wrap : listAllocationFiltrWrap){
            wrap.checked=false;
        }
        searchInitiative();
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to refresh the Initiative picklist, based on objective selection
     */
    Public void refreshInitiativeFilter(){
        try{
        Boolean isCheked = false;
        for(FilterWrapper wrap : listIniFiltrWrap){
            if(wrap.checked){
                isCheked = true;
            }
        }
        if(!isCheked){
            listIniFiltrWrap.clear();
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to refresh the Objectives picklist, based on initiative selection
     */
    Public void refreshObjectiveFilter(){
        try{
        Set<String> setInit = new Set<String>();
        for(FilterWrapper wrap : listIniFiltrWrap){
            if(wrap.checked){
                setInit.add(wrap.filtrValue);
            }
        }
        if(listObjFiltrWrapFiltered == null){
            listObjFiltrWrapFiltered = new List<FilterWrapper>();
        }
        else{
            listObjFiltrWrapFiltered.clear();
        }
        for(FilterWrapper wrap : listObjFiltrWrap){
            if(wrap.checked){
                setSelectedObjectivesFiltr.add(wrap.filtrValue);
            }
        }
        Set<String> setExistingObj = new Set<String>();
        listObjFiltrWrap.clear();
        for(National_Initiative__c ni : [Select Objectives__c from National_Initiative__c where id in : setNIId and Initiatives__c in : setInit]){
            if(ni.Objectives__c != null && !setExistingObj.contains(ni.Objectives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = (setSelectedObjectivesFiltr.contains(ni.Objectives__c)?true:false);
                wrap.filtrLabel = ni.Objectives__c;
                wrap.filtrValue = ni.Objectives__c;
                listObjFiltrWrapFiltered.add(wrap);
                setExistingObj.add(ni.Objectives__c);
            }
        }
        for(Local_Initiative__c li : [Select Objectives__c from Local_Initiative__c where id in : setLIId and Initiatives__c in : setInit]){
            if(li.Objectives__c != null && !setExistingObj.contains(li.Objectives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = (setSelectedObjectivesFiltr.contains(li.Objectives__c)?true:false);
                wrap.filtrLabel = li.Objectives__c;
                wrap.filtrValue = li.Objectives__c;
                listObjFiltrWrapFiltered.add(wrap);
                setExistingObj.add(li.Objectives__c);
            }
        }
        if(listObjFiltrWrapFiltered.size() > 0){
            listObjFiltrWrap.addAll(listObjFiltrWrapFiltered);
        }
        if(setInit.size() ==0){
            listObjFiltrWrap.addAll(listObjFiltrWrapAll);
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to refresh the Banner picklist, based on Sub Banner selection
     */
    Public void refreshbannerFilter(){
        try{
        Boolean isCheked = false;
        for(FilterWrapper wrap : listBannerFiltrWrap){
            if(wrap.checked){
                isCheked = true;
            }
        }
        if(!isCheked){
            listBannerFiltrWrap.clear();
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called to refresh the Sub Banner picklist, based on Banner selection
     */
    Public void refreshSubBannerFilter(){
        try{
        Set<String> setBanner = new Set<String>();
        for(FilterWrapper wrap : listBannerFiltrWrap){
            if(wrap.checked){
                setBanner.add(wrap.filtrValue);
            }
        }
        if(listSBFiltrWrapFiltered == null){
            listSBFiltrWrapFiltered =  new List<FilterWrapper>();
        }
        else{
            listSBFiltrWrapFiltered.clear();
        }
        for(FilterWrapper wrap : listSBFiltrWrap){
            if(wrap.checked){
                setSelectedSubBannerFiltr.add(wrap.filtrValue);
            }
        }
        listSBFiltrWrap.clear();
        Set<String> setExistingSB = new Set<String>();
        for(National_Sub_Banner_Allocation__c nsba : [Select National_Sub_Banner_Allocation_Name__c from National_Sub_Banner_Allocation__c where id in : setNSBAId AND National_Banner_Allocation__r.National_Banner_Allocation_Name__c in : setBanner]){
            if(!setExistingSB.contains(nsba.National_Sub_Banner_Allocation_Name__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = (setSelectedSubBannerFiltr.contains(nsba.National_Sub_Banner_Allocation_Name__c)?true:false);
                wrap.filtrLabel = nsba.National_Sub_Banner_Allocation_Name__c;
                wrap.filtrValue = nsba.National_Sub_Banner_Allocation_Name__c;
                listSBFiltrWrapFiltered.add(wrap);
                setExistingSB.add(nsba.National_Sub_Banner_Allocation_Name__c);
            }
        }
        for(Local_Sub_Banner_Allocation__c lsba: [Select Local_Sub_Banner_Allocation_Name__c from Local_Sub_Banner_Allocation__c where id in : setLSBAId AND Local_Banner_Allocation__r.Local_Banner_Allocation_Name__c in : setBanner ]){
            if(!setExistingSB.contains(lsba.Local_Sub_Banner_Allocation_Name__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = (setSelectedSubBannerFiltr.contains(lsba.Local_Sub_Banner_Allocation_Name__c)?true:false);
                wrap.filtrLabel = lsba.Local_Sub_Banner_Allocation_Name__c;
                wrap.filtrValue = lsba.Local_Sub_Banner_Allocation_Name__c;
                listSBFiltrWrapFiltered.add(wrap);
                setExistingSB.add(lsba.Local_Sub_Banner_Allocation_Name__c);
            }
        }
        if(listSBFiltrWrapFiltered.size() > 0){
            listSBFiltrWrap.addAll(listSBFiltrWrapFiltered);
        }
        if(setBanner.size() == 0){
            listSBFiltrWrap.addAll(listSBFiltrWrapAll);
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Wrapper class for the filter display
     */
    @TestVisible
    private class FilterWrapper{
        public Boolean checked{ get; set; }
        public String filtrLabel{ get; set;}
        public String filtrValue{ get; set;}
        public String id{get;set;}

        public FilterWrapper(){
            checked = false;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Wrapper class for the filter display
     */
    @TestVisible
    private class InitiativeWrapper{
        public Boolean checked{ get; set; }
        public String id{ get; set;}
        public String initId{get;set;}
        public String initName{get;set;}
        public String initiatives{ get; set;}
        public String objectives{get;set;}
        public String clientName{get;set;}
        public String banner{get;set;}
        public String subBanner{get;set;}
        public String product{get;set;}
        public String productGroup{get;set;}
        public String brand{get;set;}
        public String target{get;set;}
        public String unitOfMeasure{get;set;}
        public String bonus{get;set;}
        public String description{get;set;}

        public InitiativeWrapper(){
            checked = false;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to create a Initiative Wrapper for NI
     */
    public InitiativeWrapper initWrapNI(National_Initiative__c ni){
        InitiativeWrapper wrap = new InitiativeWrapper();
        wrap.checked =false;
        wrap.Id = ni.Id;
        wrap.initId = ni.Id;
        wrap.initName = ni.Name;
        wrap.initiatives = ni.Initiatives__c;
        wrap.objectives = ni.Objectives__c;
        wrap.clientName = ni.Strategy__r.Client__r.Name;
        wrap.product = ni.Product_SKU__c;
        wrap.productGroup = ni.Product_Group__c;
        wrap.brand = ni.Brand__c;
        wrap.target = ni.Target__c;
        wrap.unitOfMeasure = ni.Unit_of_Measure__c;
        wrap.bonus = ni.Bonus_Eligibility__c?'Yes':'No';
        wrap.description = ni.Comments__c;
        return wrap;
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to create a Initiative Wrapper for LI
     */
    public InitiativeWrapper initWrapLI(Local_Initiative__c li){
        InitiativeWrapper wrap = new InitiativeWrapper();
        wrap.checked =false;
        wrap.Id = li.Id;
        wrap.initId = li.Id;
        wrap.InitName =li.Name;
        wrap.initiatives = li.Initiatives__c;
        wrap.objectives = li.Objectives__c;
        wrap.clientName = li.Local_Strategy__r.Client_Customer_Relationship__r.Client__r.Name;
        wrap.product = li.Product_SKU__c;
        wrap.productGroup = li.Product_Group__c;
        wrap.brand = li.Brand__c;
        wrap.target = li.Target__c;
        wrap.unitOfMeasure = li.Unit_of_Measure__c;
        wrap.bonus = li.Bonus_Eligibility__c?'Yes':'No';
        wrap.description = li.Comments__c;
        return wrap;
    }

 //---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to create a Initiative Wrapper for NSBA
     */
    public InitiativeWrapper initWrapNSBA(National_Sub_Banner_Allocation__c nsba){
        InitiativeWrapper wrap = new InitiativeWrapper();
        wrap.checked =false;
        wrap.Id = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c;
        wrap.initId = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__c;
        wrap.initName = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Name;
        wrap.initiatives = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Initiatives__c;
        wrap.objectives = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Objectives__c;
        wrap.clientName = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Strategy__r.Client__r.Name;
        wrap.product = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Product_SKU__c;
        wrap.productGroup = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Product_Group__c;
        wrap.brand = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Brand__c;
        wrap.target = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Target__c;
        wrap.unitOfMeasure = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Unit_of_Measure__c;
        wrap.bonus = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Bonus_Eligibility__c?'Yes':'No';
        wrap.description = nsba.National_Banner_Allocation__r.National_Initiative_Lookup__r.Comments__c;
        return wrap;
    }
 //---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to create a Initiative Wrapper for LSBA
     */
    public InitiativeWrapper initWrapLSBA(Local_Sub_Banner_Allocation__c lsba){
        InitiativeWrapper wrap = new InitiativeWrapper();
        wrap.checked =false;
        wrap.Id = lsba.Local_Banner_Allocation__r.Local_Initiative__c;
        wrap.initId = lsba.Local_Banner_Allocation__r.Local_Initiative__c;
        wrap.initiatives = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Initiatives__c;
        wrap.initName = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Name;
        wrap.objectives = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Objectives__c;
        wrap.clientName = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Client__r.Name;
        wrap.product = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Product_SKU__c;
        wrap.productGroup = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Product_Group__c;
        wrap.brand = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Brand__c;
        wrap.target = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Target__c;
        wrap.unitOfMeasure = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Unit_of_Measure__c;
        wrap.bonus = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Bonus_Eligibility__c?'Yes':'No';
        wrap.description = lsba.Local_Banner_Allocation__r.Local_Initiative__r.Comments__c;
        return wrap;
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to navigate to the first page of the data table
     */
    public void FirstPage(){
        try{
        OffsetSize = 0;
        listInitWrapperOffset.clear();
        if(showSelected && listInitWrapperSelected.size() >0){
            Integer count = (listInitWrapperSelected.size() > LimitSize?  LimitSize: listInitWrapperSelected.size());
            for(Integer i = OffsetSize;i < count;i++){
                listInitWrapperOffset.add(listInitWrapperSelected.get(i));
            }
        }
        else{
            Integer count = (listInitWrapper.size() > LimitSize?  LimitSize: listInitWrapper.size());
            for(Integer i = OffsetSize;i < count;i++){
                listInitWrapperOffset.add(listInitWrapper.get(i));
            }
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to navigate to the previous page of the data table
     */
    public void previous(){
        try{
        OffsetSize = (OffsetSize-LimitSize);
        listInitWrapperOffset.clear();
        if(showSelected && listInitWrapperSelected.size() >0){
            Integer count = (listInitWrapperSelected.size() > (OffsetSize+LimitSize)?  (OffsetSize+LimitSize) : listInitWrapperSelected.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapperSelected.get(i));
            }
        }
        else{
            Integer count = (listInitWrapper.size() > (OffsetSize+LimitSize)?  (OffsetSize+LimitSize) : listInitWrapper.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapper.get(i));
            }
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to navigate to the next page of the data table
     */
    public void next(){
        try{
        OffsetSize = OffsetSize + LimitSize;
        listInitWrapperOffset.clear();
        if(showSelected && listInitWrapperSelected.size() >0){
            Integer count = (listInitWrapperSelected.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : listInitWrapperSelected.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapperSelected.get(i));
            }
        }
        else{
            Integer count = (listInitWrapper.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : listInitWrapper.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapper.get(i));
            }
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to navigate to the last page of the data table
     */
    public void LastPage(){
        try{
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        listInitWrapperOffset.clear();
        if(showSelected && listInitWrapperSelected.size() >0){
            Integer count = (listInitWrapperSelected.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : listInitWrapperSelected.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapperSelected.get(i));
            }
        }
        else{
            Integer count = (listInitWrapper.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : listInitWrapper.size());
            for(Integer i = OffsetSize;i< count;i++){
                listInitWrapperOffset.add(listInitWrapper.get(i));
            }
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to check if data table has any previous item
     */
    public boolean getprev(){
        if(OffsetSize == 0){
            return true;
        }
        else {
            return false;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to check if data table has any next item
     */
    public boolean getnxt(){
        if((OffsetSize + LimitSize +1) > totalRecs){
            return true;
        }
        else {
            return false;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to get the total record count
     */
    public Integer gettotalRecs(){
        return totalRecs;
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : method to get the page number
     */
    public Integer getPageNumber(){
        if(OffsetSize ==0){
            return 1;
        }
        else{
            return (OffsetSize /LimitSize)+1 ;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called when look up is clicked to show the pop up window
     */
    public void showPopup() {
        try{
        showSelected = false;
        totalRecs = 0;
        OffsetSize = 0;
        totalPages=0;
        this.page=1;
        initiativesSelected ='';
        setNBAId.clear();
        setLBAId.clear();
        setNSBAId.clear();
        setLSBAId.clear();
        listBonusFiltrWrap = new List<FilterWrapper>();
        listPriorityFiltrWrap = new List<FilterWrapper>();
        listAllocationFiltrWrap = new List<FilterWrapper>();
        listIniFiltrWrap = new List<FilterWrapper>();
        listIniFiltrWrapAll = new List<FilterWrapper>();
        listObjFiltrWrap = new List<FilterWrapper>();
        listObjFiltrWrapAll = new List<FilterWrapper>();
        listBannerFiltrWrap = new List<FilterWrapper>();
        listBannerFiltrWrapAll = new List<FilterWrapper>();
        listSBFiltrWrap = new List<FilterWrapper>();
        listSBFiltrWrapAll = new List<FilterWrapper>();
        searchInitiative();
        //populate filter values for Bonus
        FilterWrapper wrapYes = new FilterWrapper();
        wrapYes.checked=false;
        wrapYes.filtrLabel = 'Yes';
        wrapYes.filtrValue='true';
        listBonusFiltrWrap.add(wrapYes);
        FilterWrapper wrapNo = new FilterWrapper();
        wrapNo.checked=false;
        wrapNo.filtrLabel = 'No';
        wrapNo.filtrValue='False';
        listBonusFiltrWrap.add(wrapNo);
        //populate filter values for priority
        for(SelectOption selOp : AcostaConstants.getPickValues('National_Initiative__c','Priority__c',null)){
            FilterWrapper wrap = new FilterWrapper();
            wrap.checked = false;
            wrap.filtrLabel = selOp.getLabel();
            wrap.filtrvalue=selOp.getValue();
            listPriorityFiltrWrap.add(wrap);
        }
        //populate filter values for Allocation Status
        for(SelectOption selOp : AcostaConstants.getPickValues('National_Banner_Allocation__c','Status__c',null)){
            FilterWrapper wrap = new FilterWrapper();
            wrap.checked = false;
            wrap.filtrLabel = selOp.getLabel();
            wrap.filtrvalue=selOp.getValue();
            listAllocationFiltrWrap.add(wrap);
        }
        //populate the multiselect picklist values for Initiatives and objectives
        Set<String> setExistingInit = new Set<String>();
        Set<String> setExistingObj = new Set<String>();
        for(National_Initiative__c ni : [Select Initiatives__c, Objectives__c from National_Initiative__c where id in : setNIId ]){
            if(ni.Initiatives__c != null && !setExistingInit.contains(ni.Initiatives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = false;
                wrap.filtrLabel = ni.Initiatives__c;
                wrap.filtrValue = ni.Initiatives__c;
                listIniFiltrWrap.add(wrap);
                listIniFiltrWrapAll.add(wrap);
                setExistingInit.add(ni.Initiatives__c);
            }
            if(ni.Objectives__c != null && !setExistingObj.contains(ni.Objectives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = false;
                wrap.filtrLabel = ni.Objectives__c;
                wrap.filtrValue = ni.Objectives__c;
                listObjFiltrWrap.add(wrap);
                listObjFiltrWrapAll.add(wrap);
                setExistingObj.add(ni.Objectives__c);
            }
        }
        for(Local_Initiative__c li : [Select Initiatives__c, Objectives__c from Local_Initiative__c where id in : setLIId ]){
            if(li.Initiatives__c != null && !setExistingInit.contains(li.Initiatives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = false;
                wrap.filtrLabel = li.Initiatives__c;
                wrap.filtrValue = li.Initiatives__c;
                listIniFiltrWrap.add(wrap);
                listIniFiltrWrapAll.add(wrap);
                setExistingInit.add(li.Initiatives__c);
            }
            if(li.Objectives__c != null && !setExistingObj.contains(li.Objectives__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.checked = false;
                wrap.filtrLabel = li.Objectives__c;
                wrap.filtrValue = li.Objectives__c;
                listObjFiltrWrap.add(wrap);
                listObjFiltrWrapAll.add(wrap);
                setExistingObj.add(li.Objectives__c);
            }
        }
        //populate the multiselect picklist for Banner
        Set<String> setExistingBA = new Set<String>();
        for(National_Banner_Allocation__c nba : [Select National_Banner_Allocation_Name__c from National_Banner_Allocation__c where id in : setNBAId ]){
            if(!setExistingBA.contains(nba.National_Banner_Allocation_Name__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.filtrLabel = nba.National_Banner_Allocation_Name__c;
                wrap.filtrValue = nba.National_Banner_Allocation_Name__c;
                listBannerFiltrWrap.add(wrap);
                setExistingBA.add(nba.National_Banner_Allocation_Name__c);
            }
        }

        for(Local_Banner_Allocation__c lba: [Select Local_Banner_Allocation_Name__c from Local_Banner_Allocation__c where id in : setLBAId ]){
            if(!setExistingBA.contains(lba.Local_Banner_Allocation_Name__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.filtrLabel = lba.Local_Banner_Allocation_Name__c;
                wrap.filtrValue = lba.Local_Banner_Allocation_Name__c;
                listBannerFiltrWrap.add(wrap);
                setExistingBA.add(lba.Local_Banner_Allocation_Name__c);
            }
        }
        //populate the multiselect picklist for Sub Banner
        Set<String> setExistingSBA = new Set<String>();
        for(National_Sub_Banner_Allocation__c nsba : [Select National_Sub_Banner_Allocation_Name__c from National_Sub_Banner_Allocation__c where id in : setNSBAId ]){
            if(!setExistingSBA.contains(nsba.National_Sub_Banner_Allocation_Name__c)){
                FilterWrapper wrap = new FilterWrapper();
                wrap.filtrLabel = nsba.National_Sub_Banner_Allocation_Name__c;
                wrap.filtrValue = nsba.National_Sub_Banner_Allocation_Name__c;
                listSBFiltrWrap.add(wrap);
                listSBFiltrWrapAll.add(wrap);
                setExistingSBA.add(nsba.National_Sub_Banner_Allocation_Name__c);
            }
        }
        for(Local_Sub_Banner_Allocation__c lsba: [Select Local_Sub_Banner_Allocation_Name__c  from Local_Sub_Banner_Allocation__c where id in : setLSBAId ]){
            if(!setExistingSBA.contains(lsba.Local_Sub_Banner_Allocation_Name__c )){
                FilterWrapper wrap = new FilterWrapper();
                wrap.filtrLabel = lsba.Local_Sub_Banner_Allocation_Name__c ;
                wrap.filtrValue = lsba.Local_Sub_Banner_Allocation_Name__c ;
                listSBFiltrWrap.add(wrap);
                listSBFiltrWrapAll.add(wrap);
                setExistingSBA.add(lsba.Local_Sub_Banner_Allocation_Name__c );
            }
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called when Save button is clicked, to Save the customer visit information.
     */
    public void saveRefine(){
        try{
        if(refinePlanId == null && !isSaved){
            custVisit = new Customer_Visit__c();
        }
        custVisit.Name = custVisitInput.Name;
        custVisit.Start_Date__c = custVisitInput.Start_Date__c;
        custVisit.End_Date__c = custVisitInput.End_Date__c;
        custVisit.Master__c = masterPlanId;
        custVisit.RecordTypeId = AcostaConstants.getIPRecordTypeId('Refine');
        //custVisit.ownerId = UserInfo.getUserId();
        upsert custVisit;
        List<Customer_Visit_Account_Relationship__c> listCVAR = new List<Customer_Visit_Account_Relationship__c>();

        //Add Client and Customer accounts to the Initiative Plan
        if(refinePlanId == null && !isSaved){
          for(Id id : setSelectedClients){
              Customer_Visit_Account_Relationship__c cvar = new Customer_Visit_Account_Relationship__c();
              cvar.Name = 'Client Account - '+ mapSelectedClients.get(id)!=null && mapSelectedClients.get(id).length() > 80 ? mapSelectedClients.get(id).substring(0, 79) : mapSelectedClients.get(id);
              cvar.Account__c = id;
              cvar.Customer_Visit__c = custVisit.Id;
              listCVAR.add(cvar);
          }
          for(Id id : setSelectedCustomers){
             Customer_Visit_Account_Relationship__c cvar = new Customer_Visit_Account_Relationship__c();
             cvar.Name = 'Customer Account - '+ mapSelectedCustomers.get(id)!=null && mapSelectedCustomers.get(id).length() > 80 ? mapSelectedCustomers.get(id).substring(0, 79) : mapSelectedCustomers.get(id);
             cvar.Account__c = id;
             cvar.Customer_Visit__c = custVisit.Id;
             listCVAR.add(cvar);
          }
          if(listCVAR.size() > 0){
              insert listCVAR;
          }
        }

        //Remove the existing Initiatives from the Initiative Plan, if it is not a part of the selected Initiatives
        Set<Id> setExistingInit = new Set<Id>();
        if(refinePlanId != null || isSaved){
            List<Customer_Visit_Initiative_Relationship__c> listCVIRDelete = new List<Customer_Visit_Initiative_Relationship__c>();
            for(Customer_Visit_Initiative_Relationship__c cvir :  [Select Local_Initiative__c, National_Initiative__c from Customer_Visit_Initiative_Relationship__c where Customer_Visit__c =: custVisit.Id]){
                if(cvir.Local_Initiative__c != null){
                    setExistingInit.add(cvir.Local_Initiative__c);
                    if(!setSelectedInitiatives.contains(cvir.Local_Initiative__c)){
                        listCVIRDelete.add(cvir);
                    }
                }
                else{
                    setExistingInit.add(cvir.National_Initiative__c);
                    if(!setSelectedInitiatives.contains(cvir.National_Initiative__c)){
                        listCVIRDelete.add(cvir);
                    }
                }
            }
            if(listCVIRDelete.size() > 0){
                Delete listCVIRDelete;
            }
        }

        //Add the Initiatives to the Initiative Plan
        Map<Id,String> mapInitType = getInitiaitveType(setSelectedInitiatives);
        List<Customer_Visit_Initiative_Relationship__c> listCVIR = new List<Customer_Visit_Initiative_Relationship__c>();
        for(Id id : setSelectedInitiatives){
            if(!setExistingInit.contains(id)){
                Customer_Visit_Initiative_Relationship__c cvir = new Customer_Visit_Initiative_Relationship__c();
                cvir.Name=mapSelectedInitiatives.get(id);
                cvir.Customer_Visit__c = custVisit.Id;
                if(mapInitType.get(id).equals('NI')){
                    cvir.National_Initiative__c = id;
                }
                else{
                    cvir.Local_Initiative__c = id;
                }
                listCVIR.add(cvir);
            }
        }
        if(listCVIR.size() > 0){
            Insert listCVIR;
        }

        //apex sharing
        InitiativePlanApexShare.grantApexSharingRefine(masterPlanId, custVisit);
        isSaved = true;
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called when Save button is clicked, to Save the customer visit information.
     */
    public PageReference saveAndExitRefine(){
        try{
        saveRefine();
        if(custVisit.Id != null){
            PageReference pref = new pageReference('/'+custVisit.Id);
            return pref;
        }
        else{
            return null;
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method which is called when Save button is clicked, to Save the customer visit information.
     */
    public PageReference saveAndScheduleRefine(){
        try{
        saveRefine();
        if(custVisit.Id != null){
            Id eventRecTypeId = AcostaConstants.getEventRecordTypeId('Initiative Planning Event');
            Customer_Visit__c masterPlanRec = [Select Name from Customer_Visit__c where id =: masterPlanId];
            //PageReference pref = new pageReference('/00U/e'+'?'+System.Label.InitiativePlanMasterLkup+'='+masterPlanRec.Name+'&'+System.Label.InitiativePlanMasterLookup+'='+masterPlanId+'&what_id='+custVisit.Id+'&retURL='+custVisit.Id+'&RecordType='+eventRecTypeId+'&ent=Event');
            PageReference pref = new pageReference('/00U/e');
            pref.getParameters().put(System.Label.InitiativePlanMasterLkup,masterPlanRec.Name);
            pref.getParameters().put(System.Label.InitiativePlanMasterLookup,masterPlanId);
            pref.getParameters().put('what_id',custVisit.Id);
            pref.getParameters().put('retURL',custVisit.Id);
            pref.getParameters().put('RecordType',eventRecTypeId);
            pref.getParameters().put('ent','Event');
            return pref;
        }
        else{
            return null;
        }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
             return null;
        }
    }

    public PageReference exit(){
        try{
            if(custVisit != null && custVisit.Id != null){
                PageReference pageRef = new PageReference('/'+custVisit.Id);
                return pageRef;
            }
            else{
                PageReference pageRef = new PageReference('/'+masterPlanId);
                return pageRef;
            }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }

    public Map<Id,String> getInitiaitveType(Set<Id> initId){
        Map<Id,String> mapInitType = new Map<Id,String>();
        for(National_Initiative__c ni : [Select Id from National_Initiative__c where id in : initId]){
            mapInitType.put(ni.Id, 'NI');
        }
        for(Local_Initiative__c li : [Select Id from Local_Initiative__c where id in : initId]){
            mapInitType.put(li.Id, 'LI');
        }
        return mapInitType;
    }
}