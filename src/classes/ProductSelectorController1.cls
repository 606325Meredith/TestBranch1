/**
 *  Description     :   National strategy page with banner and sub banner relared list.
 *
 *  Created By      :   Abhishek Tripathi
 *
 *  Created Date    :   8/09/2016
 *  Version         :   V1.0
 * Modification Log :
 -----------------------------------------------------------------------------
 * Developer        Date                   Description
 * ----------------------------------------------------------------------------
 * CoastalCloud      3/23/2017
 *                      Added new code to filter the display of the CCR records
 *                      for the ASO user.  Only shows Allocated NBAs and Sub-mapSubBanners
 *                      where this user has read/write access to the CCR
 **/
public with sharing class ProductSelectorController1{

    public Map<Id, BannerWrapper> bannerResults {get;set;}
    public map<Id,BannerWrapper> bannerResultsOffset {get;set;}
    public String bannerResultsList{
        get{
            return JSON.serialize(bannerResults.values());
        }set;}
    public Account client{get;set;}
    public National_Initiative__c nationalInitiative{get;set;}
    public Integer page{get;set;}
    public Integer totalRecs{get;set;}
    public Boolean isCLTUser{get;set;}//User belongs to Customer Leadership Team profile
    public Integer totalSubBannerRecs{
        public get{
            Integer subBannerCount = 0;
            for(BannerWrapper bw: bannerResults.values())
            {
               for(NBAWrapper nba:bw.nbaWrap)
               {
                    System.debug('sub banner id----'+nba.acId);
                    subBannerCount++;
               }
            }
            System.debug('subBannerCount-----'+subBannerCount);
            return subBannerCount;
        }
        public set;
    }
    public integer totalbannerRecs{get;set;}
    private integer OffsetSize = 0;
    private integer LimitSize= 5;
    public Integer totalPages{get;set;}
    public Static List<Account> childAccountsL5 { get;set; }
    public Id ccId ;
    public String selectCustomerType { get; set; }
    private string clientId;
    private String nationalTarget { get; set; }
    public String searchedName { get; set; }
    public boolean ProductSKUflag{get;set;}
    public boolean ProductGroupflag{get;set;}
    public boolean Brandflag{get;set;}
    public boolean Noflag{get;set;}
    public map<id,Id> mapCCRSubBanner {get;set;}
    public National_Banner_Allocation__c nba{get;set;}
    public Client_Customer_Relationship__c ccr{get;set;}
    private List<SelectOption> wamItems;
    //private Map<Id, BannerWrapper> newMapResults ;
    public list<string> cctBannerSelections {get;set;}  //holds the values of the selected Client Customer Tier Banner checkboxes
    public list<string> cctSubBannerSelections {get;set;}  //holds the values of the selected Client Customer Tier Sub-Banner checkboxes

    public String selectedBanners{get;set;}
    public String selectedSubBanners{get;set;}
    public String displayRange{get;set;}

    public String returnCode{get;set;}
    public String errorMessage{get;set;}
    public String allocateAllValue{get;set;}
    public String queryType{get;set;}
    Set<String> allocatedNBA_CCRIds {get;set;}
    String currentUserId;
    //Set<String> allocatedNSBA_CCRIds {get;set;}

    public class UpdateAllocationResponse
    {
        public Integer returnCode{get;set;}
        public String errorMessage{get;set;}
        //public Boolean hasMoreRecords{get;set;}
    }
    public ProductSelectorController1(){

        nba = new National_Banner_Allocation__c();
        allocatedNBA_CCRIds = new Set<String>();
        //allocatedNSBA_CCRIds = new Set<String>();
        ccr = new Client_Customer_Relationship__c();
        client = new Account();
        nationalInitiative = new National_Initiative__c();
        ccId = null;
        nationalTarget = '';
        totalRecs = 0;
        totalbannerRecs = 0;
        String initIds = ApexPages.currentPage().getParameters().get('initiativeId');
        queryType = ApexPages.currentPage().getParameters().get('type');
        nationalInitiative = [Select Initiatives__c,Objectives__c, Has_a_Target__c, Initiative_Start_Date__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Priority__c,Product_SKU__c,Comments__c,Strategy__c,Strategy__r.Client__c,Product_Group__c ,Brand__c from National_Initiative__c where id=:initIds];
        clientId = nationalInitiative.Strategy__r.Client__c;
        System.debug('nationalInitiative::::::::: ' + nationalInitiative);
        this.page = 1;
        cctBannerSelections = new List<String>();
        cctSubBannerSelections = new List<String>();

        childAccountsL5 = new List<Account>();
        //Fetching the picklist values from the Account object
        Schema.DescribeFieldResult dfr = Account.Customer_Type__c.getDescribe();
        //newMapResults = new Map<Id, BannerWrapper>();
        selectCustomerType = '';
        searchedName = '';

        //If user belongs to Customer Leadership Team profile, a message is displayed to him:
        String profileId = UserInfo.getProfileId();
        Profile p = [select Name from Profile where Id=:profileId];
        if(p.Name == 'Customer Leadership Team') {
            isCLTUser = true;
        }

        // Get the CCR IDs from the NBAs that have been allocated for the current National Initiative if the 'Type=SBA' parameter is passed in the URL.
        // Only show the allocated NBAs when the current logged in user has R/W access on related CCR
        if (queryType == 'SBA') {
            List<Id> allCCRIds = new List<Id>();
            for (National_Banner_Allocation__c nbaRec : [SELECT Client_Customer_Relationship__c FROM National_Banner_Allocation__c WHERE National_Initiative_Lookup__c = :initIds and Status__c = 'Allocated']) {
                allCCRIds.add(nbaRec.Client_Customer_Relationship__c);
            }

            System.debug('allCCRIds-----'+allCCRIds);
            //Get all CCATMs related to the CCRs. Only pick CCRs where the current user's CCATM has CC_Access__c = 'Read/Write'
            currentUserId = UserInfo.getUserId();

            if(!allCCRIds.isEmpty()) {
                for(Client_Customer_Account_Team__c  ccatm: [SELECT Client_Customer_Access__c,User__r.name,User__c,source__c, Client_Customer_Relationship__c, Client_Customer_Relationship__r.name, Id
                    FROM Client_Customer_Account_Team__c
                    WHERE User__c = :currentUserId
                    AND Client_Customer_Relationship__c IN: allCCRIds] )
                {
                    if(ccatm.Client_Customer_Access__c == AcostaConstants.readWriteAccess) {
                        allocatedNBA_CCRIds.add(ccatm.Client_Customer_Relationship__c);
                    }
                }
                System.debug('CCRs with Allocated NBA records ====> '+allocatedNBA_CCRIds);
            }//end empty check on allCCRIds

        }//end check on queryType

        if(nationalInitiative.Target__c != '' && nationalInitiative.Target__c != null && nationalInitiative.Unit_of_Measure__c == 'Percent') {
            nationalTarget = nationalInitiative.Target__c;
        }
        if(string.isnotblank(nationalInitiative.Product_SKU__c))
        {
            ProductSKUflag = true;
            Brandflag = false;
            ProductGroupflag  = false;
            Noflag = false;
        }
        else if(string.isnotblank(nationalInitiative.Product_Group__c))
        {
            ProductGroupflag = true;
            Brandflag = false;
            ProductSKUflag  = false;
            Noflag = false;
        }
        else if(string.isnotblank(nationalInitiative.Brand__c))
        {
            Brandflag = true;
            ProductSKUflag  = false;
            ProductGroupflag  = false;
            Noflag = false;
        }
        else if(string.isblank(nationalInitiative.Product_SKU__c) && string.isblank(nationalInitiative.Product_Group__c) && string.isblank(nationalInitiative.Brand__c))
        {
            Brandflag = true;
            ProductSKUflag  = false;
            ProductGroupflag  = false;
            Noflag = true;
        }
        searchbanners();
    }

    public list<SelectOption> getMyCCTCheckboxes(){
        list<SelectOption> options = new list<SelectOption>();

        sObjectType objectType = Schema.getGlobalDescribe().get('Client_Customer_Relationship__c');
        if(objectType==null) return options;

        Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
        Schema.SObjectField theField = objDescribe.fields.getMap().get('Client_Customer_Tier__c');
        if(theField==null) return options;

        for (Schema.PicklistEntry a :theField.getDescribe().getPickListValues()) {
            options.add(new SelectOption(a.getValue(),' Tier ' + a.getLabel()));
            //options.add(new SelectOption(a.getLabel(), a.getValue()));
            //system.debug('options =====> '+options);
        }

        return options;
    }

    //Method to search the records from the picklist and search box
    public pageReference filterList()  {

        searchbanners();

        Map<Id, BannerWrapper> newMapResults = new Map<Id, BannerWrapper>();

        Set<String> selected = new Set<String>();
        Set<string> selectedSubType = new set<string>();
        Set<String> selectedPurchasingOptions = new set<String>();

        if(nba.System_Customer_Type_Multi__c != null) {
            for(String str : nba.System_Customer_Type_Multi__c.split(';')){
                selected.add(str.toLowerCase());
            }
        }

        if(nba.System_Customer_Sub_Type__c  != null) {
            for(String str : nba.System_Customer_Sub_Type__c.split(';')){
                selectedSubType.add(str.toLowerCase());
            }
        }

        if(ccr.Purchasing_Options__c  != null) {
            for(String str : ccr.Purchasing_Options__c.split(';')){
                selectedPurchasingOptions.add(str.toLowerCase());
            }
        }

        if(selected.size() > 0 || (searchedName != null && searchedName != '') || selectedSubType.size()>0)
        {
            if(searchedName != null && searchedName != '') {
                system.debug('searchedName-->' + searchedName );
                for(Id ids : bannerResults.keySet()) {
                system.debug('bannerResults.get(ids).name-->' + bannerResults.get(ids).name);
                    if(bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                        newMapResults.put(ids, bannerResults.get(ids));
                    }
                }
            }

            if(selected.size() > 0 && selectedSubType.size() == 0 && (searchedName == null || searchedName == '') ) {
                for(Id ids : bannerResults.keySet()) {
                system.debug('bannerResults.get(ids).customertype-->' + bannerResults.get(ids).customertype);
                    if(!String.isBlank(bannerResults.get(ids).customertype)) {
                        if(selected.contains(bannerResults.get(ids).customertype.toLowerCase())) {
                            system.debug('Test4--->');
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                    system.debug('newMapResults-->' + newMapResults.size());
                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customertype)){
                            if(selected.contains(nba.customertype.toLowerCase())) {
                            system.debug('Test5--->');
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                    system.debug('newMapResults7-->' + newMapResults.size());
                }
            }

            if(selected.size() > 0 && selectedSubType.size() == 0 && (searchedName != null && searchedName != '') ) {
                for(Id ids : bannerResults.keySet()) {
                system.debug('bannerResults.get(ids).customertype-->' + bannerResults.get(ids).customertype);
                    if(!String.isBlank(bannerResults.get(ids).customertype)) {
                        if(selected.contains(bannerResults.get(ids).customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                            system.debug('Test4--->');
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                    system.debug('newMapResults-->' + newMapResults.size());
                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customertype)){
                            if(selected.contains(nba.customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                            system.debug('Test5--->');
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                    system.debug('newMapResults7-->' + newMapResults.size());
                }
            }

            if(selectedSubType.size() > 0 && selected.size() == 0 && (searchedName != null && searchedName != '')) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customerSubType)) {
                        if(selectedSubType.contains(bannerResults.get(ids).customerSubType.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }

                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customerSubType)){
                            if(selectedSubType.contains(nba.customerSubType.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            }

            if(selectedSubType.size() > 0 && selected.size() == 0 && (searchedName == null || searchedName == '')) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customerSubType)) {
                        if(selectedSubType.contains(bannerResults.get(ids).customerSubType.toLowerCase())){
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }

                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customerSubType)){
                            if(selectedSubType.contains(nba.customerSubType.toLowerCase())){
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            }

            if(selectedSubType.size() > 0 && selected.size() > 0 && (searchedName == null || searchedName == '')) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customerSubType) && !String.isBlank(bannerResults.get(ids).customertype)) {
                        if(selectedSubType.contains(bannerResults.get(ids).customerSubType.toLowerCase()) && selected.contains(bannerResults.get(ids).customertype.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }

                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customerSubType)){
                            if(selectedSubType.contains(nba.customerSubType.toLowerCase()) && selected.contains(bannerResults.get(ids).customertype.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            }

            if(selectedSubType.size() > 0 && selected.size() > 0 && (searchedName != null && searchedName != '')) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customerSubType) && !String.isBlank(bannerResults.get(ids).customertype) && (searchedName != null && searchedName != '')) {
                        if(selectedSubType.contains(bannerResults.get(ids).customerSubType.toLowerCase()) && selected.contains(bannerResults.get(ids).customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }

                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customerSubType)){
                            if(selectedSubType.contains(nba.customerSubType.toLowerCase()) && selected.contains(bannerResults.get(ids).customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            }

            system.debug('newMapResults3-->' + newMapResults);
            totalRecs = newMapResults.size();
            system.debug('totalRecs -->' + totalRecs );
            if(newMapResults.size() > 0) {
                bannerResultsOffset.clear();
                Integer count = (newMapResults.size() > LimitSize ?  LimitSize : newMapResults.size());
                OffsetSize = 0;
                bannerResults.clear();
                for(Integer j = OffsetSize;j < count;j++){
                        bannerResultsOffset.put(newMapResults.values().get(j).ids ,newMapResults.values().get(j));
                }
                for(Integer k = 0;k < newMapResults.size();k++){
                        bannerResults.put(newMapResults.values().get(k).ids ,newMapResults.values().get(k));
                }
            } else {
                bannerResultsOffset.clear();
            }
        } else {
            //newMapResults.clear();
            searchbanners();
        }

        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        computeDisplayRange(totalRecs);

        PageReference pref = new PageReference('/apex/BannerUI1?initiativeId='+nationalInitiative.Id);
        pref.setRedirect(false);
        return pref ;
    }//end filterList

    //Method called on the load of the page
    public void searchbanners(){

        string strQuery;
        Set<String> selected = new Set<String>();
        Set<string> selectedSubType = new set<string>();
        Set<String> selectedPurchasingOptions = new set<String>();
        Set<String> selectedBannerCCTOptions = new set<String>();
        Set<String> selectedSubBannerCCTOptions = new set<String>();
        Boolean WAM = False;

        if(nba.System_Customer_Type_Multi__c != null) {
            for(String str : nba.System_Customer_Type_Multi__c.split(';')){
                selected.add(str.toLowerCase());
            }
        }

        if(nba.System_Customer_Sub_Type__c  != null) {
            for(String str : nba.System_Customer_Sub_Type__c.split(';')){
                selectedSubType.add(str.toLowerCase());
            }
        }

        if(ccr.Purchasing_Options__c  != null) {
            for(String str : ccr.Purchasing_Options__c.split(';')){
                selectedPurchasingOptions.add(str.toLowerCase());
            }
        }

        if(cctBannerSelections != null) {
            for(String str : cctBannerSelections){
                selectedBannerCCTOptions.add(str.toLowerCase());
            }
        }

        if(cctSubBannerSelections != null) {
            for(String str : cctSubBannerSelections){
                selectedSubBannerCCTOptions.add(str.toLowerCase());
            }
        }
        system.debug('selectedPurchasingOptions =====> '+selectedPurchasingOptions);
        system.debug('selectedBannerCCTOptions =====> '+selectedBannerCCTOptions);
        system.debug('selectedSubBannerCCTOptions =====> '+selectedSubBannerCCTOptions);

        if(client.WAM__c == true) {
            WAM = true;
        }

        System.debug('clientId::::' + clientId);
        if(string.isNOTBlank(clientId))
        {
            //Fetching the record type ids
            //Get the record type schema
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Id rtCustomerSBL5 = rtMapByName.get('Customer - Sub Banner - L5').getRecordTypeId();
            Id rtCustomerSBL4 = rtMapByName.get('Customer - Banner - L4').getRecordTypeId();
            system.debug('clientId-->' + clientId);
            strQuery = 'Select Id,Name,Customer__c,WAM__c,Client_Customer_Tier__c,Customer__r.Customer_Type__c,Customer__r.Customer_Sub_Type__c,Customer__r.RecordType.Name,Customer__r.Name from Client_Customer_Relationship__c where Client__c =: clientId and Customer__r.recordType.Id =: rtCustomerSBL4 and Status__c = \'Active\'';
            if(String.isNotBlank(searchedName )) {
                strQuery+=' AND (Customer__r.Name Like \'%' +String.escapeSingleQuotes(searchedName ) +'%\')';
            }
            if(selected.size() > 0) {
                strQuery+=' AND (Customer__r.Customer_Type__c IN : selected)';
            }
            if(selectedSubType.size() > 0) {
                strQuery+=' AND (Customer__r.Customer_Sub_Type__c IN : selectedSubType)';
            }
            if(selectedPurchasingOptions.size() > 0) {
                strQuery+=' AND (Parent_Relationship__c = null AND Purchasing_Options__c IN : selectedPurchasingOptions)';
            }
            if(WAM) {
                strQuery+=' AND (Parent_Relationship__c = null AND WAM__c = true)';
            }
            if(selectedBannerCCTOptions.size() > 0) {
                strQuery+=' AND (Parent_Relationship__c = null AND Client_Customer_Tier__c IN : selectedBannerCCTOptions)';
            }
            if(queryType == 'SBA') {
                strQuery+=' AND (Id IN : allocatedNBA_CCRIds)';
            }

            string strQueryWithoutOffset ;
            bannerResults = new Map<Id, BannerWrapper>();

            strQueryWithoutOffset = strQuery;
            List<Client_Customer_Relationship__c> listClientCustRel = Database.query(strQueryWithoutOffset );
            totalbannerRecs = (listClientCustRel !=null && listClientCustRel.size()>0)?listClientCustRel.size():0;
            //strQuery+=' LIMIT :LimitSize OFFSET :OffsetSize';
             System.debug('strQuery::::::::::' + strQuery);
            List<Client_Customer_Relationship__c> listCCRel = Database.query(strQuery);
            Integer i = 0;
            Set<Id> ids = new Set<Id>();

            System.debug('listCCRel::::::::::' + listCCRel);
            for(Client_Customer_Relationship__c ccRel : listCCRel)
            {
                if(ccRel.Customer__r.RecordType.Name == 'Customer - Banner - L4' && !ids.contains(ccRel.Customer__r.Id))
                {
                    System.debug('ccRel.Id:::::::' + ccRel.Id);
                    ids.add(ccRel.Customer__r.Id);
                    BannerWrapper wrap = new BannerWrapper();
                    wrap.name = ccRel.Customer__r.Name;
                    wrap.index += i;
                    wrap.ids = ccRel.Customer__r.Id;
                    wrap.proposed = nationalTarget;
                    wrap.checked = false;
                    wrap.ccIds = ccRel.Id;
                    system.debug('ccRel.Customer__r.Customer_Type__c-->' + ccRel.Customer__r.Customer_Type__c);
                    wrap.customerType = ccRel.Customer__r.Customer_Type__c;
                    wrap.customerSubType = ccRel.Customer__r.Customer_Sub_Type__c;
                    wrap.wam = ccRel.WAM__c;
                    wrap.clientCustomerTier = ccRel.Client_Customer_Tier__c;
                    bannerResults.put(ccRel.Customer__r.Id, wrap);
                    i++;
                }
            }

            if(OffsetSize > 2000){
                OffsetSize = 2000;
            }

            if(totalbannerRecs >2000) {
                totalbannerRecs =2000;
            }

            Set<Id> accIds = new Set<Id>();
            Set<Id> SubBannerids = new Set<Id>();
            map<Id,Account> mapSubBanners = new map<Id,Account>();
            Map<Id, List<NBAWrapper>> mapOfNBAWrap = new Map<Id, List<NBAWrapper>>();

            String readWriteAccessString = AcostaConstants.readWriteAccess;
            string strQuerySubBanners =  'select id,Customer__c,WAM__c,Client_Customer_Tier__c,Customer__r.ParentId,Customer__r.Name,Customer__r.Customer_Type__c,Customer__r.Customer_Sub_Type__c,(SELECT Client_Customer_Access__c,User__r.name,User__c,source__c, Client_Customer_Relationship__c, Client_Customer_Relationship__r.name, Id FROM Client_Customer_Account_Teams__r WHERE User__c = :currentUserId AND Client_Customer_Access__c =: readWriteAccessString) from Client_Customer_Relationship__c where Customer__r.ParentId IN: ids and Client__c =: ClientId and (Customer__r.recordType.Id =: rtCustomerSBL5) and Status__c = \'Active\'';

            if(String.isNotBlank(searchedName )) {
                strQuerySubBanners +=' AND (Customer__r.Name Like \'%' +String.escapeSingleQuotes(searchedName ) +'%\')';
            }
            if(selected.size() > 0) {
                strQuerySubBanners +=' AND (Customer__r.Customer_Type__c IN : selected )';
            }
            if(selectedSubType.size() > 0) {
                strQuerySubBanners +=' AND (Customer__r.Customer_Sub_Type__c IN : selectedSubType )';
            }
            if(selectedSubBannerCCTOptions.size() > 0) {
                strQuerySubBanners+=' AND (Parent_Relationship__c != null AND Client_Customer_Tier__c IN : selectedSubBannerCCTOptions)';
            }

            System.debug('strQuerySubBanners----'+strQuerySubBanners);
            System.debug('rtCustomerSBL5----'+rtCustomerSBL5);
            System.debug('ids----'+ids);

            List<Client_Customer_Relationship__c> listCCRSubbanner = Database.query(strQuerySubBanners);
            mapCCRSubBanner = new map<Id,Id>();
            for(Client_Customer_Relationship__c objCCR : listCCRSubbanner)
            {
                if(queryType == 'SBA')// Additional checks when Type='SBA' is in the URL
                {
                    if(objCCR.Client_Customer_Account_Teams__r.isEmpty())//If a CCATM with RW Client_Customer access doesn't exist, don't show on the UI
                    {
                        continue;
                    }
                }

                if(bannerResults.containsKey(objCCR.Customer__r.ParentId) && !(SubBannerids.contains(objCCR.Customer__r.Id))) {
                    SubBannerids.add(objCCR.Customer__r.Id);
                    NBAWrapper bn = new NBAWrapper();
                    bn.name = objCCR.Customer__r.Name;
                    bn.acId = objCCR.Customer__c;
                    bn.bannerAccountId = objCCR.Customer__r.ParentId;
                    bn.ccrId = objCCR.Id;
                    bn.proposedTarget = nationalTarget;
                    bn.isChecked = false;
                    bn.Customertype = objCCR.Customer__r.Customer_Type__c;
                    bn.customerSubType = objCCR.Customer__r.Customer_Sub_Type__c;
                    bn.wam = objCCR.WAM__c;
                    bn.clientCustomerTier = objCCR.Client_Customer_Tier__c;
                    bannerResults.get(objCCR.Customer__r.ParentId).nbaWrap.add(bn);
                }
                mapCCRSubBanner.put(objCCR.Customer__c,objCCR.Id);
            }
            system.debug('mapCCRSubBanner--->' + mapCCRSubBanner);
            Set<Id> bannerId = new Set<Id>();
            system.debug('queryType ====> '+queryType);
            //Populating wrapper with the National Banner data
            for(National_Banner_Allocation__c bnr : [Select Id, Allocated_non_Editable__c, Proposed_editable__c, System_Account_Name__c, System_Account_Id__c,Status__c From National_Banner_Allocation__c Where System_Account_Id__c IN: ids and National_Initiative_Lookup__c =:nationalInitiative.Id]) {
                if(bannerResults.containsKey(bnr.System_Account_Id__c)) {
                    bannerResults.get(bnr.System_Account_Id__c).checked = false;
                    bannerResults.get(bnr.System_Account_Id__c).target = bnr.Allocated_non_Editable__c;

                    if(bnr.Proposed_editable__c != null && bnr.Proposed_editable__c != '')
                        bannerResults.get(bnr.System_Account_Id__c).proposed = bnr.Proposed_editable__c;
                    else
                        bannerResults.get(bnr.System_Account_Id__c).proposed = nationalTarget;
                        bannerId.add(bnr.Id);
                        bannerResults.get(bnr.System_Account_Id__c).banIds = bnr.Id;
                }
            }
            System.debug('bannerResults:::::::' + bannerResults);

            Set<Id> bnrSetIds = new Set<Id>();
            List<National_Sub_Banner_Allocation__c> bnrList = [Select Id, Allocated_Target__c, Proposed_Target__c,Name, System_Account_Name__c, System_Account_Id__c From National_Sub_Banner_Allocation__c Where National_Banner_Allocation__c IN: bannerId and System_Account_Id__c IN: ids];

            //Populating wrapper with National Sub Banner Data

            for(Id ids1 : bannerResults.keySet())
            {
                system.debug('bannerResults.get(ids1).ids-->' + bannerResults.get(ids1).ids);
                Integer k = 0;
                for(National_Sub_Banner_Allocation__c bnr : bnrList)
                {

                    if(bannerResults.get(ids1).ids == bnr.System_Account_Id__c)
                    {
                        if(bannerResults.containsKey(bnr.System_Account_Id__c) && bannerResults.get(bnr.System_Account_Id__c).nbaWrap.size() > k && bannerResults.get(bnr.System_Account_Id__c).nbaWrap.size() > 0)
                        {
                            bannerResults.get(bnr.System_Account_Id__c).nbaWrap[k].allocated = bnr.Allocated_Target__c;

                            if(bnr.Proposed_Target__c != null && bnr.Proposed_Target__c != '')
                                bannerResults.get(bnr.System_Account_Id__c).nbaWrap[k].proposedTarget = bnr.Proposed_Target__c;
                            else
                                bannerResults.get(bnr.System_Account_Id__c).nbaWrap[k].proposedTarget = nationalTarget;

                            bannerResults.get(bnr.System_Account_Id__c).nbaWrap[k].banId = bnr.Id;
                            k++;
                         }
                    }
                }
            }//end for on bannerResults.keyset()
            bannerResultsOffset = new Map<Id, BannerWrapper>();
            totalRecs = bannerResults.size();
            totalSubBannerRecs = SubBannerids.size();
            Integer count = (bannerResults.size() > LimitSize ?  LimitSize : bannerResults.size());
            OffsetSize = 0;

            for(Integer j = OffsetSize;j < count;j++){
                    bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
            }

            Decimal pages = Decimal.valueOf(totalRecs);
            pages = pages.divide(Decimal.valueOf(LimitSize), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

            computeDisplayRange(totalRecs);

        }
    }//end searchBanners()

    public PageReference applyTargetToSelected()
    {
        System.debug('allocateAllValue----'+allocateAllValue);
        for(BannerWrapper bw: bannerResults.values())
        {
           if(bw.checked)
           {
             bw.proposed = allocateAllValue;
           }
           for(NBAWrapper nba:bw.nbaWrap)
           {
                if(nba.isChecked)
                {
                    nba.proposedTarget = allocateAllValue;
                }
           }
        }
        return null;
    }//end applyTargetToSelected()

    @RemoteAction
    public static UpdateAllocationResponse updateAllocated( String nationalInitiativeId, List<ProductSelectorController1.BannerWrapper> allBannerResults)
    {

        System.debug('allBannerResults---'+allBannerResults);
        System.debug('size allBannerResults---'+allBannerResults.size());
        National_Initiative__c nationalInitiative = [Select Initiatives__c,Objectives__c, Has_a_Target__c, Initiative_Start_Date__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Priority__c,Product_SKU__c,Comments__c,Strategy__c,Strategy__r.Client__c,Product_Group__c ,Brand__c from National_Initiative__c where id=:nationalInitiativeId];
        System.debug('nationalInitiative ----> '+nationalInitiative);
        return updateAllocatedUsingWrappers(nationalInitiative, allBannerResults);

    }//end RemoteaAction method updateAllocated()

    //Method to insert on click of Allocate
    public static UpdateAllocationResponse updateAllocatedUsingWrappers( National_Initiative__c nationalInitiative, List<ProductSelectorController1.BannerWrapper> bannerWrappers)
    {
        UpdateAllocationResponse response = new UpdateAllocationResponse();

        //On Allocate allocate records
        Map<Id, List<National_Sub_Banner_Allocation__c>> nSubBanner = new Map<Id, List<National_Sub_Banner_Allocation__c>>();
        Map<Id, National_Banner_Allocation__c> nBanner = new Map<Id, National_Banner_Allocation__c>();

        System.debug('bannerWrappers:::::::::::' + bannerWrappers);
        //On Save Unallocate
        for(ProductSelectorController1.BannerWrapper bw : bannerWrappers) {

            //Record modification of Banner Allocation
            if(bw.checked == true) {
                if(!String.isBlank(bw.proposed) && nationalInitiative.Has_a_Target__c == true) {

                    National_Banner_Allocation__c nban = new National_Banner_Allocation__c();

                    if(bw.banIds != null)  {
                        nban.Id = bw.banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bw.ccIds;
                        nban.National_Initiative_Lookup__c = nationalInitiative.Id;
                    }
                    nban.Allocated_non_Editable__c = bw.proposed;
                    nban.Proposed_editable__c = '';
                    nban.Status__c = 'Allocated';
                    nban.System_Account_Id__c = bw.ids;
                    nban.System_Account_Name__c = bw.name ;
                    nban.National_Banner_Allocation_Name__c = bw.name ;
                    nBanner.put(bw.ids, nban);
                }
                else if(String.isBlank(bw.proposed) && nationalInitiative.Has_a_Target__c == false) {

                    National_Banner_Allocation__c nban = new National_Banner_Allocation__c();

                    if(bw.banIds != null)  {
                        nban.Id = bw.banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bw.ccIds;
                        nban.National_Initiative_Lookup__c = nationalInitiative.Id;
                    }
                    nban.Allocated_non_Editable__c = bw.proposed;
                    nban.Proposed_editable__c = '';
                    nban.Status__c = 'Allocated';
                    nban.System_Account_Id__c = bw.ids;
                    nban.System_Account_Name__c = bw.name ;
                    nban.National_Banner_Allocation_Name__c = bw.name ;
                    nBanner.put(bw.ids, nban);
                }
                else if(String.isBlank(bw.proposed) && nationalInitiative.Has_a_Target__c == true){
                    response.returnCode = 1;
                    response.errorMessage = 'Revised Target 2 value is required.';
                    return response;
               } else if(!String.isBlank(bw.proposed) && nationalInitiative.Has_a_Target__c == false) {
                    response.returnCode = 2;
                    response.errorMessage = 'Revised Target value should be set to blank.';
                    return response;
               }
            }
            if(bw.nbaWrap != null)
            {
                for(NBAWrapper nb : bw.nbaWrap)
                {
                    System.debug('sub-banner-----'+nb.isChecked);
                    System.debug('banner-----'+bw.checked);
                    if(nb.isChecked == true) {
                        if(bw.checked == true){
                            if(nb.proposedTarget != null && nb.proposedTarget != '' && nationalInitiative.Has_a_Target__c == true) {
                                if(nSubBanner.containsKey(bw.ids)) {
                                    National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                    nSub.Allocated_Target__c = nb.proposedTarget;
                                    nSub.Proposed_Target__c = '';
                                    if(nb.banId != null) {
                                        nSub.Id = nb.banId;
                                    } else {
                                        nSub.Client_Customer_Relationship__c = nb.ccrId;
                                    }
                                    nSub.Status__c = 'Allocated';
                                    nSub.System_Account_Id__c = bw.ids;
                                    nSub.System_Related_Account__c = nb.acId;
                                    nSub.System_Account_Name__c = bw.name ;
                                    nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                    nSubBanner.get(bw.ids).add(nSub);
                                } else {
                                    National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                    nSub.Allocated_Target__c = nb.proposedTarget;
                                    nSub.Proposed_Target__c = '';
                                    if(nb.banId != null) {
                                        nSub.Id = nb.banId;
                                    } else {
                                         nSub.Client_Customer_Relationship__c = nb.ccrId;
                                    }
                                    nSub.Status__c = 'Allocated';
                                    nSub.System_Account_Id__c = bw.ids;
                                    nSub.System_Related_Account__c = nb.acId;
                                    nSub.System_Account_Name__c = bw.name ;
                                    nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                    nSubBanner.put(bw.ids,new List<National_Sub_Banner_Allocation__c>{nSub});
                                }
                            }
                             else if((nb.proposedTarget == null || nb.proposedTarget == '') && nationalInitiative.Has_a_Target__c == false) {
                                if(nSubBanner.containsKey(bw.ids)) {
                                    National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                    nSub.Allocated_Target__c = nb.proposedTarget;
                                    nSub.Proposed_Target__c = '';
                                    if(nb.banId != null) {
                                        nSub.Id = nb.banId;
                                    } else {
                                         nSub.Client_Customer_Relationship__c = nb.ccrId;
                                    }
                                    nSub.Status__c = 'Allocated';
                                    nSub.System_Account_Id__c = bw.ids;
                                    nSub.System_Related_Account__c = nb.acId;
                                    nSub.System_Account_Name__c = bw.name ;
                                    nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                    nSubBanner.get(bw.ids).add(nSub);
                                } else {
                                    National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                    nSub.Allocated_Target__c = nb.proposedTarget;
                                    nSub.Proposed_Target__c = '';
                                    if(nb.banId != null) {
                                        nSub.Id = nb.banId;
                                    } else {
                                         nSub.Client_Customer_Relationship__c = nb.ccrId;
                                    }
                                    nSub.Status__c = 'Allocated';
                                    nSub.System_Account_Id__c = bw.ids;
                                    nSub.System_Related_Account__c = nb.acId;
                                    nSub.System_Account_Name__c = bw.name ;
                                    nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                    nSubBanner.put(bw.ids,new List<National_Sub_Banner_Allocation__c>{nSub});
                                }
                            }
                             else if(String.isBlank(nb.proposedTarget) && nationalInitiative.Has_a_Target__c == true) {
                                response.returnCode = 1;
                                response.errorMessage = 'Revised Target 3 value is required.';
                                return response;
                            } else if(!String.isBlank(nb.proposedTarget) && nationalInitiative.Has_a_Target__c == false) {
                                response.returnCode = 2;
                                response.errorMessage = 'Revised Target value should be set to blank.';
                                return response;
                            }
                        } else {
                            response.returnCode = 1;
                            response.errorMessage = 'Please select the related banner of the selected sub-banner.';
                            return response;
                        }
                    }
                }//end for on nbaWrap
            }//end null check on bw.nbaWrap

        }//end for on bannerResults.keySet()

        //Check for size and update
        if(nBanner.size() > 0) {
            upsert nBanner.values();

            List<National_Sub_Banner_Allocation__c> nSubBanAllocation = new List<National_Sub_Banner_Allocation__c>();
            for(Id ids : nBanner.keySet()) {
                if(nSubBanner.containsKey(ids)){
                    for(National_Sub_Banner_Allocation__c nb : nSubBanner.get(ids)) {
                        nb.National_Banner_Allocation__c = nBanner.get(ids).Id;
                        nSubBanAllocation.add(nb);
                    }
                }
            }
            upsert nSubBanAllocation;
        }
        response.returnCode = 0;
        response.errorMessage = null;
        System.debug('response in updateAllocatedUsingWrappers--------'+response);
        return response;
    }//end updateAllocatedUsingWrappers()

    //Method to insert the data on click of Save
    public integer saveUnallocated() {

        //On Allocate allocate records
        Map<Id, List<National_Sub_Banner_Allocation__c>> nSubBanner = new Map<Id, List<National_Sub_Banner_Allocation__c>>();
        Map<Id, National_Banner_Allocation__c> nBanner = new Map<Id, National_Banner_Allocation__c>();

        //On Save Unallocate
        for(Id ids : bannerResults.keySet()) {

            if(bannerResults.get(ids).checked == true ) {
               if( bannerResults.get(ids).proposed != null  && nationalInitiative.Has_a_Target__c == true) {
                    National_Banner_Allocation__c nban = new National_Banner_Allocation__c();

                    if(bannerResults.get(ids).banIds != null)  {
                        nban.Id = bannerResults.get(ids).banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                        nban.National_Initiative_Lookup__c = nationalInitiative.Id;
                    }

                    nban.Proposed_editable__c = bannerResults.get(ids).proposed;
                    if(bannerResults.get(ids).target != '' && bannerResults.get(ids).target != null  ) {
                        //nban.Status__c = 'Unallocated';
                    } else {
                        nban.Status__c = 'Unallocated';
                    }
                    nban.System_Account_Id__c = bannerResults.get(ids).ids;
                    nban.System_Account_Name__c = bannerResults.get(ids).name ;
                    nban.National_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nBanner.put(ids, nban);
               }
               else if((bannerResults.get(ids).proposed == null || bannerResults.get(ids).proposed == '') && nationalInitiative.Has_a_Target__c == false) {
                    National_Banner_Allocation__c nban = new National_Banner_Allocation__c();

                    if(bannerResults.get(ids).banIds != null)  {
                        nban.Id = bannerResults.get(ids).banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                        nban.National_Initiative_Lookup__c = nationalInitiative.Id;
                    }

                    nban.Proposed_editable__c = bannerResults.get(ids).proposed;
                    if(bannerResults.get(ids).target != '' && bannerResults.get(ids).target != null  ) {
                        //nban.Status__c = 'Unallocated';
                    } else {
                        nban.Status__c = 'Unallocated';
                    }
                    nban.System_Account_Id__c = bannerResults.get(ids).ids;
                    nban.System_Account_Name__c = bannerResults.get(ids).name ;
                    nban.National_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nBanner.put(ids, nban);
               }
               else if(String.isBlank(bannerResults.get(ids).proposed)  && nationalInitiative.Has_a_Target__c == true){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Revised Target 4 value is required.'));
                    return 1;
               } else if(!String.isBlank(bannerResults.get(ids).proposed)  && nationalInitiative.Has_a_Target__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Revised Target value should be set to blank.'));
                    return 2;
               }
            }

            for(NBAWrapper nb : bannerResults.get(ids).nbaWrap) {
                system.debug('nb.proposedTarget-->' + nb.proposedTarget);
                system.debug('nb.proposedTarget-->' + nb.proposedTarget);
                system.debug('nationalInitiative.Has_a_Target__c-->' + nationalInitiative.Has_a_Target__c);
                if(nb.isChecked == true) {

                    if(bannerResults.get(ids).checked == true ) {

                        if(nb.proposedTarget != null && nb.proposedTarget != '' && nationalInitiative.Has_a_Target__c == true) {
                            if(nSubBanner.containsKey(ids)) {

                                National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                nSub.Proposed_Target__c = nb.proposedTarget;
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId;
                                } else {
                                     nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }

                                if(nb.allocated != null && nb.allocated != '') {
                                    // nSub.Status__c = 'Unallocated';
                                } else {
                                    nSub.Status__c = 'Unallocated';
                                }
                                nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                                nSub.System_Related_Account__c = nb.acId;
                                nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                                nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.get(ids).add(nSub);
                            } else {
                                National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                nSub.Proposed_Target__c = nb.proposedTarget;
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId;
                                } else {
                                     nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }

                                if(nb.allocated != null && nb.allocated != '') {
                                    // nSub.Status__c = 'Unallocated';
                                } else {
                                    nSub.Status__c = 'Unallocated';
                                }
                                nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                                nSub.System_Related_Account__c = nb.acId;
                                nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                                nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.put(ids, new List<National_Sub_Banner_Allocation__c>{nSub});
                            }
                        }
                        else if((nb.proposedTarget == null || nb.proposedTarget == '') && nationalInitiative.Has_a_Target__c == false) {
                            if(nSubBanner.containsKey(ids)) {

                                National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                nSub.Proposed_Target__c = nb.proposedTarget;
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId;
                                } else {
                                     nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }

                                if(nb.allocated != null && nb.allocated != '') {
                                    // nSub.Status__c = 'Unallocated';
                                } else {
                                    nSub.Status__c = 'Unallocated';
                                }
                                nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                                nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSub.System_Related_Account__c = nb.acId;
                                nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                                nSubBanner.get(ids).add(nSub);
                            } else {
                            system.debug('Test45-->');
                                National_Sub_Banner_Allocation__c nSub = new National_Sub_Banner_Allocation__c();
                                nSub.Proposed_Target__c = nb.proposedTarget;
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId;
                                } else {
                                     nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }

                                if(nb.allocated != null && nb.allocated != '') {
                                    // nSub.Status__c = 'Unallocated';
                                } else {
                                    nSub.Status__c = 'Unallocated';
                                }
                                nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                                nSub.System_Related_Account__c = nb.acId;
                                nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                                nSub.National_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.put(ids, new List<National_Sub_Banner_Allocation__c>{nSub});
                                 system.debug('nSubBanner-->' + nSubBanner);
                            }
                        }
                         else if(String.isBlank(nb.proposedTarget) && nationalInitiative.Has_a_Target__c == true) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Revised Target 1 value is required.'));
                            return 1;
                        } else if(!String.isBlank(nb.proposedTarget) && nationalInitiative.Has_a_Target__c == false) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Sub Banner Revised Target value should be set to blank.'));
                            return 2;
                        }
                    } else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select the banner related to the selected Sub Banner.'));
                            return 2;
                    }
                }
            }
        }

        System.debug('nBanner::::::::' + nBanner);
        //Check for size and update
        if(nBanner.size() > 0) {
            upsert nBanner.values();
            system.debug('nBanner-->' + nBanner);
            List<National_Sub_Banner_Allocation__c> nSubBanAllocation = new List<National_Sub_Banner_Allocation__c>();
            for(Id ids : nBanner.keySet()) {
                system.debug('nBanner-->' + nBanner);
                if(nSubBanner.containsKey(ids)) {
                    for(National_Sub_Banner_Allocation__c nb : nSubBanner.get(ids)) {
                    system.debug('nBanner.get(ids).Id-->' + nBanner.get(ids).Id);
                        nb.National_Banner_Allocation__c = nBanner.get(ids).Id;
                        nSubBanAllocation.add(nb);
                    }
                }
            }
            upsert nSubBanAllocation;
        }
        return 0;
    }//end saveUnallocated()

    public pageReference saveAndExit() {
        try {
            integer re = saveUnallocated();

            if(re == 0) {
                PageReference ref = new PageReference('/'+nationalInitiative.Strategy__c);
                ref.setRedirect(true);
                return ref;
            } else {
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, please contact your system administrator.<br/> '+e));
            return null;
        }
        return null;
    }

    public pageReference saveAndNewInitiative() {
        try {
            integer re = saveUnallocated();
            if(re == 0) {
                PageReference ref = new PageReference('/apex/NationalStrategyItem?StrategyId='+ nationalInitiative.Strategy__c);
                ref.setRedirect(true);
                return ref;
            } else {
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, please contact your system administrator.<br/> '+e));
            return null;
        }
        return null;
    }

    public pageReference allocateAndExit()
    {
       System.debug('before returnCode----'+returnCode);
       System.debug('before errorMessage----'+errorMessage);
       System.debug('nationalInitiative.Strategy__c---'+nationalInitiative.Strategy__c);
       try
       {
            Integer re = Integer.valueOf(returnCode);//updateAllocatedUsingWrappers();
            if(re == 0)
            {
                PageReference ref = new PageReference('/'+nationalInitiative.Strategy__c);
                ref.setRedirect(true);
                return ref;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessage));
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,e.getMessage()));
            return null;
        }
        return null;
    }

    public pageReference allocateAndNewInitiative()
    {
        System.debug('returnCode inside allocateAndNewInitiative----'+returnCode);
        System.debug('errorMessage----'+errorMessage);
        try
        {
            integer re = Integer.valueOf(returnCode);//updateAllocatedUsingWrappers();

            if(re == 0)
            {
                PageReference ref = new PageReference('/apex/NationalStrategyItem?StrategyId='+ nationalInitiative.Strategy__c);
                ref.setRedirect(true);
                return ref;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessage));
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong, please contact your system administrator.<br/> '+e));
            return null;
        }
        return null;
    }

    public pageReference Exit(){
        PageReference ref = new PageReference('/' + nationalInitiative.Strategy__c);
        ref.setRedirect(true);
        return ref;
    }

    public class NBAWrapper{
        public String name {get;set;}
        public Boolean isChecked {get;set;}
        public String allocated {get;set;}
        public Id acId {get;set;}
        public Id bannerAccountId{get;set;}
        public Id ccrId {get;set;}
        public String proposedTarget {get;set;}
        public Id banId {get;set;}
        public String Customertype {get;set;}
        public String customerSubType {get; set;}
        public boolean wam { get; set; }
        public string clientCustomerTier {get;set;}
    }

    public void computeDisplayRange(Integer totalRecs)
    {
        String  startingRange;
        Integer displayRecordsSize;
        if(totalRecs <= LimitSize)
        {
            displayRecordsSize = totalRecs;
        }else{
            displayRecordsSize = LimitSize * getPageNumber();
        }
        if(totalRecs>0)
        {
            startingRange = ((getPageNumber()-1)*LimitSize)+1 + ' - ';
            if(totalRecs < displayRecordsSize)
            {
                startingRange += totalRecs;
            }else
            {
                startingRange += displayRecordsSize;
            }
        }else
        {
            startingRange = '0';
        }
        displayRange = startingRange + ' of ' + totalRecs;
    }

    public void selectAllBannersAndSubBanners()
    {
        Set<String> selectedBannerIdSet = new Set<String>();
        Set<String> selectedSubBannerIdSet = new Set<String>();

        if(String.isNotBlank(selectedBanners))
        {
            selectedBannerIdSet = new Set<String>(selectedBanners.split(';'));
        }
        if(String.isNotBlank(selectedSubBanners))
        {
            selectedSubBannerIdSet = new Set<String>(selectedSubBanners.split(';'));
        }


        for(BannerWrapper bw: bannerResults.values())
        {
           bw.checked = true;
           selectedBannerIdSet.add(bw.ids);
           for(NBAWrapper nba:bw.nbaWrap)
           {
                nba.isChecked = true;
                selectedSubBannerIdSet.add(nba.acId);
           }
        }
        selectedBanners = String.join(new List<String>(selectedBannerIdSet),';');
        selectedSubBanners = String.join(new List<String>(selectedSubBannerIdSet),';');
        System.debug('selectedBanners----'+selectedBanners);
        System.debug('selectedSubBanners----'+selectedSubBanners);
    }//end selectAllBannersAndSubBanners()

    public void selectAllBanners()
    {
        Set<String> selectedBannerIdSet = new Set<String>();

        if(String.isNotBlank(selectedBanners))
        {
            selectedBannerIdSet = new Set<String>(selectedBanners.split(';'));
        }
        for(BannerWrapper bw: bannerResults.values())
        {
           bw.checked = true;
           selectedBannerIdSet.add(bw.ids);
        }
        selectedBanners = String.join(new List<String>(selectedBannerIdSet),';');
    }

    public Pagereference clearFilters()
    {
      String initiativeId = ApexPages.currentPage().getParameters().get('initiativeId');
      PageReference samePage = new PageReference('/apex/BannerUI1');
      samePage.getParameters().put('initiativeId',initiativeId);
      // If the URL contains type=SBA we need to make sure that is added to the URL again before refreshing the page
      if (queryType != null) samePage.getParameters().put('type',queryType);
      samePage.setRedirect(true);
      return samePage;
    }

    public void clearAllSelected()
    {
        selectedBanners = '';
        selectedSubBanners = '';
        for(BannerWrapper bw: bannerResults.values())
        {
            if(bw.checked)
            {
                bw.proposed = null;//If a banner is selected, blank out the proposed value upon clear.
                bw.checked = false;
            }

           for(NBAWrapper nba:bw.nbaWrap)
           {
                if(nba.isChecked)
                {
                    nba.proposedTarget = null;//If a sub-banner is selected, blank out the proposed value upon clear.
                    nba.isChecked = false;
                }
           }
        }//end for on bannerResults
    }

    public void showSelected()
    {
        OffsetSize = 0;

        bannerResultsOffset.clear();
        Set<String> selectedBannerIdSet = new Set<String>();
        if(String.isNotBlank(selectedBanners))
        {
            selectedBannerIdSet = new Set<String>(selectedBanners.split(';'));
        }
        System.debug('selectedBannerIdSet----'+selectedBannerIdSet);
        List<BannerWrapper> selectedBannerResults = new List<BannerWrapper>();
        for(BannerWrapper bw: bannerResults.values())
        {
            if(selectedBannerIdSet.contains(bw.ids))
            {
                bw.checked=true;
                selectedBannerResults.add(bw);
            }
        }
        totalRecs = selectedBannerResults.size();
        System.debug('totalRecs-----'+totalRecs);
        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

        System.debug('selectedBannerResults-----'+selectedBannerResults);
        Integer count = (selectedBannerResults.size() > LimitSize?  LimitSize: selectedBannerResults.size());
        for(Integer j = OffsetSize;j < count;j++)
        {
            bannerResultsOffset.put(selectedBannerResults.get(j).ids ,selectedBannerResults.get(j));
        }

        computeDisplayRange(totalRecs);

    }//end showSelected()

    public void showAll()
    {
        OffsetSize = 0;

        bannerResultsOffset.clear();
        totalRecs = bannerResults.size();
        Decimal pages = Decimal.valueOf(totalRecs);
        pages = pages.divide(Decimal.valueOf(LimitSize), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        System.debug('totalRecs-----'+totalRecs);
        System.debug('bannerResults-----'+bannerResults);
        Integer count = (bannerResults.size() > LimitSize?  LimitSize: bannerResults.size());
        for(Integer j = OffsetSize;j < count;j++)
        {
            bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
        }
        computeDisplayRange(totalRecs);
    }//end showAll()

    public void FirstPage(){
        OffsetSize = 0;
        //holdATM();

        bannerResultsOffset.clear();
        Integer count = (bannerResults.size() > LimitSize?  LimitSize: bannerResults.size());
        for(Integer j = OffsetSize;j < count;j++){
                    bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
            }
        computeDisplayRange(totalRecs);
    }

    public void previous(){
        system.debug('OffsetSize-->' + OffsetSize );

        OffsetSize = (OffsetSize-LimitSize);
        system.debug('OffsetSize-->' + OffsetSize );
        bannerResultsOffset.clear();
        system.debug('LimitSize-->' + LimitSize );
        Integer count = (bannerResults.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : bannerResults.size());
        system.debug('Count-->' + Count);

        for(Id ids1 : bannerResults.keySet()) {

        }
        for(Integer j = OffsetSize;j < count;j++){
            bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
        }
       computeDisplayRange(totalRecs);
    }

    public void next(){
        OffsetSize = OffsetSize + LimitSize;
        bannerResultsOffset.clear();
        system.debug('bannerResults-->' + bannerResults);
        Integer count = (bannerResults.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize) : bannerResults.size());
        System.debug('selectedBanners---'+selectedBanners);
        System.debug('OffsetSize-->' + OffsetSize );
        System.debug('count -->' + count );
        for(Integer j = OffsetSize;j < count;j++){
            bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
        }
        system.debug('bannerResultsOffset-->' + bannerResultsOffset.size());
        computeDisplayRange(totalRecs);
    }

      public void LastPage(){
        if(math.mod(totalrecs, LimitSize)!=0){
            OffsetSize = totalrecs - math.mod(totalrecs, LimitSize);
        }
        else{
            OffsetSize = totalrecs - LimitSize;
        }
        bannerResultsOffset.clear();
        Integer count = (bannerResults.size() > (OffsetSize + LimitSize) ?  (OffsetSize + LimitSize): bannerResults.size());
        for(Integer j = OffsetSize;j < count;j++){
            bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
        }
        computeDisplayRange(totalRecs);

    }

     public boolean getprev(){
        if(OffsetSize == 0){
            return true;
        }
        else {
            return false;
        }
    }
     public boolean getnxt(){
        if((OffsetSize + LimitSize +1) > totalRecs){
            return true;
        }
        else {
            return false;
        }
    }
     public Integer gettotalRecs(){
        return totalRecs;
    }

    public Integer getPageNumber(){
        if(OffsetSize ==0){
            return 1;
        }
        else{
            return (OffsetSize / LimitSize)+1 ;
        }
    }
    public class BannerWrapper {
        public Boolean checked{ get; set; }
        public Integer index { get; set; }
        public string target { get; set;}
        public string proposed { get; set;}
        public string name{ get; set;}
        public id ids{ get; set;}
        public id banIds {get; set;}
        public id ccIds { get; set; }
        public List<ProductSelectorController1.NBAWrapper> nbaWrap { get; set; }
        public String customerType { get; set; }
        public String customerSubType { get; set; }
        public boolean wam { get; set; }
        public string clientCustomerTier {get;set;}
        public BannerWrapper()
        {
            target = '';
            index = 0;
            checked = false;
            ids = null;
            proposed = '';
            banIds = null;
            ccIds = null;
            nbaWrap = new List<ProductSelectorController1.NBAWrapper>();
            customerType = '';
            customerSubType = '';
            wam = false;
            clientCustomerTier ='';
        }
    }
}