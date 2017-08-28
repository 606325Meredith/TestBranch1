/**
 *  Description     :   Creaetion and update of Disposition object based on Banner and Sub Banner, this is the controller of the InitiativeDisposition page
 *                      this page will be run from a button of the
 *
 *  Created By      :   Abhishek Tripathi
 *  Created Date    :   8/23/2016
 *  Version         :   V1.0
 **/
public without sharing class InitiativeDispositionExtn{
    public Customer_Visit__c initiativePlan {get;set;}
    public Customer_Visit__c masterInitiativePlan { get; set; }
    public Event evnt { get; set; }
    Public Boolean isSaved { get; set; }

    public List<itemWrapper> listOfItems { get; set; }
    public List<itemWrapper> listOfOtherItems { get; set; }
    public Map<Id, National_Banner_Allocation__c> customerNationalIds;
    public Map<Id, National_Sub_Banner_Allocation__c> mapOfSubNationalBanners;
    public Map<Id, Local_Sub_Banner_Allocation__c> mapOfSubLocalBanners;

    private Map<Id, Local_Banner_Allocation__c> customerLocallIds;
    private List<Customer_Visit_Execution__c> initiativeDisposition ;
    private Set<Id> idsLocalInitiative ;
    private Set<Id> idsNationalInitiative ;
    public Customer_Visit_Execution__c initDesposition { get; set; }
    public List<Customer_Visit_Execution_Detail__c> listOfCVEDtoInsert;

    private Map<Id, National_Initiative__c> mapOfNationalInitiatives;
    private Map<Id, Local_Initiative__c> mapOfLocallInitiatives;

    public InitiativeDispositionExtn(Apexpages.StandardController con){
        isSaved = false;
        init();
    }

    public void init() {

        try {
            listOfItems = new List<itemWrapper>();
            listOfOtherItems = new List<itemWrapper>();
            initiativePlan = new Customer_Visit__c();
            masterInitiativePlan = new Customer_Visit__c();
            customerNationalIds = new Map<Id, National_Banner_Allocation__c>();
            customerLocallIds = new Map<Id, Local_Banner_Allocation__c>();
            idsLocalInitiative = new Set<Id>();
            idsNationalInitiative = new Set<Id>();
            mapOfSubNationalBanners = new Map<Id, National_Sub_Banner_Allocation__c>();
            mapOfSubLocalBanners = new Map<Id, Local_Sub_Banner_Allocation__c>();
            initDesposition = new Customer_Visit_Execution__c();
            listOfCVEDtoInsert = new List<Customer_Visit_Execution_Detail__c>();

            mapOfNationalInitiatives = new Map<Id, National_Initiative__c>();
            mapOfLocallInitiatives = new Map<Id, Local_Initiative__c>();
            Map<Id, Id> nationalInitiativeWithClient = new Map<Id, Id>();

            String evtId = ApexPages.currentPage().getParameters().get('id');
            evnt = [Select Id, WhatId, Description_Internal_Only__c, StartDateTime, Initiative_Disposition__c, Initiative_Disposition__r.Overal_Status__c, Customer_Name__c, Customer_Name__r.ParentId, Customer_Name__r.Name, Customer_Name__r.RecordType.Name From Event Where Id =: evtId];

            if(evnt.Initiative_Disposition__c != null) {
                initDesposition.Overal_Status__c = evnt.Initiative_Disposition__r.Overal_Status__c;
            }
            //Fetching initiative plan from the event
            initiativePlan = [Select Id, Name, End_Date__c, Start_Date__c, Master__c, RecordType.Name from Customer_Visit__c Where Id =: evnt.WhatId ];

            if(initiativePlan.RecordType.Name == Constant.REFINE) {

                //Check for the master record
                if(initiativePlan.Master__c != null) {
                    masterInitiativePlan = initiativePlan;
                    initiativePlan = new Customer_Visit__c();
                    initiativePlan = [Select Id, Name, End_Date__c, Start_Date__c, RecordType.Name From Customer_Visit__c Where ID =: masterInitiativePlan.Master__c];
                }
            }

            Set<Id> setOflocalInitiativeIds = new Set<Id>();

            //Fetching all the junction records related to the initiative plan
            for(Customer_Visit_Initiative_Relationship__c cvIR : [ Select Id, Customer_Visit__c, Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c, Local_Initiative__c, National_Initiative__c, National_Initiative__r.Strategy__r.Client__c From Customer_Visit_Initiative_Relationship__c Where Customer_Visit__c =: evnt.WhatId]) {

                if(cvIR.National_Initiative__c != null) {
                    nationalInitiativeWithClient.put(cvIR.National_Initiative__c, cvIR.National_Initiative__r.Strategy__r.Client__c);
                }

                if(cvIR.Local_Initiative__c != null) {
                    setOflocalInitiativeIds.add(cvIR.Local_Initiative__c);
                    if(cvIR.Local_Initiative__r.Local_Strategy__r.Client_Customer_Relationship__r.Customer__c == evnt.Customer_Name__c)
                        idsLocalInitiative.add(cvIR.Local_Initiative__c);
                }
            }

            //Local Banner CC.CUSTOMER == EVNT.CUSTOMER and Sub banner query based on CC
            for(Local_Banner_Allocation__c lba : [Select Id, Local_Initiative__c From Local_Banner_Allocation__c Where Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated'  ]) {

                if(setOflocalInitiativeIds.contains(lba.Local_Initiative__c))
                    idsLocalInitiative.add(lba.Local_Initiative__c);
            }

            //Local Banner CC.CUSTOMER == EVNT.CUSTOMER and Sub banner query based on CC
            for(Local_Sub_Banner_Allocation__c lba : [Select Id, Local_Initiative__c From Local_Sub_Banner_Allocation__c Where Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated'  ]) {
                if(lba.Local_Initiative__c != null && setOflocalInitiativeIds.contains(lba.Local_Initiative__c))
                    idsLocalInitiative.add(lba.Local_Initiative__c);
            }

            for(Client_Customer_Relationship__c cc : [ Select Id, Client__c, Customer__c From Client_Customer_Relationship__c Where Client__c IN: nationalInitiativeWithClient.values() OR Customer__c =: evnt.Customer_Name__c]) {
                for(Id ids : nationalInitiativeWithClient.keySet()) {
                    if(cc.Client__c == nationalInitiativeWithClient.get(ids) && cc.Customer__c == evnt.Customer_Name__c) {
                        idsNationalInitiative.add(ids);
                    }
                }
            }

            //Fetching the picklist values from the Account object
            Schema.DescribeFieldResult dfr = National_Initiative__c.Objectives__c.getDescribe();
            Set<String> objectiveValues = new Set<String>();

            for(Schema.PicklistEntry st : dfr.getPicklistValues()) {
                if(st.getValue() == Constant.OBJECTIVE_SELLIN || st.getValue() == Constant.OBJECTIVE_ITEM_CONVERSION || st.getValue() == Constant.OBJECTIVE_SELL_IN_CORE_ITEMS || st.getValue() == Constant.OBJECTIVE_FIX){
                    objectiveValues.add(st.getValue());
                }
            }

            Map<Id, Customer_Visit_Execution_Detail__c> nationalLocalInitiativeMap = new Map<Id, Customer_Visit_Execution_Detail__c>();
            for(Customer_Visit_Execution_Detail__c cv : [ Select Id, Comments__c, Customer_Code__c, Accepted_Comments__c , Rejected_Reason__c, Pending_Reason__c, Follow_Up_Date__c, Pipeline_UOM__c, Customer_Visit_Execution__c, Local_Banner_Allocation__c, Local_Sub_Banner_Allocation__c, National_Banner_Allocation__c, National_Sub_Banner_Allocation__c, Forecast__c, Retail_Availability_Date__c, Shipment_Date__c, Status__c, System_Local_Initiative__c, System_National_Initiative__c FROM Customer_Visit_Execution_Detail__c where  Customer_Visit_Execution__c =: evnt.Initiative_Disposition__c AND (System_Local_Initiative__c IN: idsLocalInitiative OR System_National_Initiative__c IN: idsNationalInitiative )]) {

                if(cv.System_Local_Initiative__c != null)
                    nationalLocalInitiativeMap.put(cv.System_Local_Initiative__c, cv);

                if(cv.System_National_Initiative__c != null)
                    nationalLocalInitiativeMap.put(cv.System_National_Initiative__c, cv);

            }


            //Check for the sets size and fetching the data
            if(idsNationalInitiative.size() > 0) {

                for(National_Initiative__c ni : [Select Id, Name, Initiatives__c, Objectives__c, Target__c, Product_SKU__c, Product_Group__c, Brand__c From National_Initiative__c Where Id IN: idsNationalInitiative]) {
                    Customer_Visit_Execution_Detail__c cv = new Customer_Visit_Execution_Detail__c();
                    mapOfNationalInitiatives.put(ni.Id, ni);
                    if(ni.Initiatives__c == Constant.INITIATIVE_ASSORTMENT && objectiveValues.contains(ni.Objectives__c)) {
                        if(nationalLocalInitiativeMap.containsKey(ni.Id)) {

                            if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_ACCEPTED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, null, ni.Product_Group__c, ni.Brand__c, nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_REJECTED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, null, ni.Product_Group__c, ni.Brand__c,'', nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_PENDING) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, nationalLocalInitiativeMap.get(ni.Id), null, ni.Product_Group__c, ni.Brand__c, '','',nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_NOT_PROPOSED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, nationalLocalInitiativeMap.get(ni.Id), ni.Product_Group__c, ni.Brand__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, nationalLocalInitiativeMap.get(ni.Id)));
                            } else {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '', '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            }
                        } else {
                            listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '','','','',new Customer_Visit_Execution_Detail__c()));
                        }
                    } else {
                        if(nationalLocalInitiativeMap.containsKey(ni.Id)) {
                            if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_ACCEPTED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, null, ni.Product_Group__c, ni.Brand__c, nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_REJECTED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, null, ni.Product_Group__c, ni.Brand__c, '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_PENDING) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, nationalLocalInitiativeMap.get(ni.Id), null, ni.Product_Group__c, ni.Brand__c, '','',nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_NOT_PROPOSED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, null, nationalLocalInitiativeMap.get(ni.Id), ni.Product_Group__c, ni.Brand__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, nationalLocalInitiativeMap.get(ni.Id)));
                            } else {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), '', ni.Product_Group__c, ni.Brand__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            }
                        } else {
                            listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISNATIONAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '','','','',new Customer_Visit_Execution_Detail__c()));
                        }
                    }
                }
            }

            //Check for the sets size and fetching the data
            if(idsLocalInitiative.size() > 0) {

                for(Local_Initiative__c ni : [Select Id, Name, Initiatives__c, Objectives__c, Product_SKU__c, Target__c, Product_Group__c, Brand__c From Local_Initiative__c Where ID IN: idsLocalInitiative] ) {
                    mapOfLocallInitiatives.put(ni.Id, ni);
                    Customer_Visit_Execution_Detail__c cv = new Customer_Visit_Execution_Detail__c();

                    if(ni.Initiatives__c == 'Assortment / Distribution' && objectiveValues.contains(ni.Objectives__c)) {

                        if(nationalLocalInitiativeMap.containsKey(ni.Id)) {
                            if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_ACCEPTED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, null, ni.Product_Group__c, ni.Brand__c, nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_REJECTED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, null, ni.Product_Group__c, ni.Brand__c, '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_PENDING) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, nationalLocalInitiativeMap.get(ni.Id), null, ni.Product_Group__c, ni.Brand__c, '','',nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_NOT_PROPOSED) {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, nationalLocalInitiativeMap.get(ni.Id), ni.Product_Group__c, ni.Brand__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, nationalLocalInitiativeMap.get(ni.Id)));
                            } else {
                                listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '', '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            }
                        } else {
                            listOfItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '', '', '', '', new Customer_Visit_Execution_Detail__c()));
                        }
                    } else {
                        if(nationalLocalInitiativeMap.containsKey(ni.Id)) {

                            if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_ACCEPTED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, null, ni.Product_Group__c, ni.Brand__c, nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_REJECTED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, null, ni.Product_Group__c, ni.Brand__c, '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_PENDING) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, nationalLocalInitiativeMap.get(ni.Id), null, ni.Product_Group__c, ni.Brand__c, '','',nationalLocalInitiativeMap.get(ni.Id).Comments__c, '', nationalLocalInitiativeMap.get(ni.Id)));
                            } else if(nationalLocalInitiativeMap.get(ni.Id).Status__c == Constant.STATUS_NOT_PROPOSED) {
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, null, nationalLocalInitiativeMap.get(ni.Id), ni.Product_Group__c, ni.Brand__c, '', '', '', nationalLocalInitiativeMap.get(ni.Id).Comments__c, nationalLocalInitiativeMap.get(ni.Id)));
                            } else{
                                listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '', '', '', '', nationalLocalInitiativeMap.get(ni.Id)));
                            }
                        } else {
                            listOfOtherItems.add(new itemWrapper(ni.Product_SKU__c, ni.Initiatives__c, ni.Objectives__c, ni.Id, Constant.ISLOCAL, new Customer_Visit_Execution_Detail__c(), new Customer_Visit_Execution_Detail__c(), ni.Product_Group__c, ni.Brand__c, '','','','',new Customer_Visit_Execution_Detail__c()));
                        }
                    }
                }
            }

            //Check for banners and fetching banners only
            if(evnt.Customer_Name__r.RecordType.Name == Constant.CUSTOMER_RECORD_TYPE_L4) {

                //Fetching National and Sub Banners
                for(National_Banner_Allocation__c nb : [Select Id, Name, Status__c, National_Initiative_Lookup__c, Client_Customer_Relationship__c, Client_Customer_Relationship__r.Customer__c From National_Banner_Allocation__c Where National_Initiative_Lookup__c IN: idsNationalInitiative AND Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated']) {
                    customerNationalIds.put(nb.National_Initiative_Lookup__c, nb);
                }
                for(Local_Banner_Allocation__c lb : [Select Id, Name, Status__c, Local_Initiative__c, Client_Customer_Relationship__r.Customer__c From Local_Banner_Allocation__c Where Local_Initiative__c IN: idsLocalInitiative AND Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated']) {
                    customerLocallIds.put(lb.Local_Initiative__c, lb);
                }

            //Check for sub banner and fetching for sub banner only
            } else if(evnt.Customer_Name__r.RecordType.Name == Constant.CUSTOMER_RECORD_TYPE_L5) {

                for(National_Sub_Banner_Allocation__c nsb : [Select Id, Name, Client_Customer_Relationship__r.Customer__c, National_Banner_Allocation__r.National_Initiative_Lookup__c From National_Sub_Banner_Allocation__c Where National_Banner_Allocation__r.National_Initiative_Lookup__c IN: idsNationalInitiative AND Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated']) {
                    mapOfSubNationalBanners.put(nsb.National_Banner_Allocation__r.National_Initiative_Lookup__c, nsb);
                }

                for(Local_Sub_Banner_Allocation__c nsb : [Select Id, Name, Local_Banner_Allocation__r.Local_Initiative__c From Local_Sub_Banner_Allocation__c Where Local_Banner_Allocation__r.Local_Initiative__c IN: idsLocalInitiative AND Client_Customer_Relationship__r.Customer__c =: evnt.Customer_Name__c AND Status__c = 'Allocated']) {
                    mapOfSubLocalBanners.put(nsb.Local_Banner_Allocation__r.Local_Initiative__c, nsb);
                }
            }
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, Please contact System Administrator!'));

        }
    }

    /**
     *  @Description    :   Method to create banner and Sub Banner for the initiative
     *  @return         :   null
     *  @paramt         :   null
     **/
    public void createBannerAndSubBannerForInitiative() {

        List<National_Banner_Allocation__c> nationalBannerToInsert = new List<National_Banner_Allocation__c>();
        List<National_Sub_Banner_Allocation__c> nationalSubBannerToInsert = new List<National_Sub_Banner_Allocation__c>();

        List<Local_Banner_Allocation__c> localBannerToInsert = new List<Local_Banner_Allocation__c>();
        Set<Id> nationalInitiativesNotMatched = new Set<Id>();
        Set<Id> nationalSubInitiativesNotMatched = new Set<Id>();
        Set<Id> localInitiativesNotMatched = new Set<Id>();
        Set<Id> localSubInitiativesNotMatched = new Set<Id>();
        Map<Id, National_Banner_Allocation__c> MapOfNationalSubBannerAllocated = new Map<Id, National_Banner_Allocation__c>();
        Map<Id, National_Banner_Allocation__c> MapOfNationalSubBannerUNAllocated = new Map<Id, National_Banner_Allocation__c>();
        Map<Id, Local_Banner_Allocation__c> MapOfLocalSubBannerAllocated = new Map<Id, Local_Banner_Allocation__c>();
        Map<Id, Local_Banner_Allocation__c> MapOfLocalSubBannerUNAllocated = new Map<Id, Local_Banner_Allocation__c>();
        Map<Id, List<Id>> mapOfClientWithNationalInitiative = new Map<Id, List<Id>>();
        Map<Id, Id> mapOfCCWithLocalInitiative = new Map<Id, Id>();
        Map<Id, Id> mapOfCCWithNationalInitiative = new Map<Id, Id>();
        Map<Id, Id> mapOfParentCustomerCC = new Map<Id, Id>();
        Map<Id, List<Id>> localCLientMap = new Map<Id, List<Id>>();
        Map<Id, Id> localCCParentMap = new Map<Id, Id>();

        Map<Id, National_Banner_Allocation__c> listOfBannerWithSubBanner = new Map<Id, National_Banner_Allocation__c>();
        Map<Id, National_Sub_Banner_Allocation__c> mapNationalSubBannerToInsert = new Map<Id, National_Sub_Banner_Allocation__c>();
        Set<Id> setOfNationalSubInitiativeIds = new Set<Id>();
        Set<Id> setOfLocalSubInitiativeIds = new Set<Id>();


        //Perform for sub banner only
        if(evnt.Customer_Name__r.RecordType.Name == Constant.CUSTOMER_RECORD_TYPE_L5) {

            //Check weather all banners matched in National Initiative's
            for(Id ids : idsNationalInitiative) {

                if(!mapOfSubNationalBanners.containsKey(ids)) {
                    nationalSubInitiativesNotMatched.add(ids);
                    setOfNationalSubInitiativeIds.add(ids);
                }
            }

            //Check for Banners is Allocated or not for the Sub Banner
            if(nationalSubInitiativesNotMatched.size() > 0 ){

                List<National_Banner_Allocation__c> nsbaList = [ Select Id, Client_Customer_Relationship__c, National_Initiative_Lookup__c, Status__c From National_Banner_Allocation__c Where National_Initiative_Lookup__c IN: nationalSubInitiativesNotMatched];
                for( National_Banner_Allocation__c nsba : nsbaList){
                    nationalSubInitiativesNotMatched.remove(nsba.National_Initiative_Lookup__c);
                    if(nsba.Status__c == 'Allocated') {
                        MapOfNationalSubBannerAllocated.put(nsba.National_Initiative_Lookup__c, nsba);
                    } else {
                        MapOfNationalSubBannerUNAllocated.put(nsba.National_Initiative_Lookup__c, nsba);
                    }
                }
            }


            System.debug('idsLocalInitiative::::::::' + idsLocalInitiative);

            //Check weather all Sub banners matched in National Initiative's
            for(Id ids : idsLocalInitiative) {
                if(!mapOfSubLocalBanners.containsKey(ids)) {
                    localSubInitiativesNotMatched.add(ids);
                    setOfLocalSubInitiativeIds.add(ids);
                }
            }

            //Check for Banners is Allocated or not for the Sub Banner
            if(localSubInitiativesNotMatched.size() > 0 ){

                List<Local_Banner_Allocation__c> lnsba =  [ Select Id, Client_Customer_Relationship__c, Local_Initiative__c, Status__c From Local_Banner_Allocation__c Where Local_Initiative__c IN: localSubInitiativesNotMatched];
                for( Local_Banner_Allocation__c nsba : lnsba){

                    localSubInitiativesNotMatched.remove(nsba.Local_Initiative__c);
                    if(nsba.Status__c == 'Allocated')
                        MapOfLocalSubBannerAllocated.put(nsba.Local_Initiative__c, nsba);
                    else
                        MapOfLocalSubBannerUNAllocated.put(nsba.Local_Initiative__c, nsba);
                }
            }

            if(setOfNationalSubInitiativeIds.size() > 0) {
                List<National_Initiative__c> inits =  [ Select Id, Strategy__r.Client__c From National_Initiative__c Where ID IN: setOfNationalSubInitiativeIds ];
                for(National_Initiative__c ni : inits) {
                    if(mapOfClientWithNationalInitiative.containsKey(ni.Strategy__r.Client__c) ) {
                        mapOfClientWithNationalInitiative.get(ni.Strategy__r.Client__c).add(ni.Id);
                    } else {
                        mapOfClientWithNationalInitiative.put(ni.Strategy__r.Client__c, new List<Id>{ni.Id});
                    }
                }
            }

            if(nationalSubInitiativesNotMatched.size() > 0) {
                List<National_Initiative__c> inits =  [ Select Id, Strategy__r.Client__c From National_Initiative__c Where ID IN: nationalSubInitiativesNotMatched ];
                for(National_Initiative__c ni : inits) {
                    if(mapOfClientWithNationalInitiative.containsKey(ni.Strategy__r.Client__c) ) {
                        mapOfClientWithNationalInitiative.get(ni.Strategy__r.Client__c).add(ni.Id);
                    } else {
                        mapOfClientWithNationalInitiative.put(ni.Strategy__r.Client__c, new List<Id>{ni.Id});
                    }
                }
            }

            //---------------------------------------------------------------
            //Populating the map of CC with National Intitiative MASTER RECORDS
            if(mapOfClientWithNationalInitiative.size() > 0) {
                List<Client_Customer_Relationship__c> ccs = [Select Id, Client__c, Customer__c From Client_Customer_Relationship__c Where Client__c IN: mapOfClientWithNationalInitiative.keySet() AND Customer__c =: evnt.Customer_Name__r.ParentId];
                if(ccs.size() > 0) {
                    for(Client_Customer_Relationship__c cc : ccs) {
                        if(mapOfClientWithNationalInitiative.containsKey(cc.Client__c) && cc.Customer__c == evnt.Customer_Name__r.ParentId){
                            for(Id ids : mapOfClientWithNationalInitiative.get(cc.Client__c))
                                mapOfParentCustomerCC.put(ids, cc.Id);

                        }
                    }
                }
            }
            //---------------------------------------------------------------------

            if(localSubInitiativesNotMatched.size() > 0) {
                List<Local_Initiative__c> linit = [ Select Id, Local_Strategy__r.Client_Customer_Relationship__c, Local_Strategy__r.Client_Customer_Relationship__r.Client__c From Local_Initiative__c Where ID IN: localSubInitiativesNotMatched ];
                for(Local_Initiative__c ni : linit) {
                    mapOfCCWithLocalInitiative.put(ni.Id, ni.Local_Strategy__r.Client_Customer_Relationship__c);

                    if(localCLientMap.containsKey(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c) ) {
                        localCLientMap.get(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c).add(ni.Id);
                    } else {
                        localCLientMap.put(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c, new List<Id>{ni.Id});
                    }
                }
            }

            if(setOfLocalSubInitiativeIds.size() > 0) {
                List<Local_Initiative__c> linit = [ Select Id, Local_Strategy__r.Client_Customer_Relationship__c, Local_Strategy__r.Client_Customer_Relationship__r.Client__c From Local_Initiative__c Where ID IN: setOfLocalSubInitiativeIds ];
                for(Local_Initiative__c ni : linit) {
                    mapOfCCWithLocalInitiative.put(ni.Id, ni.Local_Strategy__r.Client_Customer_Relationship__c);

                    if(localCLientMap.containsKey(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c) ) {
                        localCLientMap.get(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c).add(ni.Id);
                    } else {
                        localCLientMap.put(ni.Local_Strategy__r.Client_Customer_Relationship__r.Client__c, new List<Id>{ni.Id});
                    }
                }
            }

            //--------LOCAL MASTER CC
            //Populating the map of CC with National Intitiative MASTER RECORDS
            if(localCLientMap.size() > 0) {
                List<Client_Customer_Relationship__c> ccs = [Select Id, Client__c, Customer__c From Client_Customer_Relationship__c Where Client__c IN: localCLientMap.keySet() AND Customer__c =: evnt.Customer_Name__r.ParentId];
                if(ccs.size() > 0) {
                    for(Client_Customer_Relationship__c cc : ccs) {
                        if(cc.Client__c != null && cc.Customer__c != null) {
                            if(localCLientMap.containsKey(cc.Client__c) && cc.Customer__c == evnt.Customer_Name__r.ParentId){
                                for(Id ids : localCLientMap.get(cc.Client__c))
                                    localCCParentMap.put(ids, cc.Id);

                            }
                        }
                    }
                }
            }
        }

        //Check for banners and fetching banners only
        else if(evnt.Customer_Name__r.RecordType.Name == Constant.CUSTOMER_RECORD_TYPE_L4) {

            //Check weather all banners matched in National Initiative's
            for(Id ids : idsNationalInitiative) {
                if(!customerNationalIds.containsKey(ids)) {
                    nationalInitiativesNotMatched.add(ids);
                }
            }

            //Check weather all Sub banners matched in National Initiative's
            for(Id ids : idsLocalInitiative) {
                if(!customerLocallIds.containsKey(ids)) {
                    localInitiativesNotMatched.add(ids);
                }
            }

            if(localInitiativesNotMatched.size() > 0) {
                List<Local_Initiative__c> linit = [ Select Id, Local_Strategy__r.Client_Customer_Relationship__c, Local_Strategy__r.Client_Customer_Relationship__r.Client__c From Local_Initiative__c Where ID IN: localInitiativesNotMatched ];
                for(Local_Initiative__c ni : linit) {
                    mapOfCCWithLocalInitiative.put(ni.Id, ni.Local_Strategy__r.Client_Customer_Relationship__c);
                }
            }

            //Populating client map for National Banners to get CC's records
            if(nationalInitiativesNotMatched.size() > 0) {
                List<National_Initiative__c> inits = [ Select Id, Strategy__r.Client__c From National_Initiative__c Where ID IN: nationalInitiativesNotMatched ];
                for(National_Initiative__c ni : inits) {
                    System.debug('ni::::::::::' + ni.Strategy__r.Client__c + ' ::: '+ ni.Id);

                    if(mapOfClientWithNationalInitiative.containsKey(ni.Strategy__r.Client__c) ) {
                        mapOfClientWithNationalInitiative.get(ni.Strategy__r.Client__c).add(ni.Id);
                    } else {
                        mapOfClientWithNationalInitiative.put(ni.Strategy__r.Client__c, new List<Id>{ni.Id});
                    }
                }
            }
        }


        //Populating the map of CC with National Intitiative
        if(mapOfClientWithNationalInitiative.size() > 0) {
            List<Client_Customer_Relationship__c> ccs = [Select Id, Client__c, Customer__c From Client_Customer_Relationship__c Where Client__c IN: mapOfClientWithNationalInitiative.keySet() AND Customer__c =: evnt.Customer_Name__c];
            if(ccs.size() > 0) {
                for(Client_Customer_Relationship__c cc : ccs) {
                    if(mapOfClientWithNationalInitiative.containsKey(cc.Client__c) && cc.Customer__c == evnt.Customer_Name__c){
                        for(Id ids : mapOfClientWithNationalInitiative.get(cc.Client__c))
                            mapOfCCWithNationalInitiative.put(ids, cc.Id);

                    }
                }
            }
        }

        /**
        *   Description     :   When National Banner allocated record is not matched with related National initiative
        *   Action          :   Creating National Banner only
        **/
        if(nationalInitiativesNotMatched.size() > 0) {
            nationalBannerToInsert = new List<National_Banner_Allocation__c>();
            for(Id ids : nationalInitiativesNotMatched) {
                if(mapOfCCWithNationalInitiative.containsKey(ids))  {

                    National_Banner_Allocation__c banner = new National_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithNationalInitiative.get(ids);
                    banner.National_Initiative_Lookup__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_non_Editable__c = mapOfNationalInitiatives.get(ids).Target__c;
                    nationalBannerToInsert.add(banner);
                }
            }
            if(nationalBannerToInsert.size() > 0) {
                insert nationalBannerToInsert;

                for(National_Banner_Allocation__c nba : nationalBannerToInsert) {
                    customerNationalIds.put(nba.National_Initiative_Lookup__c, nba);
                }
            }
        }

        //Allocated banners scenario
        if(MapOfNationalSubBannerAllocated.size() > 0) {
            mapNationalSubBannerToInsert = new Map<Id, National_Sub_Banner_Allocation__c>();
            for(Id ids : MapOfNationalSubBannerAllocated.keySet()) {

                if(MapOfNationalSubBannerAllocated.get(ids) != null){
                    National_Sub_Banner_Allocation__c banner = new National_Sub_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithNationalInitiative.get(ids);
                    banner.National_Banner_Allocation__c = MapOfNationalSubBannerAllocated.get(ids).Id;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfNationalInitiatives.get(ids).Target__c;
                    mapNationalSubBannerToInsert.put(ids, banner);
                }
            }

            if(mapNationalSubBannerToInsert.size() > 0) {
                insert mapNationalSubBannerToInsert.values();
                for(Id ids : mapNationalSubBannerToInsert.keyset()) {
                    mapOfSubNationalBanners.put(ids, mapNationalSubBannerToInsert.get(ids));
                }
            }
        }

        /**
        *   Scenario        :   National Sub Banner when there is no Banner found with the related national initiative
        *   Action          :   Creating National Banner and Sub Banner
        **/
        if(nationalSubInitiativesNotMatched.size() > 0) {
            listOfBannerWithSubBanner = new Map<Id, National_Banner_Allocation__c>();
                mapNationalSubBannerToInsert = new Map<Id, National_Sub_Banner_Allocation__c>();

            for(Id ids : nationalSubInitiativesNotMatched) {
                if(mapOfParentCustomerCC.containsKey(ids))  {
                    National_Banner_Allocation__c banner = new National_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfParentCustomerCC.get(ids);
                    banner.National_Initiative_Lookup__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_non_Editable__c = mapOfNationalInitiatives.get(ids).Target__c;
                    listOfBannerWithSubBanner.put(ids, banner);
                }
            }

            if(listOfBannerWithSubBanner.size() > 0) {
                insert listOfBannerWithSubBanner.values();

                for(Id ids : listOfBannerWithSubBanner.keySet()) {
                    National_Sub_Banner_Allocation__c banner = new National_Sub_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithNationalInitiative.get(ids);
                    banner.National_Banner_Allocation__c = listOfBannerWithSubBanner.get(ids).Id;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfNationalInitiatives.get(ids).Target__c;
                    mapNationalSubBannerToInsert.put(ids, banner);
                }

                if(mapNationalSubBannerToInsert.size() > 0) {
                    insert mapNationalSubBannerToInsert.values();

                    for(Id ids : mapNationalSubBannerToInsert.keyset()) {
                        mapOfSubNationalBanners.put(ids, mapNationalSubBannerToInsert.get(ids));
                    }
                }
            }
        }

        /**
        *   @Description     :   Scenario of National Sub banner Unallocated and having banner as unallocated as well.
        *   @Action          :   Creating Banner and Sub Banner
        **/
        if(MapOfNationalSubBannerUNAllocated.size() > 0) {
            mapNationalSubBannerToInsert = new Map<Id, National_Sub_Banner_Allocation__c>();
            listOfBannerWithSubBanner = new Map<Id, National_Banner_Allocation__c>();
            for(Id ids : MapOfNationalSubBannerUNAllocated.keySet()) {

                //Check for initiative is for Allocated banner or not
                if(mapOfParentCustomerCC.containsKey(ids)){
                    National_Banner_Allocation__c banner = new National_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfParentCustomerCC.get(ids);
                    banner.National_Initiative_Lookup__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_non_Editable__c = mapOfNationalInitiatives.get(ids).Target__c;
                    listOfBannerWithSubBanner.put(ids, banner);
                }
            }

            if(listOfBannerWithSubBanner.size() > 0) {
                insert listOfBannerWithSubBanner.values();

                for(Id ids : listOfBannerWithSubBanner.keySet()) {
                    National_Sub_Banner_Allocation__c banner = new National_Sub_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithNationalInitiative.get(ids);
                    banner.National_Banner_Allocation__c = listOfBannerWithSubBanner.get(ids).Id;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfNationalInitiatives.get(ids).Target__c;
                    mapNationalSubBannerToInsert.put(ids, banner);
                }

                if(mapNationalSubBannerToInsert.size() > 0) {
                    insert mapNationalSubBannerToInsert.values();

                    for(Id ids : mapNationalSubBannerToInsert.keyset()) {
                        mapOfSubNationalBanners.put(ids, mapNationalSubBannerToInsert.get(ids));
                    }
                }
            }
        }

        //------------------ LOCAL BANNER STARTS HERE -----------------------------------------------------
        /**
        *   Description  :   When Local Banner allocated record is not found with related National initiative
        **/
        if(localInitiativesNotMatched.size() > 0) {
            localBannerToInsert = new List<Local_Banner_Allocation__c>();
            for(Id ids : localInitiativesNotMatched) {
                if(mapOfCCWithLocalInitiative.containsKey(ids)) {

                    Local_Banner_Allocation__c banner = new Local_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithLocalInitiative.get(ids);
                    banner.Local_Initiative__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfLocallInitiatives.get(ids).Target__c;
                    localBannerToInsert.add(banner);

                }
            }
            if(localBannerToInsert.size() > 0) {
                insert localBannerToInsert;

                for(Local_Banner_Allocation__c nba : localBannerToInsert) {
                    customerLocallIds.put(nba.Local_Initiative__c, nba);
                }
            }
        }

        /**
         *      Description     :   Scenario when Unallocated Sub Banner and Allocated Banner
         **/
        if(MapOfLocalSubBannerAllocated.size() > 0) {
            Map<Id, Local_Sub_Banner_Allocation__c> mapLocalSubBannerToInsert = new Map<Id, Local_Sub_Banner_Allocation__c>();

            for(Id ids : MapOfLocalSubBannerAllocated.keySet()) {

                Local_Sub_Banner_Allocation__c banner = new Local_Sub_Banner_Allocation__c();
                banner.Client_Customer_Relationship__c = mapOfCCWithLocalInitiative.get(ids);
                banner.Status__c = Constant.STATUS_ALLOCATED;
                banner.Local_Banner_Allocation__c = MapOfLocalSubBannerAllocated.get(ids).Id;
                banner.Auto_Created__c = true;
                banner.Allocated_Traget__c = mapOfLocallInitiatives.get(ids).Target__c;
                mapLocalSubBannerToInsert.put(ids, banner);
            }

            if(mapLocalSubBannerToInsert.size() > 0) {
                insert mapLocalSubBannerToInsert.values();

                for(Id nba : mapLocalSubBannerToInsert.keySet()) {
                    mapOfSubLocalBanners.put(nba, mapLocalSubBannerToInsert.get(nba));
                }
            }
        }

        /**
        *      Scenario        :       Local Sub Banner when there is no Sub Banner found with the related national initiative
        **/
        if(localSubInitiativesNotMatched.size() > 0) {
            Map<Id, Local_Banner_Allocation__c> mapOfLocalBannerToInsert = new Map<Id, Local_Banner_Allocation__c>();
            Map<Id, Local_Sub_Banner_Allocation__c> mapLocalSubBannerToInsert = new Map<Id, Local_Sub_Banner_Allocation__c>();

            for(Id ids : localSubInitiativesNotMatched) {
                if(localCCParentMap.containsKey(ids))  {
                    Local_Banner_Allocation__c banner = new Local_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = localCCParentMap.get(ids);
                    banner.Local_Initiative__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfLocallInitiatives.get(ids).Target__c;
                    mapOfLocalBannerToInsert.put(ids, banner);
                }
            }

            if(mapOfLocalBannerToInsert.size() > 0) {
                insert mapOfLocalBannerToInsert.values();

                for(Id ids : mapOfLocalBannerToInsert.keySet()) {
                    Local_Sub_Banner_Allocation__c banner = new Local_Sub_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = mapOfCCWithLocalInitiative.get(ids);
                    banner.Local_Banner_Allocation__c = mapOfLocalBannerToInsert.get(ids).Id;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Traget__c = mapOfLocallInitiatives.get(ids).Target__c;
                    mapLocalSubBannerToInsert.put(ids, banner);
                }

                if(mapLocalSubBannerToInsert.size() > 0) {
                    insert mapLocalSubBannerToInsert.values();

                    for(Id ids : mapLocalSubBannerToInsert.keyset()) {
                        mapOfSubLocalBanners.put(ids, mapLocalSubBannerToInsert.get(ids));
                    }
                }
            }
        }

        /**
            Description     :   Scenario where Unallocated Local Sub Banner has the unallocated banner as well.
        **/
        if(MapOfLocalSubBannerUNAllocated.size() > 0) {
            Map<Id, Local_Banner_Allocation__c> mapOfLocalBannerToInsert = new Map<Id, Local_Banner_Allocation__c>();
            Map<Id, Local_Sub_Banner_Allocation__c> mapLocalSubBannerToInsert = new Map<Id, Local_Sub_Banner_Allocation__c>();

            for(Id ids : MapOfLocalSubBannerUNAllocated.keySet()) {

                //Check for initiative is for Allocated banner or not
                if(MapOfLocalSubBannerUNAllocated.containsKey(ids) && localCCParentMap.containsKey(ids)){
                    Local_Banner_Allocation__c banner = new Local_Banner_Allocation__c();
                    banner.Client_Customer_Relationship__c = localCCParentMap.get(ids);
                    banner.Local_Initiative__c = ids;
                    banner.Status__c = Constant.STATUS_ALLOCATED;
                    banner.Auto_Created__c = true;
                    banner.Allocated_Target__c = mapOfLocallInitiatives.get(ids).Target__c;
                    mapOfLocalBannerToInsert.put(ids, banner);
                }
            }

            //Inserting banner to assign in Sub banners
            if(mapOfLocalBannerToInsert.size() > 0) {
                insert mapOfLocalBannerToInsert.values();

                for(Id ids : MapOfLocalSubBannerUNAllocated.keySet()) {
                    if(MapOfLocalSubBannerUNAllocated.get(ids) != null){
                        Local_Sub_Banner_Allocation__c banner = new Local_Sub_Banner_Allocation__c();
                        banner.Client_Customer_Relationship__c = mapOfCCWithLocalInitiative.get(ids);
                        banner.Status__c = Constant.STATUS_ALLOCATED;
                        banner.Local_Banner_Allocation__c = mapOfLocalBannerToInsert.get(ids).Id;
                        banner.Auto_Created__c = true;
                        banner.Allocated_Traget__c = mapOfLocallInitiatives.get(ids).Target__c;
                        mapLocalSubBannerToInsert.put(ids, banner);
                    }
                }

                if(mapLocalSubBannerToInsert.size() > 0) {
                    insert mapLocalSubBannerToInsert.values();

                    for(Id nba : mapLocalSubBannerToInsert.keySet()) {
                        mapOfSubLocalBanners.put(nba, mapLocalSubBannerToInsert.get(nba));
                    }
                }
            }
        }
    }

    /**
     *  @Description    :   Method for Save button (Without any Validation saving Disposition data)
     *  @return         :   pageReference
     *  @paramt         :   null
     **/
    public pageReference createDisposition() {

        listOfCVEDtoInsert = new List<Customer_Visit_Execution_Detail__c>();
        isSaved = false;

        Boolean isItemStatus = false;
        Boolean doProcess = false;

        //Check for the items list
        if(listOfItems.size() > 0) {

            //Loop through the items wrapper of initiative
            for(itemWrapper it : listOfItems) {
                if(it.cved.Status__c == null) {
                    isItemStatus = true;
                }
                system.debug('isItemStatus3---> '+ isItemStatus);
                system.debug('**initDesposition.Overal_Status__c -' +initDesposition.Overal_Status__c + '**it.cved.Status__c -' +it.cved.Status__c);

                     if(initDesposition.Overal_Status__c == Constant.STATUS_COMPLETED && it.cved.Status__c == Constant.STATUS_ACCEPTED){

                       if(String.isBlank(it.cved.Customer_Code__c) || it.cved.Retail_Availability_Date__c == null ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Customer Code or Retail Availability cannot be blank when Overall Status is Completed !'));
                        return null;
                    }
                }

                if(it.cved.Status__c == Constant.STATUS_REJECTED) {
                    if(it.cved.Rejected_Reason__c == Constant.STATUS_OTHER) {
                        if(String.isBlank(it.rejectComment)) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Comments cannot be blank if Reason of Rejection is Other!'));
                            return null;
                        }
                    } else if(it.cved.Rejected_Reason__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Reason of Rejction is required for Rejected status!'));
                        return null;
                    }
                } else if(it.cved.Status__c == Constant.STATUS_PENDING ) {
                    if(it.cved.Pending_Reason__c == Constant.STATUS_OTHER && String.isBlank(it.pendingCommnent)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Comments cannot be blank if Pending reason is Other!'));
                        return null;

                    } else if(it.cved.Pending_Reason__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Pending reason is required for Pending status!'));
                        return null;
                    }
                }

                doProcess = true;
            }
        }

        if(listOfOtherItems.size() > 0) {
            doProcess = false;
            //Loop through the others item wrapper of initiative
            for(itemWrapper it : listOfOtherItems) {
                if(!isItemStatus)
                {
                    system.debug('isItemStatus2---> '+ isItemStatus);
                    isItemStatus = false;
                }
                if(it.cved.Status__c == null) {
                    isItemStatus = true;
                }
                        system.debug('isItemStatus1---> '+ isItemStatus);
                if(it.cved.Status__c == Constant.STATUS_REJECTED) {
                    if(it.cved.Rejected_Reason__c == Constant.STATUS_OTHER) {
                        if(String.isBlank(it.rejectComment)) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Comments cannot be blank if Reason of Rejection is Other!'));
                            return null;
                        }
                    } else if(it.cved.Rejected_Reason__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Reason of Rejection is required for Rejected status!'));
                        return null;
                    }
                } else if(it.cved.Status__c == Constant.STATUS_PENDING ) {
                    if(it.cved.Pending_Reason__c == Constant.STATUS_OTHER && String.isBlank(it.pendingCommnent)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Comments cannot be blank if Pending reason is Other!'));
                        return null;

                    } else if(it.cved.Pending_Reason__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Pending reason is required for Pending status!'));
                        return null;
                    }
                }
                doProcess = true;

            }
        }
        system.debug('isItemStatus---> '+ isItemStatus);
        if(initDesposition.Overal_Status__c == Constant.STATUS_COMPLETED && isItemStatus == true ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Status cannot be blank, if Overall Status is Completed!'));
            return null;
        } else {

            if(initDesposition.Overal_Status__c != null) {

                try {
                    if(doProcess) {

                        //Creating Banner and Sub Banner
                        createBannerAndSubBannerForInitiative();

                        //Creating Disposition records
                        if(evnt.Initiative_Disposition__c == null) {

                            Date te = date.newinstance(evnt.StartDateTime.year(), evnt.StartDateTime.month(), evnt.StartDateTime.day());
                            initDesposition.Name__c = evnt.Customer_Name__r.Name + ' '+ String.valueof(te) + ' Initiative Disposition' ;
                            initDesposition.Customer_Visit__c = evnt.WhatId;
                            insert initDesposition;

                            evnt.Initiative_Disposition__c = initDesposition.Id;
                            update evnt;
                        }

                        if(listOfItems.size() > 0) {
                            for(itemWrapper it : listOfItems) {
                                Customer_Visit_Execution_Detail__c cved = createCVED(it);
                                listOfCVEDtoInsert.add(cved);
                            }
                        }

                        if(listOfOtherItems.size() > 0) {
                            for(itemWrapper it : listOfOtherItems) {
                                Customer_Visit_Execution_Detail__c cved = createCVED(it);
                                listOfCVEDtoInsert.add(cved);
                            }
                        }

                        //Check for the size and insert
                        if(listOfCVEDtoInsert.size() > 0) {
                            upsert listOfCVEDtoInsert;

                            //Method to update banners and sub banners data
                            UpdateBannerSubBanner updateBanners = new UpdateBannerSubBanner();
                            updateBanners.populateBannerSubBanner(listOfCVEDtoInsert);

                            initDesposition.Id = evnt.Initiative_Disposition__c;
                            initDesposition.Overal_Status__c = initDesposition.Overal_Status__c;
                            initDesposition.Comments__c = initDesposition.Comments__c;
                            update initDesposition;
                            isSaved = true;
                            init();
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Data have been saved successfully.'));
                            return null;
                        }
                    }
                } catch( Exception e) {
                   system.debug('**e - '+ e);
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, please contact your System Administrator.'));
                   return null;
                }
            } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Overall status is required.'));
                    return null;
            }
        }
        return null;
    }

    /**
     *  @Description    :   Method to create the Initiative Disposition Detail
     *  @return         :   pageReference
     *  @param          :   null
     **/
    public pageReference saveAndExit() {

        try {
            listOfCVEDtoInsert = new List<Customer_Visit_Execution_Detail__c>();

            pageReference refr = createDisposition();
            if(evnt.Initiative_Disposition__c != null && isSaved == true){
                PageReference pfRef = new PageReference('/'+evnt.Initiative_Disposition__c);
                return pfRef ;
            }

        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, Please contact System Administrator!'));
            return null;
        }
        return null;
    }

    /**
     *  @Description    :   Method to create banner and Sub Banner for the initiative
     *  @return         :   Customer_Visit_Execution_Detail__c
     *  @param          :   itemWrapper
     **/
    private Customer_Visit_Execution_Detail__c createCVED(itemWrapper it) {
        Customer_Visit_Execution_Detail__c cved = new Customer_Visit_Execution_Detail__c();

        cved.Status__c = it.cved.Status__c;

        //Check for national or Local
        if(it.cved.Id != null) {
            cved.Id = it.cved.Id;
        }

        //Check for national or Local
        if(it.initiativeType == Constant.ISNATIONAL) {
            cved.System_National_Initiative__c = it.initId;
        } else if(it.initiativeType == Constant.ISLOCAL) {
            cved.System_Local_Initiative__c = it.initId;
        }


        //Check weather Events Initiative disposition
        if(evnt.Initiative_Disposition__c != null) {
            cved.Customer_Visit_Execution__c = evnt.Initiative_Disposition__c;
        } else if(initDesposition.Id != null) {
            cved.Customer_Visit_Execution__c = initDesposition.Id;
        }

        //Check for Accepted status
        if(it.cved.Status__c == Constant.STATUS_ACCEPTED) {
            cved.Customer_Code__c = it.cved.Customer_Code__c;
            cved.Shipment_Date__c = it.cved.Shipment_Date__c;
            cved.Retail_Availability_Date__c = it.cved.Retail_Availability_Date__c;
            cved.Forecast__c = it.cved.Forecast__c;
            cved.Pipeline_UOM__c = it.cved.Pipeline_UOM__c;
            cved.Comments__c =  it.acceptComment;
            cved.Rejected_Reason__c = '';
            cved.Pending_Reason__c = '';
        }

        //Check for Rejected status
        if(it.cved.Status__c == Constant.STATUS_REJECTED) {
            cved.Rejected_Reason__c = it.cved.Rejected_Reason__c;
            cved.Comments__c =  it.rejectComment;

            cved.Customer_Code__c = '';
            cved.Shipment_Date__c = null;
            cved.Retail_Availability_Date__c = null;
            cved.Forecast__c = '';
            cved.Pipeline_UOM__c = '';
            cved.Pending_Reason__c = '';

        }

        //Check for Pending status
        if(it.cved.Status__c == Constant.STATUS_PENDING) {
            cved.Pending_Reason__c = it.cved.Pending_Reason__c;
            cved.Comments__c = it.pendingCommnent;

            if(it.pendingFollowup.Follow_Up_Date__c != null)
                cved.Follow_Up_Date__c = it.pendingFollowup.Follow_Up_Date__c;

            cved.Customer_Code__c = '';
            cved.Shipment_Date__c = null;
            cved.Retail_Availability_Date__c = null;
            cved.Forecast__c = '';
            cved.Pipeline_UOM__c = '';
            cved.Rejected_Reason__c = '';

        }

        //Check for Not Proposed status
        if(it.cved.Status__c == Constant.STATUS_NOT_PROPOSED) {
            cved.Comments__c = it.notProComment;

            if(it.notProposedFollowup.Follow_Up_Date__c != null)
                cved.Follow_Up_Date__c = it.notProposedFollowup.Follow_Up_Date__c;

            cved.Customer_Code__c = '';
            cved.Shipment_Date__c = null;
            cved.Retail_Availability_Date__c = null;
            cved.Forecast__c = '';
            cved.Pipeline_UOM__c = '';
            cved.Rejected_Reason__c = '';
            cved.Pending_Reason__c = '';


        }

        //Lookup's of Banner and Sub Banner's
        if(customerLocallIds.containsKey(it.initId))
            cved.Local_Banner_Allocation__c = customerLocallIds.get(it.initId).Id;

        if(mapOfSubLocalBanners.containsKey(it.initId))
            cved.Local_Sub_Banner_Allocation__c = mapOfSubLocalBanners.get(it.initId).Id;

        if(customerNationalIds.containsKey(it.initId))
            cved.National_Banner_Allocation__c = customerNationalIds.get(it.initId).Id;

        if(mapOfSubNationalBanners.containsKey(it.initId))
            cved.National_Sub_Banner_Allocation__c = mapOfSubNationalBanners.get(it.initId).Id;

        return cved;
    }

    public PageReference exit(){
        try{
            if(initDesposition != null && initDesposition.Id != null){
                PageReference pageRef = new PageReference('/'+initDesposition.Id);
                return pageRef;
            }
            else{
                PageReference pageRef = new PageReference('/'+evnt.Id);
                return pageRef;
            }
        }
        Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }
}