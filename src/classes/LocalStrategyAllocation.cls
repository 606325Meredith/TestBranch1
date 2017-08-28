/**
 *  Description     :   Local strategy page with banner and sub banner relared list.
 *
 *  Created By      :   Abhishek Tripathi 
 * 
 *  Created Date    :   8/09/2016   
 *  Version         :   V1.0     
 **/
public with sharing class LocalStrategyAllocation{
   
    public Map<Id, BannerWrapper> bannerResults {get;set;}
    public Map<Id, BannerWrapper> bannerResultsOffset {get;set;}
    public String bannerResultsList{
        get{
            return JSON.serialize(bannerResults.values());
    }set;}
    public Account client{get;set;}
    public Local_Initiative__c localInitiative{get;set;}    
    public Integer page{get;set;}
    private string strQuery {get;set;} 
    public integer totalRecs{get;set;}
    public integer totalbannerRecs =0;
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
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    public Integer totalPages{get;set;}
    public Static List<Account> childAccountsL5 {get;set;}
    public List<String> accCustomerTypePicklist {get;set;}
    public Id ccId ; 
    private string CCRelId; 
    private string clientId; 
    private string nationalTarget;
    public String searchedName {get;set;}
    public list<string> cctSubBannerSelections {get;set;}  //holds the values of the selected Client Customer Tier Sub-Banner checkboxes
    
    public Account accounts {get;set;}
    public String selectCustomerType {get;set;}
    public boolean ProductSKUflag{get;set;}
    public boolean ProductGroupflag{get;set;}
    public boolean Brandflag{get;set;}
    public boolean Noflag{get;set;}
    public map<id,id> mapCCRSubBanner {get;set;}
    public Local_Banner_Allocation__c lba{get;set;}
    
    public String selectedBanners{get;set;}
    public String selectedSubBanners{get;set;}
    public String displayRange{get;set;}

    public String returnCode{get;set;}
    public String errorMessage{get;set;}
    public String allocateAllValue{get;set;}

    public class UpdateAllocationResponse
    {
        public Integer returnCode{get;set;}
        public String errorMessage{get;set;}
        //public Boolean hasMoreRecords{get;set;}
    }
    
    public LocalStrategyAllocation(){
        lba = new Local_Banner_Allocation__c();
        client = new Account();
        localInitiative = new Local_Initiative__c();
        ccId = null;
        nationalTarget = '';
        totalRecs = 0;
        String initIds = ApexPages.currentPage().getParameters().get('initiativeId');
        searchedName = '';
        bannerResults = new Map<Id, BannerWrapper>();
        
        localInitiative = [Select Initiatives__c,Objectives__c,Initiative_Start_Date__c,Has_a_Target__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Priority__c,Product_SKU__c,Comments__c,Local_Strategy__c,Local_Strategy__r.Client_Customer_Relationship__c,Product_Group__c,Brand__c from Local_Initiative__c where id=:initIds];        
        CCRelId = localInitiative.Local_Strategy__r.Client_Customer_Relationship__c;
        
        Client_Customer_Relationship__c  objCCRel = [Select Id,Client__c from Client_Customer_Relationship__c where Id =: CCRelId];
        clientId = objCCRel.Client__c ;
        this.page = 1;
        cctSubBannerSelections = new List<String>();

        childAccountsL5 = new List<Account>();
        accCustomerTypePicklist = new List<String>();

        //Fetching the picklist values from the Account object
        Schema.DescribeFieldResult dfr = Account.Customer_Type__c.getDescribe();
        for(Schema.PicklistEntry st : dfr.getPicklistValues()) {
            accCustomerTypePicklist.add(st.getValue());
        }        

        selectCustomerType = '';
        
        if(localInitiative.Target__c != '' && localInitiative.Target__c != null && localInitiative.Unit_of_Measure__c == 'Percent') {
            nationalTarget = localInitiative.Target__c;
        }
        if(string.isnotblank(localInitiative.Product_SKU__c))
        {
            ProductSKUflag = true;
            Brandflag = false;
            ProductGroupflag  = false;
            Noflag = false;
            
        }
        else if(string.isnotblank(localInitiative.Product_Group__c))
        {
            ProductGroupflag = true;
            Brandflag = false;
            ProductSKUflag  = false;
            Noflag = false;
        }
        else if(string.isnotblank(localInitiative.Brand__c))
        {
            Brandflag = true;
            ProductSKUflag  = false;
            ProductGroupflag  = false;
            Noflag = false;
            
        }
        else if(string.isblank(localInitiative.Product_SKU__c) && string.isblank(localInitiative.Product_Group__c) && string.isblank(localInitiative.Brand__c))
        {
            Brandflag = true;
            ProductSKUflag  = false;
            ProductGroupflag  = false;
            Noflag = true;
        }
        searchBanners();
    }

    public list<SelectOption> getMyCCTCheckboxes(){
        list<SelectOption> options = new list<SelectOption>();

        sObjectType objectType = Schema.getGlobalDescribe().get('Client_Customer_Relationship__c');
        if(objectType==null) return options;

        Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
        Schema.SObjectField theField = objDescribe.fields.getMap().get('Client_Customer_Tier__c');
        if(theField==null) return options;

        for (Schema.PicklistEntry a :theField.getDescribe().getPickListValues())
            options.add(new SelectOption(a.getValue(),' Tier ' + a.getLabel()));
            //options.add(new SelectOption(a.getLabel(), a.getValue()));
            //system.debug('options =====> '+options);

        return options;
    }
    
    //Method to search the records from the picklist and search box
    public pageReference filterList()  {
        
        searchbanners();
        Map<Id, BannerWrapper> newMapResults = new Map<Id, BannerWrapper>();
        
        Set<String> selected = new Set<String>();
        set<string> selectedSubType = new set<string>();
        if(lba.System_Customer_Type_Multi__c != null) {
            for(String str : lba.System_Customer_Type_Multi__c.split(';')){
                selected.add(str.toLowerCase());
            }
        }
       
         if(lba.System_Customer_Sub_Type__c  != null) {
            for(String str : lba.System_Customer_Sub_Type__c.split(';')){
                selectedSubType.add(str.toLowerCase());
            }
        }
        
        
         //if(selected.size() > 0 || (searchedName != null && searchedName != '') || selectedSubType.size()>0 || lba.System_WAM__c !=null || (lba.System_Client_Customer_Tier__c !=null || lba.System_Client_Customer_Tier__c !='')) {
         if(selected.size() > 0 || (searchedName != null && searchedName != '') || selectedSubType.size()>0) 
         {
       
            if(searchedName != null && searchedName != '') {
                
                for(Id ids : bannerResults.keySet()) {
                    if(bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                        newMapResults.put(ids, bannerResults.get(ids));
                    }
                }
            }
            /*
            if(lba.System_WAM__c !=null){
                for(Id ids : bannerResults.keySet()) {
                    if(bannerResults.get(ids).wam !=null)
                    {
                        if(bannerResults.get(ids).wam == lba.System_WAM__c) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                }
            } 
            if(lba.System_Client_Customer_Tier__c !=null && lba.System_Client_Customer_Tier__c !=''){
                for(Id ids : bannerResults.keySet()) {
                    if(bannerResults.get(ids).clientCustomerTier !=null && bannerResults.get(ids).clientCustomerTier !='')
                    {
                        if(bannerResults.get(ids).clientCustomerTier.toLowerCase().contains(lba.System_Client_Customer_Tier__c.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                }
            }
            if(lba.System_Client_Customer_Tier__c !=null && lba.System_Client_Customer_Tier__c !=''){
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).clientCustomerTier))
                    {
                        if(bannerResults.get(ids).clientCustomerTier.toLowerCase().contains(lba.System_Client_Customer_Tier__c.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    } 
                    for(NBAWrapper lbawrap : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(lbawrap.clientCustomerTier)){
                            if(lba.System_Client_Customer_Tier__c.toLowerCase().contains(lbawrap.clientCustomerTier.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }                  
                }
            }
            */
            if(selected.size() > 0 && selectedSubType.size() == 0  && (searchedName == null || searchedName == '') ) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customertype)) {
                        if(selected.contains(bannerResults.get(ids).customertype.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                    
                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customertype)){
                            if(selected.contains(nba.customertype.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            } 
            if(selected.size() > 0 && selectedSubType.size() == 0  && (searchedName != null && searchedName != '') ) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customertype)) {
                        if(selected.contains(bannerResults.get(ids).customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                    
                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customertype)){
                            if(selected.contains(nba.customertype.toLowerCase()) && bannerResults.get(ids).name.toLowerCase().contains(searchedName.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
                }
            } 
            
             if(selectedSubType.size() > 0 && selected.size() == 0 && (searchedName == null || searchedName == '')) {
                for(Id ids : bannerResults.keySet()) {
                    if(!String.isBlank(bannerResults.get(ids).customerSubType)) {
                        if(selectedSubType.contains(bannerResults.get(ids).customerSubType.toLowerCase())) {
                            newMapResults.put(ids, bannerResults.get(ids));
                        }
                    }
                    
                    for(NBAWrapper nba : bannerResults.get(ids).nbaWrap) {
                        if(!String.isBlank(nba.customerSubType)){
                            if(selectedSubType.contains(nba.customerSubType.toLowerCase())) {
                                newMapResults.put(ids, bannerResults.get(ids));
                            }
                        }
                    }
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
            
            if(newMapResults.size() > 0) {
                bannerResults.clear();
                bannerResults = newMapResults;
            } else {
                bannerResults.clear();
            }
        } else {
            searchbanners();
        }
        PageReference pref = new PageReference('/apex/LocalStrategyAllocation?initiativeId='+localInitiative.Id);
        pref.setRedirect(false);
        return pref ;
    }
    
    public Void searchBanners(){
        string strQuery;
        Set<String> selected = new Set<String>();
        set<string> selectedSubType = new set<string>();
        Set<String> selectedSubBannerCCTOptions = new set<String>();

        if(lba.System_Customer_Type_Multi__c != null) {
            for(String str : lba.System_Customer_Type_Multi__c.split(';')){
                selected.add(str.toLowerCase());
            }
        }
       
         if(lba.System_Customer_Sub_Type__c  != null) {
            for(String str : lba.System_Customer_Sub_Type__c.split(';')){
                selectedSubType.add(str.toLowerCase());
            }
        }

        if(cctSubBannerSelections != null) {
            for(String str : cctSubBannerSelections){
                selectedSubBannerCCTOptions.add(str.toLowerCase());
            }
        }

        if(string.isNOTBlank(CCRelId))
        {
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Id rtCustomerSBL5 = rtMapByName.get('Customer - Sub Banner - L5').getRecordTypeId();
            Id rtCustomerSBL4 = rtMapByName.get('Customer - Banner - L4').getRecordTypeId();
            strQuery = 'Select Id,Name,Customer__c,WAM__c,Client_Customer_Tier__c,Customer__r.Customer_Type__c,Customer__r.Customer_Sub_Type__c,Customer__r.RecordType.Name,Customer__r.Name from Client_Customer_Relationship__c where Id=: CCRelId and Customer__r.recordType.Id =: rtCustomerSBL4 and Status__c = \'Active\'';
            if(String.isNotBlank(searchedName )) {
                strQuery+=' AND (Customer__r.Name Like \'%' +String.escapeSingleQuotes(searchedName ) +'%\')';               
            }
            if(selected.size() > 0) {
                strQuery+=' AND (Customer__r.Customer_Type__c IN : selected)';
            }
            if(selectedSubType.size() > 0) {
                strQuery+=' AND (Customer__r.Customer_Sub_Type__c IN : selectedSubType)';
            }
            string strQueryWithoutOffset ;
            bannerResults.clear();
            //map<Id,Client_Customer_Relationship__c > mapCCRel = new map<Id,Client_Customer_Relationship__c >([Select Id , Name,Customer__c, Customer__r.RecordType.Name,Customer__r.Name from Client_Customer_Relationship__c where Client__c ='0011700000WAv8W']);
            
            strQueryWithoutOffset = strQuery;
            List<Client_Customer_Relationship__c> listClientCustRel = Database.query(strQueryWithoutOffset );
            totalbannerRecs = (listClientCustRel !=null && listClientCustRel.size()>0)?listClientCustRel.size():0;
            //strQuery+=' LIMIT :LimitSize OFFSET :OffsetSize';
            List<Client_Customer_Relationship__c> listCCRel = Database.query(strQuery); 
            Integer i = 0;
            Set<Id> ids = new Set<Id>();
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
                    wrap.customerType = ccRel.Customer__r.Customer_Type__c;
                    wrap.customerSubType = ccRel.Customer__r.Customer_Sub_Type__c;
                    wrap.wam = ccRel.WAM__c;
                    wrap.clientCustomerTier = ccRel.Client_Customer_Tier__c;
                    bannerResults.put(ccRel.Customer__r.Id, wrap);
                    i++;
                }
            }
            
            
            Set<Id> accIds = new Set<Id>();
            Map<Id, List<NBAWrapper>> mapOfNBAWrap = new Map<Id, List<NBAWrapper>>();
            Set<Id> SubBannerids = new Set<Id>();
            //Fetching all the child accounts 
            /*
            for(Account ac : [ Select Id, Name, ParentId From Account Where ParentId IN: ids and (RecordTypeId =: rtCustomerSBL5 OR RecordTypeId =: rtCustomerSBL4)]) {
                accIds.add(ac.Id);
                
                if(bannerResults.containsKey(ac.ParentId)) {
                    NBAWrapper bn = new NBAWrapper();
                    bn.name = ac.Name;
                    bn.acId = ac.Id;
                    bn.proposedTarget = nationalTarget;
                    bannerResults.get(ac.ParentId).nbaWrap.add(bn);
                }    
            }
            */
            //List<Client_Customer_Relationship__c> listCCRSubbanner = new List<Client_Customer_Relationship__c>([select id,Customer__c from Client_Customer_Relationship__c where Customer__c in : accIds]);
            string strQuerySubBanners = 'select id,Customer__c,WAM__c,Client_Customer_Tier__c,Customer__r.ParentId,Customer__r.Name,Customer__r.Customer_Type__c,Customer__r.Customer_Sub_Type__c from Client_Customer_Relationship__c where Customer__r.ParentId IN: ids and (Customer__r.recordType.Id =: rtCustomerSBL5) and Status__c = \'Active\' and Client__c =: clientId';
            
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
            List<Client_Customer_Relationship__c> listCCRSubbanner = Database.query(strQuerySubBanners);
            //List<Client_Customer_Relationship__c> listCCRSubbanner = new List<Client_Customer_Relationship__c>([Select Parent_Relationship__r.Id,Parent_Relationship__r.Customer__c,Parent_Relationship__c from Client_Customer_Relationship__c where Id=: CCRelId and Status__c = 'Active']);
            mapCCRSubBanner = new map<Id,Id>();
            
           for(Client_Customer_Relationship__c objCCR : listCCRSubbanner)
            {
                if(bannerResults.containsKey(objCCR.Customer__r.ParentId) && !(SubBannerids.contains(objCCR.Customer__r.Id))) {
                    SubBannerids.add(objCCR.Customer__r.Id);
                    NBAWrapper bn = new NBAWrapper();
                    bn.name = objCCR.Customer__r.Name;
                    bn.acId = objCCR.Customer__c;
                    bn.ccrId = objCCR.Id;
                    bn.proposedTarget = nationalTarget;
                    bn.isChecked = false;
                    bn.allocated = localInitiative.Target__c;
                    bn.Customertype = objCCR.Customer__r.Customer_Type__c;
                    bn.customerSubType = objCCR.Customer__r.Customer_Sub_Type__c;
                    bn.wam = objCCR.WAM__c;
                    bn.clientCustomerTier = objCCR.Client_Customer_Tier__c;
                    bannerResults.get(objCCR.Customer__r.ParentId).nbaWrap.add(bn);
                }
                mapCCRSubBanner.put(objCCR.Customer__c,objCCR.Id);
            }
            Set<Id> bannerId = new Set<Id>();
            //Populating wrapper with the Local Banner data
            for(Local_Banner_Allocation__c bnr : [Select Id, Allocated_Target__c, Proposed_Target__c, Client_Customer_Relationship__c , System_Account_Name__c, System_Account_Id__c From Local_Banner_Allocation__c Where System_Account_Id__c IN: ids and Local_Initiative__c =:localInitiative.Id]) {
                if(bannerResults.containsKey(bnr.System_Account_Id__c)) {
                    //if(bnr.Allocated_Target__c != null) {
                    //bannerResults.get(bnr.System_Account_Id__c).checked = true;
                    bannerResults.get(bnr.System_Account_Id__c).target = bnr.Allocated_Target__c;
                    
                    if(bnr.Proposed_Target__c != null && bnr.Proposed_Target__c != '')
                        bannerResults.get(bnr.System_Account_Id__c).proposed = bnr.Proposed_Target__c;
                    else 
                        bannerResults.get(bnr.System_Account_Id__c).proposed = nationalTarget;
                    
                    bannerId.add(bnr.Id);
                    bannerResults.get(bnr.System_Account_Id__c).banIds = bnr.Id;
                } 
            }
            
            Set<Id> bnrSetIds = new Set<Id>();
            List<Local_Sub_Banner_Allocation__c> bnrList = [Select Id, Allocated_Traget__c, Client_Customer_Relationship__c , Proposed_Target__c, System_Account_Name__c, System_Account_Id__c,System_Related_Account__c  From Local_Sub_Banner_Allocation__c Where Local_Banner_Allocation__c IN: bannerId and System_Account_Id__c IN: ids ];
            system.debug('bnrList-->' + bnrList );
            //Populating wrapper with Local Sub Banner Data
            for(Id objId : Ids)
            {
                integer inte = 0;
                for(Local_Sub_Banner_Allocation__c bnr : bnrList) {
                
                    if(objId == bnr.System_Account_Id__c)
                    {
                    
                        if(bannerResults.containsKey(bnr.System_Account_Id__c) && bannerResults.get(bnr.System_Account_Id__c).nbaWrap.size() > inte) {
                            //bannerResults.get(bnr.System_Account_Id__c).nbaWrap[inte].isChecked = 'checked';
                            system.debug('bnr.Allocated_Traget__c-->' + bnr.Allocated_Traget__c);
                            bannerResults.get(bnr.System_Account_Id__c ).nbaWrap[inte].allocated = bnr.Allocated_Traget__c;
                            
                            if(bnr.Proposed_Target__c != null && bnr.Proposed_Target__c != '' )
                                bannerResults.get(bnr.System_Account_Id__c ).nbaWrap[inte].proposedTarget = bnr.Proposed_Target__c;
                            else 
                                bannerResults.get(bnr.System_Account_Id__c ).nbaWrap[inte].proposedTarget = nationalTarget;
                             system.debug('bnr.Id-->' + bnr.Id);
                             system.debug('inte-->' + inte);
                            bannerResults.get(bnr.System_Account_Id__c ).nbaWrap[inte].banId = bnr.Id;
                            inte++;
                        }
                    }
                }
            }//end for on Ids

            if(OffsetSize > 2000){
                OffsetSize = 2000;
            }        
            bannerResultsOffset = new Map<Id, BannerWrapper>();
            totalRecs = bannerResults.size();
            
            Integer count = (bannerResults.size() > LimitSize ?  LimitSize : bannerResults.size());
            OffsetSize = 0;
           
            for(Integer j = OffsetSize;j < count;j++){            
                bannerResultsOffset.put(bannerResults.values().get(j).ids ,bannerResults.values().get(j));
            }
            Decimal pages = Decimal.valueOf(totalRecs);
            pages = pages.divide(Decimal.valueOf(LimitSize), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);  
            
            computeDisplayRange(totalRecs);

            if(totalbannerRecs >2000)
            {
                totalbannerRecs =2000;
            }
            

        }//Null check on CCRelId

    }//end searchBanners()

    public void computeDisplayRange(Integer totalRecs)
    {
        String  startingRange;
        Integer displayRecordsSize;
        if((totalRecs + totalSubBannerRecs) <= LimitSize)
        {
            displayRecordsSize = (totalRecs + totalSubBannerRecs);
        }else{
            displayRecordsSize = LimitSize * getPageNumber();
        }
        if((totalRecs + totalSubBannerRecs)>0)
        {
            startingRange = ((getPageNumber()-1)*LimitSize)+1 + ' - ';
            if((totalRecs + totalSubBannerRecs) < displayRecordsSize)
            {
                startingRange += (totalRecs + totalSubBannerRecs);
            }else
            {
                startingRange += displayRecordsSize;
            }
        }else
        {
            startingRange = '0';
        }  
        displayRange = startingRange + ' of ' + (totalRecs + totalSubBannerRecs);
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

    public Pagereference clearFilters()
    {
      Pagereference samePage = new Pagereference('/apex/LocalStrategyAllocation');
      String initiativeId = ApexPages.currentPage().getParameters().get('initiativeId');
      samePage.getParameters().put('initiativeId',initiativeId);
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
           
        }
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
            return (OffsetSize /LimitSize)+1 ;
        }      
    }  

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
    public static UpdateAllocationResponse updateAllocated( String localInitiativeId, List<LocalStrategyAllocation.BannerWrapper> allBannerResults)
    {

        System.debug('allBannerResults---'+allBannerResults);
        System.debug('size allBannerResults---'+allBannerResults.size());
        Local_Initiative__c localInitiative = [Select Initiatives__c,Objectives__c,Initiative_Start_Date__c,Has_a_Target__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Priority__c,Product_SKU__c,Comments__c,Local_Strategy__c,Local_Strategy__r.Client_Customer_Relationship__c,Product_Group__c,Brand__c from Local_Initiative__c where id=:localInitiativeId];  
        return updateAllocatedUsingWrappers(localInitiative, allBannerResults);
        
    }//end RemoteaAction method updateAllocated()

    //Method to insert on click of Allocate
    public static UpdateAllocationResponse updateAllocatedUsingWrappers( Local_Initiative__c localInitiative, List<LocalStrategyAllocation.BannerWrapper> bannerWrappers)
    { 
        UpdateAllocationResponse response = new UpdateAllocationResponse(); 
        //On Allocate allocate records
        Map<Id, List<Local_Sub_Banner_Allocation__c>> nSubBanner = new Map<Id, List<Local_Sub_Banner_Allocation__c>>();
        Map<Id, Local_Banner_Allocation__c> nBanner = new Map<Id, Local_Banner_Allocation__c>();
        
        //On Save Unallocate
        for(LocalStrategyAllocation.BannerWrapper bw  : bannerWrappers) {
           
            //Record modification of Banner Allocation
            if(bw.checked == true) {
                if(!String.isBlank(bw.proposed) && localInitiative.Has_a_Target__c == true) {
                    Local_Banner_Allocation__c nban = new Local_Banner_Allocation__c();
                    
                    if(bw.banIds != null)  {
                        nban.Id = bw.banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bw.ccIds;
                        nban.Local_Initiative__c = localInitiative.Id;
                    }
                
                    nban.Local_Banner_Allocation_Name__c = bw.name ;
                    nban.Allocated_Target__c = bw.proposed;
                    nban.Proposed_Target__c = '';
                    nban.Status__c = 'Allocated';
                    nban.System_Account_Id__c = bw.ids;
                    nban.System_Account_Name__c = bw.name ;
                    nban.Local_Banner_Allocation_Name__c = bw.name ;
                    nBanner.put(bw.ids, nban);
                }
                else if(String.isBlank(bw.proposed) && localInitiative.Has_a_Target__c == false) {
                    Local_Banner_Allocation__c nban = new Local_Banner_Allocation__c();
                    
                    if(bw.banIds != null)  {
                        nban.Id = bw.banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bw.ccIds;
                        nban.Local_Initiative__c = localInitiative.Id;
                    }
                
                    nban.Local_Banner_Allocation_Name__c = bw.name ;
                    nban.Allocated_Target__c = bw.proposed;
                    nban.Proposed_Target__c = '';
                    nban.Status__c = 'Allocated';
                    nban.System_Account_Id__c = bw.ids;
                    nban.System_Account_Name__c = bw.name ;
                    nban.Local_Banner_Allocation_Name__c = bw.name ;
                    nBanner.put(bw.ids, nban);
                }
                 else if(String.isBlank(bw.proposed)  && localInitiative.Has_a_Target__c == true){
                   //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value is required.'));
                   //return 1;     
                   response.returnCode = 1;
                   response.errorMessage = 'Proposed Target value is required.';
                   return response;
               } else if(!String.isBlank(bw.proposed)  && localInitiative.Has_a_Target__c == false) {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value should be set to blank.'));
                    //return 1;   
                    response.returnCode = 1;
                    response.errorMessage = 'Proposed Target value should be set to blank.';
                    return response;             
               }
            }
            for(NBAWrapper nb : bw.nbaWrap) {
                if(nb.isChecked == true) {
                    if(bw.checked == true) {
            
                        if(nb.proposedTarget != null && nb.proposedTarget != '' && localInitiative.Has_a_Target__c == true) { 
                            
                            if(nSubBanner.containsKey(bw.ids) ) {
                                
                                Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                                nSub.Allocated_Traget__c = nb.proposedTarget;
                                nSub.Proposed_Target__c = '';
                                if(nb.banId != null) { 
                                    nSub.Id = nb.banId;
                                } else {
                                    //nSub.Client_Customer_Relationship__c = bw.ccIds;
                                    //nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                                    nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }
                                nSub.Status__c = 'Allocated'; 
                                nSub.System_Account_Id__c = bw.ids;
                                nSub.System_Related_Account__c = nb.acId; 
                                nSub.System_Account_Name__c = bw.name ;
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.get(bw.ids).add(nSub);
                            } else{
                               
                                Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                                nSub.Allocated_Traget__c = nb.proposedTarget;
                                nSub.Proposed_Target__c = '';
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId; 
                                } else {
                                    //nSub.Client_Customer_Relationship__c = bw.ccIds;
                                    //nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                                    nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }
                                nSub.Status__c = 'Allocated';
                                nSub.System_Account_Id__c = bw.ids;
                                nSub.System_Related_Account__c = nb.acId; 
                                nSub.System_Account_Name__c = bw.name ;
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.put(bw.ids,new List<Local_Sub_Banner_Allocation__c>{nSub});
                            }
                        } 
                        else if((nb.proposedTarget == null || nb.proposedTarget == '') && localInitiative.Has_a_Target__c == false) {
                            if(nSubBanner.containsKey(bw.ids) ) {
                                
                                Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                                nSub.Allocated_Traget__c = nb.proposedTarget;
                                nSub.Proposed_Target__c = '';
                                if(nb.banId != null) { 
                                    nSub.Id = nb.banId;
                                } else {
                                    //nSub.Client_Customer_Relationship__c = bw.ccIds;
                                    //nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                                    nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }
                                nSub.Status__c = 'Allocated'; 
                                nSub.System_Account_Id__c = bw.ids;
                                nSub.System_Related_Account__c = nb.acId; 
                                nSub.System_Account_Name__c = bw.name ;
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.get(bw.ids).add(nSub);
                            } else{
                               
                                Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                                nSub.Allocated_Traget__c = nb.proposedTarget;
                                nSub.Proposed_Target__c = '';
                                if(nb.banId != null) {
                                    nSub.Id = nb.banId; 
                                } else {
                                    //nSub.Client_Customer_Relationship__c = bw.ccIds;
                                    //nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                                    nSub.Client_Customer_Relationship__c = nb.ccrId;
                                }
                                nSub.Status__c = 'Allocated';
                                nSub.System_Account_Id__c = bw.ids;
                                nSub.System_Related_Account__c = nb.acId; 
                                nSub.System_Account_Name__c = bw.name ;
                                nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                                nSubBanner.put(bw.ids,new List<Local_Sub_Banner_Allocation__c>{nSub});
                            }
                        } 
                        else if(String.isBlank(nb.proposedTarget) && localInitiative.Has_a_Target__c == true) {
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value is required.'));
                            //return 1;
                            response.returnCode = 1;
                            response.errorMessage = 'Proposed Target value is required.';
                            return response; 
                        } else if(!String.isBlank(nb.proposedTarget) && localInitiative.Has_a_Target__c == false) {
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value should be set to blank.'));
                            //return 1;
                            response.returnCode = 1;
                            response.errorMessage = 'Proposed Target value should be set to blank.';
                            return response; 
                        }
                    } else {
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select the banner related to the selected Sub Banner.'));
                            //return 1;
                            response.returnCode = 1;
                            response.errorMessage = 'Please select the banner related to the selected Sub Banner.';
                            return response; 
                    }
                }
            }
        }
        
        //Check for size and update
        if(nBanner.size() > 0) {
            upsert nBanner.values();
            
            List<Local_Sub_Banner_Allocation__c> nSubBanAllocation = new List<Local_Sub_Banner_Allocation__c>();
            for(Id ids : nBanner.keySet()) {
                 
                if(nSubBanner.containsKey(ids)){
                    for(Local_Sub_Banner_Allocation__c nb : nSubBanner.get(ids)) {
                        nb.Local_Banner_Allocation__c = nBanner.get(ids).Id;
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
    }//end updateAllocatedUsingWrappers
    
    //Method to insert the data on click of Save
    public integer saveUnallocated() {
        
        //On Allocate allocate records
        Map<Id, List<Local_Sub_Banner_Allocation__c>> nSubBanner = new Map<Id, List<Local_Sub_Banner_Allocation__c>>();
        Map<Id, Local_Banner_Allocation__c> nBanner = new Map<Id, Local_Banner_Allocation__c>();
        
        //On Save Unallocate
        for(Id ids : bannerResults.keySet()) {
           
            //Record modification of Banner Allocation
             if(bannerResults.get(ids).checked == true) {
                 if(bannerResults.get(ids).proposed != null && bannerResults.get(ids).proposed != '' && localInitiative.Has_a_Target__c == true) { 
               
                    Local_Banner_Allocation__c nban = new Local_Banner_Allocation__c();
                    
                    if(bannerResults.get(ids).banIds != null)  {
                        nban.Id = bannerResults.get(ids).banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;                        
                        nban.Local_Initiative__c = localInitiative.Id;
                    }
                    
                    nban.Local_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nban.Proposed_Target__c = bannerResults.get(ids).proposed;
                    
                    if(bannerResults.get(ids).target != '' && bannerResults.get(ids).target != null  ) {
                        //nban.Status__c = 'Unallocated';
                    } else {
                        nban.Status__c = 'Unallocated';
                    }
                    nban.System_Account_Id__c = bannerResults.get(ids).ids;
                    nban.System_Account_Name__c = bannerResults.get(ids).name ;
                    nban.Local_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nBanner.put(ids, nban);
                } else if((bannerResults.get(ids).proposed == null || bannerResults.get(ids).proposed == '') && localInitiative.Has_a_Target__c == true) {
               
                    Local_Banner_Allocation__c nban = new Local_Banner_Allocation__c();
                    
                    if(bannerResults.get(ids).banIds != null)  {
                        nban.Id = bannerResults.get(ids).banIds;
                    } else {
                        nban.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                        nban.Local_Initiative__c = localInitiative.Id;
                    }
                    
                    nban.Local_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nban.Proposed_Target__c = bannerResults.get(ids).proposed;
                    
                    if(bannerResults.get(ids).target != '' && bannerResults.get(ids).target != null  ) {
                        //nban.Status__c = 'Unallocated';
                    } else {
                        nban.Status__c = 'Unallocated';
                    }
                    nban.System_Account_Id__c = bannerResults.get(ids).ids;
                    nban.System_Account_Name__c = bannerResults.get(ids).name ;
                    nban.Local_Banner_Allocation_Name__c = bannerResults.get(ids).name ;
                    nBanner.put(ids, nban);
                }
                 else if(String.isBlank(bannerResults.get(ids).proposed)  && localInitiative.Has_a_Target__c == true){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value is required.'));
                   return 1;     
               } else if(!String.isBlank(bannerResults.get(ids).proposed)  && localInitiative.Has_a_Target__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value should be set to blank.'));
                    return 1;                
               }
            }
            
            for(NBAWrapper nb : bannerResults.get(ids).nbaWrap) {
                if(nb.isChecked == true) {
                    if(nb.proposedTarget != null && nb.proposedTarget != '' && localInitiative.Has_a_Target__c == true) { 
                       if(nSubBanner.containsKey(ids)) {
                      
                           Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                           nSub.Proposed_Target__c = nb.proposedTarget;
                           
                           if(nb.banId != null) { 
                               nSub.Id = nb.banId;
                           } else {
                               //nSub.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                               //nSub.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                               nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                           }
                           
                           if(nb.allocated != null && nb.allocated != '') {
                              // nSub.Status__c = 'Unallocated';
                           } else {
                               nSub.Status__c = 'Unallocated';
                           }
                           nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                           nSub.System_Related_Account__c = nb.acId; 
                           nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                           nSubBanner.get(ids).add(nSub);
                       } else {
                           Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.name; 
                           nSub.Proposed_Target__c = nb.proposedTarget;
                           if(nb.banId != null) {
                               nSub.Id = nb.banId; 
                           }else {
                                //nSub.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                                nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                           }
                           
                           if(nb.allocated != null && nb.allocated != '') {
                              // nSub.Status__c = 'Unallocated';
                           } else {
                               nSub.Status__c = 'Unallocated';
                           }
                           nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                           nSub.System_Related_Account__c = nb.acId; 
                           nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                           nSubBanner.put(ids, new List<Local_Sub_Banner_Allocation__c>{nSub});
                       }
                   }
                   else if((nb.proposedTarget == null || nb.proposedTarget != '') && localInitiative.Has_a_Target__c == false) { 
                       if(nSubBanner.containsKey(ids)) {
                      
                           Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.name;
                           nSub.Proposed_Target__c = nb.proposedTarget;
                           if(nb.banId != null) { 
                               nSub.Id = nb.banId;
                           } else {
                               //nSub.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                               nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                           }
                           
                           if(nb.allocated != null && nb.allocated != '') {
                              // nSub.Status__c = 'Unallocated';
                           } else {
                               nSub.Status__c = 'Unallocated';
                           }
                           nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                           nSub.System_Related_Account__c = nb.acId; 
                           nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                           nSubBanner.get(ids).add(nSub);
                       } else {
                           Local_Sub_Banner_Allocation__c nSub = new Local_Sub_Banner_Allocation__c();
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.name; 
                           nSub.Proposed_Target__c = nb.proposedTarget;
                           if(nb.banId != null) {
                               nSub.Id = nb.banId; 
                           }else {
                                //nSub.Client_Customer_Relationship__c = bannerResults.get(ids).ccIds;
                                nSub.Client_Customer_Relationship__c = mapCCRSubBanner.get(nb.acId);
                           }
                           
                           if(nb.allocated != null && nb.allocated != '') {
                              // nSub.Status__c = 'Unallocated';
                           } else {
                               nSub.Status__c = 'Unallocated';
                           }
                           nSub.System_Account_Id__c = bannerResults.get(ids).ids;
                           nSub.System_Related_Account__c = nb.acId; 
                           nSub.System_Account_Name__c = bannerResults.get(ids).name ;
                           nSub.Local_Sub_Banner_Allocation_Name__c = nb.Name ;
                           nSubBanner.put(ids, new List<Local_Sub_Banner_Allocation__c>{nSub});
                       }
                   } 
                   else if(String.isBlank(bannerResults.get(ids).proposed)  && localInitiative.Has_a_Target__c == true){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value is required.'));
                       return 1;     
                   } else if(!String.isBlank(bannerResults.get(ids).proposed)  && localInitiative.Has_a_Target__c == false) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Proposed Target value should be set to blank.'));
                        return 1;                 
                   }
                }
            }
        }
        
        //Check for size and update
        if(nBanner.size() > 0) {
            upsert nBanner.values();
            
            List<Local_Sub_Banner_Allocation__c> nSubBanAllocation = new List<Local_Sub_Banner_Allocation__c>();
            for(Id ids : nBanner.keySet()) {
                
                if(nSubBanner.containsKey(ids)) {
                    for(Local_Sub_Banner_Allocation__c nb : nSubBanner.get(ids)) {
                        nb.Local_Banner_Allocation__c = nBanner.get(ids).Id;
                        nSubBanAllocation.add(nb);
                    }
                }
            }
            upsert nSubBanAllocation;
        }
        return 0;
    }

    //Save and Exit button method
    public pageReference saveAndExit() {
        
        try {
            integer er = saveUnallocated();
            if(er == 0) {
                PageReference ref = new PageReference('/'+localInitiative.Local_Strategy__c);
                ref.setRedirect(true);
                return ref;  
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;            
        }  
        return null;
    }
    
    //Save and New Initiative button method
    public pageReference saveAndNewInitiative() {
        
        try {
            integer er = saveUnallocated();
            if(er == 0) {
                PageReference ref = new PageReference('/apex/LocalStrategyItem?StrategyId='+ localInitiative.Local_Strategy__c);
                ref.setRedirect(true);
                return ref;  
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;            
        }  
        return null;
    }
    
    public pageReference allocateAndExit() {
        System.debug('before returnCode----'+returnCode);
        System.debug('before errorMessage----'+errorMessage);
        try {
             Integer er = Integer.valueOf(returnCode);// updateAllocated();
            
            if(er == 0) {
                PageReference ref = new PageReference('/'+localInitiative.Local_Strategy__c);
                ref.setRedirect(true);
                return ref; 
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessage));
                return null;
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;            
        }   
        return null;
        
    }
    public PageReference Exit()
    {
        PageReference ref = new PageReference('/'+localInitiative.Local_Strategy__c);
        ref.setRedirect(true);
        return ref; 
    }
    
    public pageReference allocateAndNewInitiative() {
        System.debug('before returnCode----'+returnCode);
        System.debug('before errorMessage----'+errorMessage);
        try {
            integer er = Integer.valueOf(returnCode);//updateAllocated();
            
            if(er == 0) {
                PageReference ref = new PageReference('/apex/LocalStrategyItem?StrategyId='+ localInitiative.Local_Strategy__c);
                ref.setRedirect(true);
                return ref;  
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessage));
                return null;
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;            
        }    
        return null;
    }
        
   public class NBAWrapper{
        public String name {get;set;}
        public Boolean isChecked {get;set;}
        public String allocated {get;set;}
        public Id acId {get;set;}
        public Id ccrId {get;set;}
        public String proposedTarget {get;set;}
        public Id banId {get;set;}
        public String Customertype {get;set;}
        public String customerSubType {get;set;}
        public boolean wam {get;set;}
        public string clientCustomerTier {get;set;}
        public NBAWrapper()  {
            name = '';
            isChecked = false;
            allocated = '';
            acId = null;
            banId = null;
            proposedTarget = '';
            Customertype = '';            
            customerSubType = '';
            wam = false;
            clientCustomerTier ='';
        } 
    }
    
   public class BannerWrapper {
        public Boolean checked{get;set;}
        public Integer index {get;set;}
        public string target { get; set;}
        public string proposed { get; set;}
        public string name{ get; set;}
        public id ids{ get; set;}
        public id banIds {get;set;}
        public id ccIds {get;set;}
        public List<NBAWrapper> nbaWrap {get;set;} 
        public String customerType {get;set;}
        public String customerSubType {get;set;}
        public boolean wam {get;set;}
        public string clientCustomerTier {get;set;}
        public BannerWrapper(){
            target = '';
            index = 0;
            checked = false;
            ids = null;
            proposed = '';
            banIds = null;
            ccIds = null;
            nbaWrap = new List<NBAWrapper>();
            customerType = '';
            customerSubType = '';
            wam = false;
            clientCustomerTier ='';
        }
    }    
}