/**************************************************************************************
Apex Class Name:  LocalStrategyController
Version     : 1.0
Created Date    : 10 Sep 2016
Description    : Controller class for the Local Strategy Header and Item page.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rahul Nasa                  10 Sep-2016             Original Version
*************************************************************************************/

public without sharing class LocalStrategyController{
    public List<ProductWrapper> searchResults {get;set;}
    public string localInitiativeID{get;set;}
    public Account client{get;set;}
    public Boolean displayPopup {get; set;}
    public String productsSelected {get;set;}
    public String UPCSelected {get;set;}
    public string productGroupsSelected{get;set;}
    public Product__c acc{get;set;}
    public Local_Initiative__c localInitiative{get;set;}
    public List<Product__c> accountList {get;set;}
    private List<Product__c> selproductList {get;set;}
    public Integer page{get;set;}
    private string strQuery {get;set;}
    public Map<Id,Product__c> selectedProMap{get;set;}
    public String searchCriteria {get;set;}
    public string searchText{get;set;}
    public set<Id> setSelectedPro{get;set;}
    public boolean displayProductSKU {get;set;}
    public boolean displayProductGroup {get;set;}
    public boolean displaySubBanner{get;set;}
    public set<string> depParam{get;set;}
    public set<string> catParam{get;set;}
    public set<string> brandParam{get;set;}
    public set<string> prodParam{get;set;}
    public set<string> itemParam{get;set;}
    public set<string> uomParam{get;set;}
    public set<string> coreFlexParam{get;set;}
    public string ProductGroup{get;set;}
    public string Brand{get;set;}
    public String startDate{get;set;}
    public String endDate{get;set;}
    public Local_Strategy__c localStrategy{get;set;}
    public string searchCriteriaProd{get;set;}
    public string bonusChecked{get;set;}
    public string hasTarget{get;set;}
    public boolean productSKUFlag{get;set;}
    public boolean productGroupFlag{get;set;}
    public boolean NoneFlag{get;set;}
    public boolean brandFlag{get;set;}
    public string RadioSelection{get;set;}
    public boolean editPG{get;set;}
    public boolean editBrand{get;set;}
    public boolean edit{get;set;}
    private set<Id> setChannelL4{get;set;}
    public string isTarget{get;set;}
    public boolean L4Panel{get;set;}


    public string localStrategystartdate{get;set;}
    public string localStrategyenddate{get;set;}
    private List<National_Strategy__c> listNS;


    public integer totalRecs = 0;
    public integer totalbannerRecs =0;
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    public boolean AllProducts {get;set;}
    public boolean SelProducts {get;set;}
    public Integer totalPages{get;set;}
    public List<string> listItemValue{get;set;}
    public string NSValue{get;set;}
    public List<string> listUnitOfMeasure{get;set;}
    //public string listUnitOfMeasure{get;set;}
    //public List<string> listDepartment{get;set;}
    public List<DepartmentWrapper> ListDepartment{get;set;}
    public List<DepartmentWrapper> ListBrandDepartment{get;set;}
    public List<DepartmentWrapper> ListPGDepartment{get;set;}
    public string strategyType{get;set;}
    private string CustomerRecordTypeName;
    private Client_Customer_Relationship__c objCcRel;


    public list<CategoryWrapper> listCategory{get;set;}
    public list<CategoryWrapper> listBrandCategory{get;set;}
    public list<CategoryWrapper> listPGCategory{get;set;}

    public list<productGroupWrapper> ListProductGroup{get;set;}
    public list<productGroupWrapper> ListPGProductGroup{get;set;}

    public List<BrandWrapper> ListBrand{get;set;}
    public List<BrandWrapper> ListBrandBrand{get;set;}
    public List<BrandWrapper> ListPGBrand{get;set;}
    public List<string> listStatus{get;set;}
    public List<string> listPriority{get;set;}
    public List<string> listCoreFlex{get;set;}
    private String clientID;
    private string CCRelId;
    private string localStrategyID;
      /**
     * @Desc : public constructor
     */
    public LocalStrategyController() {

            CCRelId = ApexPages.currentPage().getParameters().get('CCRelId');
            localStrategyID = ApexPages.currentPage().getParameters().get('strategyID');
            localStrategy = new Local_Strategy__c();
            RadioSelection = 'None';
            NoneFlag = true;
            strategyType ='Local';
            acc= new Product__c();
            displaySubBanner = false;
            client = new Account();
            displayProductSKU = false;
            displayProductGroup  = false;
            localInitiativeID = ApexPages.currentPage().getParameters().get('id');
            localInitiative = new Local_Initiative__c();
            if(String.isNotBlank(localInitiativeID))
            {

                 localInitiative = [Select Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Comments__c,Priority__c,Active__c,Product_SKU__c ,Brand__c ,Product_Group__c ,Bonus_Eligibility__c,Local_Strategy__c,Local_Strategy__r.Client_Customer_Relationship__c,Has_a_Target__c from Local_Initiative__c where id=:localInitiativeID ];
                 localStrategy = new Local_Strategy__c(id=localInitiative.Local_Strategy__c);
                 if(String.isBlank(localStrategyID)) localStrategyID = localStrategy.Id;
                 If(String.isBlank(CCRelId))
                 {
                     CCRelId = localInitiative.Local_Strategy__r.Client_Customer_Relationship__c;
                 }

                 if(localInitiative.Initiative_Start_Date__c !=null)
                     startDate  = DateTime.newInstance(localInitiative.Initiative_Start_Date__c.year(),localInitiative.Initiative_Start_Date__c.month(),localInitiative.Initiative_Start_Date__c.day()).format('MM/dd/yyyy');

                 If(localInitiative.Bonus_Eligibility__c )
                     bonusChecked = 'Yes';
                 else
                     bonusChecked = 'No';
                 if(localInitiative.Initiative_End_Date__c!=null)
                     endDate = DateTime.newInstance(localInitiative.Initiative_End_Date__c.year(),localInitiative.Initiative_End_Date__c.month(),localInitiative.Initiative_End_Date__c.day()).format('MM/dd/yyyy');
                 if(localInitiative.Product_SKU__c !=null)
                     productsSelected = localInitiative.Product_SKU__c;
                 if(localInitiative.Brand__c != null)
                 {
                     Brand = localInitiative.Brand__c ;
                 }
                 if(localInitiative.Product_Group__c !=null)
                 {
                     ProductGroup = localInitiative.Product_Group__c;
                 }
            }
            if(string.IsNOTBlank(localStrategyID))
            {
                localStrategy = [Select Client_Customer_Relationship__c,Id,Name from Local_Strategy__c where id=:localStrategyID];
                system.debug('localStrategy-->' + localStrategy);
                If(String.isBlank(CCRelId))
                {
                     CCRelId = localStrategy.Client_Customer_Relationship__c;
                }
            }
            system.debug('CCRelId-->' + CCRelId);
            if(String.isNOTBlank(CCRelId))
            {
                //objCcRel = [Select Id,Client__c,Customer__c,Customer__r.RecordType.name,Customer__r.Name,Parent_Relationship__c from Client_Customer_Relationship__c where Id =: CCRelId Limit 1];
                objCcRel = [Select Id,Client__c,Customer__c,Customer__r.RecordType.name,Customer__r.Name,Status__c from Client_Customer_Relationship__c where Id =: CCRelId Limit 1];

                if(objCcRel.Customer__r.RecordType.name == 'Customer - Banner - L4')
                {
                    L4Panel = true;
                }
                else if(objCcRel.Customer__r.RecordType.name == 'Customer - Sub Banner - L5')
                {
                    L4Panel = false;
                }
                clientID = objCcRel.Client__c ;
                setChannelL4 = new set<Id>();
                List<Account> listClientL3 = new List<Account>([Select Id,ParentId from Account where ParentId =: clientID]);
                system.debug('clientID-->' + clientID);
                system.debug('setChannelL4-->' + setChannelL4);
                for(Account acnt : listClientL3)
                {
                    setChannelL4.add(acnt.Id);
                }
            }
            if(string.isnotBlank(productsSelected))
            {
                RadioSelection = 'ProductSKU';
                productSKUFlag = true;
                productGroupFlag = false;
                brandFlag = false;
                NoneFlag = false;
            }
            if(string.isnotBlank(Brand))
            {
                RadioSelection = 'Brand';
                productSKUFlag = false;
                productGroupFlag = false;
                brandFlag = true;
                NoneFlag = false;
                editBrand = true;
            }
            if(string.isnotBlank(ProductGroup))
            {
                RadioSelection = 'ProductGroup';
                productSKUFlag = false;
                productGroupFlag = true;
                brandFlag = false;
                NoneFlag = false;
                editPG = true;
            }

            if(accountList !=null && accountList.size()>0){
                accountList=null;
            }
            system.debug('==>AccountMultipleSearchWithPagenationCLS  is calling==>+++');
            //listDepartment = new list<string>();

            If(localInitiative.Has_a_Target__c)
                 hasTarget = 'Yes';
            else
                 hasTarget = 'No';
            setSelectedPro= new set<Id>();
            selectedProMap =new map<Id,Product__c>();
            listItemValue= new List<string>();
            listUnitOfMeasure = new List<string>();
            listStatus = new List<string>();
            listPriority = new List<string>();
            listCoreFlex = new List<string>();
            this.page = 1;
            //accountList  = new List<Account>();
        }

        public void searchAcc(){
            totalRecs = 0;
            OffsetSize = 0;
            AllProducts = true;

            if(accountList !=null && accountList.size()>0){
             accountList=null;
            }
            holdSelected();
            searchAccounts();
        }
          /**
     * @Desc : method to search for the Products
     */
        public Void searchAccounts(){
            string strQueryWithoutOffset ;
            searchCriteria = searchCriteriaProd;
            searchResults = new List<ProductWrapper>();
               set<string> setProdGroupName = new set<string>();
            set<string> setDepName = new set<string>();
            set<string> setCatName = new set<string>();
            set<string> setBrandName = new set<string>();
            if(ListProductGroup !=null && ListProductGroup.size()>0)
            {
                for(ProductGroupWrapper pgw : ListProductGroup )
                {
                    if(pgw.checked)
                        setProdGroupName.add(pgw.prod);
                }
            }
            if(ListDepartment !=null && ListDepartment.size()>0)
            {
                for(DepartmentWrapper dpw : ListDepartment)
                {
                    if(dpw.checked)
                        setDepName.add(dpw.dep);
                }
            }
            if(ListCategory !=null && ListCategory.size()>0)
            {
                for(CategoryWrapper catw : ListCategory)
                {
                    if(catw.checked)
                        setCatName.add(catw.cat);
                }
            }
            if(ListBrand !=null && ListBrand.size()>0)
            {
                for(BrandWrapper brw : ListBrand)
                {
                    if(brw.checked)
                        setBrandName.add(brw.bran);
                }
            }
            system.debug('setChannelL4-->' + setChannelL4);
            If(setChannelL4.size() >0)
             {
                 //ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c in : setChannelL4];
                 strQuery = 'Select Product_Description__c,Id,Department__c,Category__c,Priority__c,UPC__c,Core_Flex__c,Account__c,Account__r.Name,Unit_of_Measure__c,Brand_Name__c,Product_Group_Name__c From Product__c where Status__c = \'Active\' and Account__c in : setChannelL4';
             }
             else
             {
                 //ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c = : clientID ];
                 strQuery = 'Select Product_Description__c,Id,Department__c,Category__c,Priority__c,UPC__c,Core_Flex__c,Account__c,Account__r.Name,Unit_of_Measure__c,Brand_Name__c,Product_Group_Name__c From Product__c where Status__c = \'Active\' and Account__c = : clientID';
             }

            if(AllProducts== false)
            {
                  Set<Id> proIds = selectedProMap.keySet();
                  strQuery += '  AND ID IN : proIds ';
            }
            system.debug('searchCriteria-->' + searchCriteria);
            if(String.isNotBlank(searchCriteria)){
                strQuery+=' AND (Product_Description__c Like \'%' +String.escapeSingleQuotes(searchCriteria ) +'%\'  OR UPC__c Like \'%' +String.escapeSingleQuotes(searchCriteria ) +'%\' OR Account__r.Name Like \'%' +String.escapeSingleQuotes(searchCriteria ) +'%\')';
            }
            if(listUnitOfMeasure.size()>0){
                strQuery += '  AND Unit_of_Measure__c IN : listUnitOfMeasure ';
            }
            if(listPriority.size()>0){
                strQuery += '  AND Priority__c  IN : listPriority ';
            }
            if(listCoreFlex.size()>0){
                strQuery += ' AND Core_Flex__c in: listCoreFlex ';
            }
            if(listItemValue.size()>0){
                strQuery += '  AND New_Item__c IN: listItemValue ';
            }
            if(setProdGroupName.size()>0){
                strQuery += '  AND Product_Group_Name__c IN: setProdGroupName';
            }
            if(setDepName.size()>0){
                strQuery += '  AND Department__c IN: setDepName';
            }
            if(setCatName.size()>0){
                strQuery += '  AND Category__c IN: setCatName';
            }
            if(setBrandName.size()>0){
                strQuery += '  AND Brand_Name__c IN: setBrandName';
            }
            strQueryWithoutOffset = strQuery;
            List<Product__c> listProductResult = Database.Query(strQueryWithoutOffset );
            totalRecs = (listProductResult !=null && listProductResult.size()>0)?listProductResult.size():0;
            strQuery+=' ORDER BY Priority__c  ASC, Product_Description__c ASC LIMIT :LimitSize OFFSET :OffsetSize';
            if(OffsetSize > 2000){
                OffsetSize = 2000;
            }

            List<Product__c> listPro =  Database.Query(strQuery);
             for(Product__c pro:listPro ){
                ProductWrapper wrap = new ProductWrapper();
                if(selectedProMap.containsKey(pro.Id)){
                    wrap.checked = true;
                }
                else{
                    wrap.checked = false;
                }
                wrap.pro = pro;
                searchResults.add(wrap);
            }
            if(totalRecs >2000)
            {
                 totalRecs =2000;
            }
            Decimal pages = Decimal.valueOf(totalRecs);
            pages = pages.divide(Decimal.valueOf(LimitSize), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

    }

    public List<ProductWrapper> selectedProducts {
        get {
            //if (selectedProducts == null) selectedProducts = new List<ProductWrapper>();
            return selectedProducts;
        }
        set;
    }
    public void clearFilters(){
        acc=new Product__c();
        listItemValue= new List<string>();
        listUnitOfMeasure = new List<string>();
        listCoreFlex = new List<string>();
        searchCriteriaProd = '';
        ListProductGroup = new List<ProductGroupWrapper>();
        ListCategory = new List<CategoryWrapper>();
        depParam = new Set<String>();
        depParam.add('No Values Selected');
        catParam = new Set<String>();
        catParam.add('No Values Selected');
        brandParam = new Set<String>();
        brandParam.add('No Values Selected');
        prodParam = new Set<String>();
        prodParam.add('No Values Selected');
        itemParam = new Set<String>();
        itemParam.add('No Values Selected');
        uomParam = new Set<String>();
        uomParam.add('No Values Selected');
        coreFlexParam = new Set<String>();
        coreFlexParam.add('No Values Selected');
        searchAccounts();

    }
    public void addSelected()
    {
        displayPopup = false;
        holdSelected();

        productsSelected ='';
        UPCSelected ='';
        for(Id id : selectedProMap.keySet()){
            productsSelected += selectedProMap.get(id).Product_Description__c +',';
            UPCSelected += selectedProMap.get(id).UPC__c +',';
        }
        if(productsSelected.length() >0)
        {
            productsSelected = productsSelected.substring(0,productsSelected.length() -1);
        }
        if(UPCSelected.length() >0)
        {
            UPCSelected = UPCSelected.substring(0,UPCSelected.length() -1);
        }
        if(selectedProMap.size() == 0){
            productsSelected ='';
            UPCSelected ='';
        }

    }
    public void showSelected(){
       totalRecs = 0;
       OffsetSize = 0;
       AllProducts = false;
       holdSelected();
       searchAccounts();


    }
     public List<SelectOption> getNSOptions(){
         system.debug('clientID-->' + clientID);
         listNS = new List<National_Strategy__c>([Select Id,Name from National_Strategy__c where Client__c =: clientID and Status__c !='Closed']);
         system.debug('listNS-->' + listNS);
         List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
         options.add(new selectOption('', '--None--')); //add the first option

         for (National_Strategy__c ns : listNS) { //for all values in the picklist list
             options.add(new selectOption(ns.Id, ns.Name)); //add the value and label to our final list
         }
         return options; //return the List
     }
     public List<SelectOption> getStatusOptions(){
           return AcostaConstants.getPickValues('Product__c','Status__c',null);
     }
     public List<SelectOption> getpriorityOptions(){
           return AcostaConstants.getPickValues('Product__c','Priority__c',null);
     }
     public List<SelectOption> getunitOfMeasureOptions(){
           return AcostaConstants.getPickValues('Product__c','Unit_of_Measure__c',null);
     }
      public List<SelectOption> getcoreFlexOptions(){
            return AcostaConstants.getPickValues('Product__c','Core_Flex__c',null);
     }
     public List<SelectOption> getnewItemOptions(){
           return AcostaConstants.getPickValues('Product__c','New_Item__c',null);
     }
     public List<DepartmentWrapper> getDepartmentOptions()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c = : clientID ];
         }
         set<string> setDepartment =new set<string>() ;
         if( ProductTemp.size()>0)
         {
             ListDepartment = new List<DepartmentWrapper>();
             DepartmentWrapper dw = new DepartmentWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setDepartment.contains(prod.Department__c))
                {
                   dw = new DepartmentWrapper();
                   dw.dep = prod.Department__c;
                   ListDepartment.add(dw);

                }
                setDepartment.add(prod.Department__c);

             }

         }
         return ListDepartment;
     }

     public List<DepartmentWrapper> getBrandDepartmentOptions()
     {


         List<Product__c> ProductTemp = new List<Product__c>();
          If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c = : clientID ];
         }
         set<string> setDepartment =new set<string>() ;
         if( ProductTemp.size()>0)
         {
             ListBrandDepartment = new List<DepartmentWrapper>();
             DepartmentWrapper dw = new DepartmentWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setDepartment.contains(prod.Department__c))
                {
                   dw = new DepartmentWrapper();
                   dw.dep = prod.Department__c;
                   ListBrandDepartment.add(dw);

                }
                setDepartment.add(prod.Department__c);

             }

         }
         return ListBrandDepartment;
     }
     public List<DepartmentWrapper> getPGDepartmentOptions()
     {


         List<Product__c> ProductTemp = new List<Product__c>();
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Department__c From Product__c where Department__c!=null and Account__c = : clientID ];
         }
         set<string> setDepartment =new set<string>() ;
         if( ProductTemp.size()>0)
         {
             ListPGDepartment = new List<DepartmentWrapper>();
             DepartmentWrapper dw = new DepartmentWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setDepartment.contains(prod.Department__c))
                {
                   dw = new DepartmentWrapper();
                   dw.dep = prod.Department__c;
                   ListPGDepartment.add(dw);

                }
                setDepartment.add(prod.Department__c);

             }

         }
         return ListPGDepartment;
     }

     public List<BrandWrapper> getBrandOptions()
     {


         List<Product__c> ProductTemp = new List<Product__c>();
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c = : clientID ];
         }
         set<string> setBrand = new set<string>();
         if( ProductTemp.size()>0)
         {
             ListBrand = new List<BrandWrapper>();
             BrandWrapper bw = new BrandWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setBrand.contains(prod.Brand_Name__c ))
                {
                   bw = new BrandWrapper();
                   bw.bran = prod.Brand_Name__c;
                   ListBrand.add(bw);

                }
                setBrand.add(prod.Brand_Name__c);

             }

         }
         return ListBrand;
     }
     public List<BrandWrapper> getBrandBrandOptions()
     {
         if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0)
         {


         }
         else
         {
             List<Product__c> ProductTemp = new List<Product__c>();
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c = : clientID ];
             }
             set<string> setBrand = new set<string>();
             if( ProductTemp.size()>0)
             {
                 ListBrandBrand = new List<BrandWrapper>();
                 BrandWrapper bw = new BrandWrapper();
                 for(Product__c prod : ProductTemp )
                 {

                    if(!setBrand.contains(prod.Brand_Name__c ))
                    {
                       bw = new BrandWrapper();
                       bw.bran = prod.Brand_Name__c;
                       ListBrandBrand.add(bw);

                    }
                    setBrand.add(prod.Brand_Name__c);

                 }

             }
         }
         return ListBrandBrand;

     }
      public List<BrandWrapper> getPGBrandOptions()
     {


         List<Product__c> ProductTemp = new List<Product__c>();
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Account__c = : clientID ];
         }
         set<string> setBrand = new set<string>();
         if( ProductTemp.size()>0)
         {
             ListPGBrand = new List<BrandWrapper>();
             BrandWrapper bw = new BrandWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setBrand.contains(prod.Brand_Name__c ))
                {
                   bw = new BrandWrapper();
                   bw.bran = prod.Brand_Name__c;
                   ListPGBrand.add(bw);

                }
                setBrand.add(prod.Brand_Name__c);

             }

         }
         return ListPGBrand ;
     }
     public List<CategoryWrapper> getCategoryOptions()
     {
         return ListCategory;
     }
     public List<CategoryWrapper> getBrandCategoryOptions()
     {
         return ListBrandCategory;
     }
     public List<CategoryWrapper> getPGCategoryOptions()
     {
         return ListPGCategory;
     }
     public List<ProductGroupWrapper> getProductGroupOptions()
     {
         return ListProductGroup;
     }
     public List<ProductGroupWrapper> getPGProductGroupOptions()
     {
         return ListPGProductGroup;
     }
     public Void doDepActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         depParam = new set<string>();
         set<string> setCategory = new set<string>();
         for(DepartmentWrapper dw : ListDepartment)
         {
             if(dw.checked)
             {
                depParam.add(dw.dep);
             }
         }
         system.debug('depParam-->' + depParam);
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c = : clientID ];
         }
         if( ProductTemp.size()>0)
         {
             ListCategory = new List<CategoryWrapper>();
             CategoryWrapper cw = new CategoryWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setCategory.contains(prod.Category__c))
                {
                   cw = new CategoryWrapper();
                   cw.cat = prod.Category__c;
                   ListCategory.add(cw);

                }
                setCategory.add(prod.Category__c);

             }

         }
         //return ListCategory;
     }
     public Void doBrandDepActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         depParam = new set<string>();
         set<string> setCategory =new set<string>() ;
         for(DepartmentWrapper dw : ListBrandDepartment)
         {
             if(dw.checked)
             {
                depParam.add(dw.dep);
             }
         }
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c = : clientID ];
         }

         if( ProductTemp.size()>0)
         {
             listBrandCategory = new List<CategoryWrapper>();
             CategoryWrapper cw = new CategoryWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setCategory.contains(prod.Category__c))
                {
                   cw = new CategoryWrapper();
                   cw.cat = prod.Category__c;
                   listBrandCategory.add(cw);

                }
                setCategory.add(prod.Category__c);

             }

         }
         //return ListCategory;
     }
     public Void doPGDepActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         depParam = new set<string>();
         set<string> setCategory =new set<string>() ;
         for(DepartmentWrapper dw : ListPGDepartment)
         {
             if(dw.checked)
             {
                depParam.add(dw.dep);
             }
         }
         system.debug('depParam-->' + depParam);

         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Category__c From Product__c where Category__c!=null and Department__c in: depParam and Account__c = : clientID ];
         }

         if( ProductTemp.size()>0)
         {
             listPGCategory = new List<CategoryWrapper>();
             CategoryWrapper cw = new CategoryWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setCategory.contains(prod.Category__c))
                {
                   cw = new CategoryWrapper();
                   cw.cat = prod.Category__c;
                   listPGCategory.add(cw);

                }
                setCategory.add(prod.Category__c);

             }

         }
         //return ListCategory;
     }
     public void doCatActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         catParam = new set<string>();
         set<string> setProductGroup = new set<string>();
         for(CategoryWrapper cw : ListCategory)
         {
             if(cw.checked)
             {
                catParam.add(cw.cat);
             }
         }
         system.debug('depParam-->' + depParam);
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c = : clientID ];
         }

         //and Department__c in: depParam and Brand_Name__c in : brandParam];

         if( ProductTemp.size()>0)
         {
             ListProductGroup = new List<ProductGroupWrapper>();
             ProductGroupWrapper pgw = new ProductGroupWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setProductGroup.contains(prod.Product_Group_Name__c))
                {
                   pgw = new ProductGroupWrapper();
                   pgw.prod = prod.Product_Group_Name__c;
                   ListProductGroup.add(pgw);

                }
                setProductGroup.add(prod.Product_Group_Name__c);

             }

         }
     }
     public void doBrandCatActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         catParam = new set<string>();
         set<string> setBrandName = new set<string>();
         for(CategoryWrapper cw : ListBrandCategory)
         {
             if(cw.checked)
             {
                catParam.add(cw.cat);
             }
         }
         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c = : clientID ];
         }

         //and Department__c in: depParam and Brand_Name__c in : brandParam];

         if( ProductTemp.size()>0)
         {
             ListBrandBrand = new List<BrandWrapper>();
             BrandWrapper bgw = new BrandWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setBrandName.contains(prod.Brand_Name__c ))
                {
                   bgw = new BrandWrapper();
                   bgw.bran = prod.Brand_Name__c ;
                   ListBrandBrand.add(bgw);

                }
                setBrandName.add(prod.Brand_Name__c );

             }

         }
     }
     public void doPGCatActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         catParam = new set<string>();
         set<string> setProductGroup = new set<string>();
         for(CategoryWrapper cw : ListPGCategory)
         {
             if(cw.checked)
             {
                catParam.add(cw.cat);
             }
         }
         system.debug('depParam-->' + depParam);

         If(setChannelL4.size() >0)
         {
             ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Department__c in: depParam and Category__c in: catParam  and Account__c in : setChannelL4];
         }
         else
         {
             ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Department__c in: depParam and Category__c in: catParam  and Account__c = : clientID ];
         }

         if( ProductTemp.size()>0)
         {
             ListPGProductGroup = new List<ProductGroupWrapper>();
             ProductGroupWrapper pgw = new ProductGroupWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setProductGroup.contains(prod.Product_Group_Name__c))
                {
                   pgw = new ProductGroupWrapper();
                   pgw.prod = prod.Product_Group_Name__c;
                   ListPGProductGroup.add(pgw);

                }
                setProductGroup.add(prod.Product_Group_Name__c);

             }

         }
     }
     public Void doBrandActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         brandParam = new set<string>();
         set<string> setProductGroup = new set<string>();
         for(BrandWrapper bw : ListBrand)
         {
             if(bw.checked)
             {
                brandParam.add(bw.bran);
             }
         }
         system.debug('depParam-->' + depParam);
         if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0)
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c = : clientID ];
             }
         }
         else
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Brand_Name__c in : brandParam  and Account__c = : clientID ];
             }
         }

         if( ProductTemp.size()>0)
         {
             ListProductGroup = new List<ProductGroupWrapper>();
             ProductGroupWrapper pgw = new ProductGroupWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setProductGroup.contains(prod.Product_Group_Name__c))
                {
                   pgw = new ProductGroupWrapper();
                   pgw.prod = prod.Product_Group_Name__c;
                   ListProductGroup.add(pgw);

                }
                setProductGroup.add(prod.Product_Group_Name__c);

             }

         }
     }

    public Void doBrandBrandActionSupport()
    {
        List<Product__c> ProductTemp = new List<Product__c>();
        brandParam = new set<string>();
        set<string> setProductGroup = new set<string>();
        for(BrandWrapper bw : ListBrandBrand)
        {
            if(bw.checked)
            {
                brandParam.add(bw.bran);
            }
        }
    }


     public Void doPGBrandActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         brandParam = new set<string>();
         set<string> setProductGroup = new set<string>();
         for(BrandWrapper bw : ListPGBrand)
         {
             if(bw.checked)
             {
                brandParam.add(bw.bran);
             }
         }
         system.debug('depParam-->' + depParam);
         if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0)
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c = : clientID ];
             }
         }
         else
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Brand_Name__c in : brandParam  and Account__c = : clientID ];
             }
         }

         if( ProductTemp.size()>0)
         {
             ListPGProductGroup = new List<ProductGroupWrapper>();
             ProductGroupWrapper pgw = new ProductGroupWrapper();
             for(Product__c prod : ProductTemp )
             {

                if(!setProductGroup.contains(prod.Product_Group_Name__c))
                {
                   pgw = new ProductGroupWrapper();
                   pgw.prod = prod.Product_Group_Name__c;
                   ListPGProductGroup.add(pgw);

                }
                setProductGroup.add(prod.Product_Group_Name__c);

             }

         }
     }

    public Void doPGPGActionSupport()
    {
        prodParam = new set<string>();
        for(ProductGroupWrapper pw : ListPGProductGroup)
        {
            if(pw.checked)
            {
                prodParam.add(pw.prod);
            }
        }
    }

    public void doProductUomSKUSupport() {

        uomParam = new Set<String>();
        if (listUnitOfMeasure.size() > 0) {
            for (String uom : listUnitOfMeasure) uomParam.add(uom);
        }
        if (uomParam.isEmpty()) uomParam.add('No Values Selected');
    }

    public void doProductCoreFlexSKUSupport() {

        coreFlexParam = new Set<String>();
        if (listCoreFlex.size() > 0) {
            for (String cf : listCoreFlex) coreFlexParam.add(cf);
        }
        if (coreFlexParam.isEmpty()) coreFlexParam.add('No Values Selected');
    }

    public void doProductItemSKUSupport() {

        itemParam = new Set<String>();
        if(listItemValue.size() > 0) {
            for (String iv : listItemValue) itemParam.add(iv);
        }
        if (itemParam.isEmpty()) itemParam.add('No Values Selected');
    }

    public void doProductPGSKUSupport() {

        prodParam = new set<string>();
        for(ProductGroupWrapper pw : ListProductGroup)
        {
            if(pw.checked)
            {
                prodParam.add(pw.prod);
            }
        }
    }

    public void holdSelected() {
       for(ProductWrapper cw :searchResults){
       system.debug('selectedProMap.size()-->' + selectedProMap.size());
            if(cw.checked && !setSelectedPro.contains(cw.pro.Id)){
                setSelectedPro.add(cw.pro.Id);
                selectedProMap.put(cw.pro.Id, cw.pro);
            }
            else if(!cw.checked && setSelectedPro.contains(cw.pro.Id)){
            system.debug('selectedProMap.size()-->' + selectedProMap.size());
                setSelectedPro.remove(cw.pro.Id);
                selectedProMap.remove(cw.pro.Id);
            }

        }
    }
     /**
     * @Desc : method to First Page
     */
    public void FirstPage()
    {
        OffsetSize = 0;
        holdSelected();
        searchAccounts();
    }
    /**
     * @Desc : method to Previous
     */
    public void previous()
    {
        OffsetSize = (OffsetSize-LimitSize);
        holdSelected();
        searchAccounts();
    }
    /**
     * @Desc : method to Next
     */
    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        holdSelected();
        searchAccounts();
    }
    /**
     * @Desc : method to Last page
     */
    public void LastPage()
    {
    //OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
     if(math.mod(totalrecs, LimitSize)!=0){
                OffsetSize = totalrecs - math.mod(totalrecs, LimitSize);
            }
            else{
                OffsetSize = totalrecs - LimitSize;
            }
        holdSelected();
        searchAccounts();
    }
    /**
     * @Desc : method to Prev
     */
    public boolean getprev()
    {

        if(OffsetSize == 0){

        return true;
        }
        else {

        return false;
        }
    }
    /**
     * @Desc : method to Next
     */
    public boolean getnxt()
    {
     if (OffsetSize + LimitSize < totalRecs){
                return false;
            }
            else{
                return true;
            }
    }

    // Wrapper Class for checkbox selection
    public class ProductWrapper {

        public Boolean checked{ get; set; }
        public Product__c pro { get; set;}

        public ProductWrapper(){
            pro = new Product__c();
            checked = false;
        }

        public ProductWrapper(Product__c c){
            pro = c;
            checked = false;
        }
    }

    public class DepartmentWrapper {
        public Boolean checked{ get; set; }
        public string dep{get;set;}
        public DepartmentWrapper(){
            checked = false;
        }
    }

    public class CategoryWrapper {
        public Boolean checked{ get; set; }
        public string cat{get;set;}
        public CategoryWrapper(){
            checked = false;
        }
    }

    public class BrandWrapper{

        public Boolean checked{ get; set; }
        public string bran { get; set;}

        public BrandWrapper(){
            checked = false;
        }
    }

    public class ProductGroupWrapper{

        public Boolean checked{ get; set; }
        public string prod{ get; set;}

        public ProductGroupWrapper(){
            checked = false;
        }
    }

    /**
     * @Desc : method to SaveUnAllocatedBannerwithoutsharing
     */
    public integer SaveUnAllocatedBannerwithoutsharing(Client_Customer_Relationship__c objCcRel,Local_Initiative__c  localInitiative)
    {
      try
      {
            List<Account> listSubbanAcnt = new List<Account>([ Select Id,ParentId,Parent.name from Account where Id=:objCcRel.Customer__c]);
            system.debug('listSubbanAcnt[0].ParentId-->' + listSubbanAcnt[0].ParentId);

            //List<Client_Customer_Relationship__c> listCCRel = new List<Client_Customer_Relationship__c>([Select Id,Customer__c from Client_Customer_Relationship__c where Customer__c =:listSubbanAcnt[0].ParentId]);
            Client_Customer_Relationship__c listCCRel = [Select Id,Parent_Relationship__r.Customer__c,Parent_Relationship__c,Parent_Relationship__r.Status__c from Client_Customer_Relationship__c where Id =:objCcRel.Id and Status__c = 'Active'];

            map<Id,Id> mapCCRel;

            if(listCCRel !=null && (listCCRel.Parent_Relationship__c != null && listCCRel.Parent_Relationship__r.Status__c == 'Active'))
            {
                mapCCRel = new map<Id,Id>();
                mapCCRel.put(listCCRel.Parent_Relationship__r.Customer__c, listCCRel.Parent_Relationship__c );
                Local_Banner_Allocation__c objLocalbnrAll;
                Local_Sub_Banner_Allocation__c objLocalSubbnrAll;
                List<Local_Banner_Allocation__c> listLocalbnrAll = new List<Local_Banner_Allocation__c>([Select Id, Allocated_Target__c ,Local_Banner_Allocation_Name__c , Proposed_Target__c , System_Account_Name__c, System_Account_Id__c,Status__c From Local_Banner_Allocation__c Where Local_Initiative__c =:localInitiative.Id and System_Account_Id__c=: listSubbanAcnt[0].ParentId]);
                List<Local_Sub_Banner_Allocation__c> listLocalSubbnrAll = new List<Local_Sub_Banner_Allocation__c>();
                if(listLocalbnrAll !=null && listLocalbnrAll.size() >0)
                {
                    listLocalSubbnrAll = [Select Id, Allocated_Traget__c, Proposed_Target__c , System_Account_Name__c,Local_Banner_Allocation__c,Local_Sub_Banner_Allocation_Name__c, System_Account_Id__c,Status__c From Local_Sub_Banner_Allocation__c Where Local_Banner_Allocation__c = : listLocalbnrAll[0].Id];
                }
                if(listLocalbnrAll !=null && listLocalbnrAll.size()>0)
                {
                    for(Local_Banner_Allocation__c lba : listLocalbnrAll)
                    {
                        objLocalbnrAll = new Local_Banner_Allocation__c(Id = lba.Id);
                        objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                        objLocalbnrAll.Proposed_Target__c = localInitiative.Target__c;
                        objLocalbnrAll.System_Account_Name__c = listSubbanAcnt[0].Parent.name;
                        objLocalbnrAll.System_Account_Id__c = listSubbanAcnt[0].ParentId;
                        objLocalbnrAll.Local_Banner_Allocation_Name__c = listSubbanAcnt[0].Parent.name;
                    }
                    update objLocalbnrAll;
                }
                else
                {
                    objLocalbnrAll = new Local_Banner_Allocation__c();
                    objLocalbnrAll.Proposed_Target__c = localInitiative.Target__c;
                    objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                    objLocalbnrAll.Client_Customer_Relationship__c = mapCCRel.get(listSubbanAcnt[0].ParentId);
                    objLocalbnrAll.Status__c = 'Unallocated';
                    objLocalbnrAll.System_Account_Name__c = listSubbanAcnt[0].Parent.name;
                    objLocalbnrAll.System_Account_Id__c = listSubbanAcnt[0].ParentId;
                    objLocalbnrAll.Local_Banner_Allocation_Name__c = listSubbanAcnt[0].Parent.name;
                    insert objLocalbnrAll;
                }

                if(listLocalSubbnrAll !=null && listLocalSubbnrAll.size()>0)
                {
                    for(Local_Sub_Banner_Allocation__c lsba : listLocalSubbnrAll )
                    {
                        objLocalSubbnrAll = new Local_Sub_Banner_Allocation__c(Id = lsba.Id);
                        objLocalSubbnrAll.Proposed_Target__c = localInitiative.Target__c;
                        objLocalSubbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                        objLocalSubbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                        objLocalSubbnrAll.Local_Sub_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    }
                    update objLocalSubbnrAll;
                }
                else
                {
                    objLocalSubbnrAll = new Local_Sub_Banner_Allocation__c();
                    objLocalSubbnrAll.Proposed_Target__c = localInitiative.Target__c;
                    objLocalSubbnrAll.Status__c = 'Unallocated';
                    objLocalSubbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                    objLocalSubbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                    objLocalSubbnrAll.Local_Sub_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    objLocalSubbnrAll.Local_Banner_Allocation__c = objLocalbnrAll.Id;
                    objLocalSubbnrAll.Client_Customer_Relationship__c = objCcRel.Id;
                    insert objLocalSubbnrAll ;
                }
                return 0;
            }
            else
            {
                return 2;
            }
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return 1;
        }

    }
    /**
     * @Desc : method to SaveAllocatedBannerwithoutsharing
     */
    public integer SaveAllocatedBannerwithoutsharing(Client_Customer_Relationship__c objCcRel ,Local_Initiative__c localInitiative)
    {
       try
        {


            List<Account> listSubbanAcnt = new List<Account>([ Select Id,ParentId,parent.name from Account where Id=:objCcRel.Customer__c]);
            //List<Client_Customer_Relationship__c> listCCRel = new List<Client_Customer_Relationship__c>([Select Id,Customer__c from Client_Customer_Relationship__c where Customer__c =:listSubbanAcnt[0].ParentId  and Id =: objCcRel.Parent_Relationship__c]);
            //List<Client_Customer_Relationship__c> listCCRel = new List<Client_Customer_Relationship__c>([Select Id,Customer__c from Client_Customer_Relationship__c where Customer__c =:listSubbanAcnt[0].ParentId]);
            Client_Customer_Relationship__c listCCRel = [Select Id,Parent_Relationship__r.Customer__c,Parent_Relationship__r.Status__c,Parent_Relationship__c from Client_Customer_Relationship__c where Id =:objCcRel.Id and Status__c = 'Active'];

            map<Id,Id> mapCCRel;

            if(listCCRel !=null && (listCCRel.Parent_Relationship__c != null && listCCRel.Parent_Relationship__r.Status__c == 'Active'))
            {
                mapCCRel = new map<Id,Id>();
                mapCCRel.put(listCCRel.Parent_Relationship__r.Customer__c, listCCRel.Parent_Relationship__c );
                Local_Banner_Allocation__c objLocalbnrAll;
                Local_Sub_Banner_Allocation__c objLocalSubbnrAll;
                system.debug('listSubbanAcnt[0].ParentId-->' + listSubbanAcnt[0].ParentId);
                List<Local_Banner_Allocation__c> listLocalbnrAll = new List<Local_Banner_Allocation__c>([Select Id, Allocated_Target__c , Proposed_Target__c ,Local_Banner_Allocation_Name__c , System_Account_Name__c, System_Account_Id__c,Status__c From Local_Banner_Allocation__c Where Local_Initiative__c =:localInitiative.Id and System_Account_Id__c=: listSubbanAcnt[0].ParentId]);
                List<Local_Sub_Banner_Allocation__c> listLocalSubbnrAll = new List<Local_Sub_Banner_Allocation__c>();
                if(listLocalbnrAll !=null && listLocalbnrAll.size() >0)
                {
                    listLocalSubbnrAll = [Select Id, Allocated_Traget__c, Proposed_Target__c , System_Account_Name__c,Local_Banner_Allocation__c, System_Account_Id__c,Local_Sub_Banner_Allocation_Name__c,Status__c From Local_Sub_Banner_Allocation__c Where Local_Banner_Allocation__c = : listLocalbnrAll[0].Id];
                }
                if(listLocalbnrAll !=null && listLocalbnrAll.size()>0)
                {
                    for(Local_Banner_Allocation__c lba : listLocalbnrAll)
                    {
                        objLocalbnrAll = new Local_Banner_Allocation__c(Id = lba.Id);
                        objLocalbnrAll.Allocated_Target__c = localInitiative.Target__c;
                        objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                        objLocalbnrAll.Status__c = 'Allocated';
                        objLocalbnrAll.System_Account_Name__c = listSubbanAcnt[0].Parent.name;
                        objLocalbnrAll.System_Account_Id__c = listSubbanAcnt[0].ParentId;
                        objLocalbnrAll.Local_Banner_Allocation_Name__c = listSubbanAcnt[0].parent.name;
                    }
                    update objLocalbnrAll;
                }
                else
                {
                    objLocalbnrAll = new Local_Banner_Allocation__c();
                    objLocalbnrAll.Allocated_Target__c = localInitiative.Target__c;
                    objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                    objLocalbnrAll.Client_Customer_Relationship__c = mapCCRel.get(listSubbanAcnt[0].ParentId);
                    objLocalbnrAll.Status__c = 'Allocated';
                    objLocalbnrAll.System_Account_Name__c = listSubbanAcnt[0].Parent.name;
                    objLocalbnrAll.System_Account_Id__c = listSubbanAcnt[0].ParentId;
                    objLocalbnrAll.Local_Banner_Allocation_Name__c = listSubbanAcnt[0].parent.name;
                    insert objLocalbnrAll;
                }
                if(listLocalSubbnrAll !=null && listLocalSubbnrAll.size()>0)
                {
                    for(Local_Sub_Banner_Allocation__c lsba : listLocalSubbnrAll )
                    {
                        objLocalSubbnrAll = new Local_Sub_Banner_Allocation__c(Id = lsba.Id);
                        objLocalSubbnrAll.Allocated_Traget__c = localInitiative.Target__c;
                        objLocalbnrAll.Status__c = 'Allocated';
                        objLocalSubbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                        objLocalSubbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                        objLocalSubbnrAll.Local_Sub_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;

                    }
                    update objLocalSubbnrAll;
                }
                else
                {
                    objLocalSubbnrAll = new Local_Sub_Banner_Allocation__c();
                    objLocalSubbnrAll.Allocated_Traget__c = localInitiative.Target__c;
                    objLocalSubbnrAll.Status__c = 'Allocated';
                    objLocalSubbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                    objLocalSubbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                    objLocalSubbnrAll.Local_Sub_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    objLocalSubbnrAll.Local_Banner_Allocation__c = objLocalbnrAll.Id;
                    objLocalSubbnrAll.Client_Customer_Relationship__c = objCcRel.Id;
                    insert objLocalSubbnrAll ;
                }
                return 0;
            }
            else
            {
                return 2;
            }
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return 1;
        }
    }


    /**
     * @Desc : method to gettotalRecs
     */
    public Integer gettotalRecs(){
        return totalRecs;
    }
    /**
     * @Desc : method to getPageNumber
     */
    public Integer getPageNumber(){
    //Integer PageNumber =1;
        if(OffsetSize ==0){
            return 1 ;
        }
        else{
           // PageNumber =
            return (OffsetSize /LimitSize)+1;
        }
    }
    /**
     * @Desc : method to showPopup
     */
    public void showPopup() {
        displayPopup = true;
        totalRecs = 0;
        OffsetSize = 0;
        totalPages=0;
        this.page=1;
        //searchAcc();
        searchAccounts() ;
    }
    /**
     * @Desc : method to ClearSelection
     */
    public void ClearSelection()
    {
        localInitiative.Brand__c='';
        localInitiative.Product_Group__c ='';
        localInitiative.Product_SKU__c ='';
        listBrandCategory = new List<CategoryWrapper>();
        listPGCategory = new List<CategoryWrapper>();
        ListBrandBrand = new List<BrandWrapper>();
        ListPGProductGroup = new List<ProductGroupWrapper>();
        ListPGBrand = new List<BrandWrapper>();
        RadioSelection = 'None';
        productSKUFlag = false;
        productGroupFlag = false;
        brandFlag = false;
        NoneFlag = true;
        editPG = false;
        editBrand = false;
        Brand ='';
        ProductGroup ='';
        productsSelected ='';
        UPCSelected='';
        selectedProMap = new map<Id,Product__c>();
        setSelectedPro = new set<Id>();
        clearFilters();

    }
    /**
     * @Desc : method to ChangeRadio
     */
     public void ChangeRadio()
    {
        Boolean errorFlag = false;
        ProductSelectionType();
        if(RadioSelection == 'ProductSKU')
        {
            if(string.IsBlank(ProductGroup ) && string.IsBlank(Brand))
            {
                productSKUFlag = true;
                productGroupFlag = false;
                brandFlag = false;
                NoneFlag = false;
            }
            else
                errorFlag = true;
        }
        if(RadioSelection == 'ProductGroup')
        {
            if(string.IsBlank(productsSelected) && string.IsBlank(Brand))
            {
                productSKUFlag = false;
                productGroupFlag = true;
                brandFlag = false;
                NoneFlag = false;
            }
            else
                errorFlag = true;
        }

        if(RadioSelection == 'None')
        {
            if(string.IsBlank(productsSelected) && string.IsBlank(Brand) && string.IsBlank(ProductGroup ))
            {
                productSKUFlag = false;
                productGroupFlag = false;
                brandFlag = false;
                NoneFlag = true;
            }
            else
                errorFlag = true;
        }
        if(RadioSelection == 'Brand')
        {
            system.debug('productsSelected-->' + string.IsBlank(productsSelected));
            system.debug('ProductGroup -->' + string.IsBlank(ProductGroup ) );
            system.debug('productsSelected1-->' + productsSelected);
            system.debug('ProductGroup1 -->' + ProductGroup  );
            if(string.IsBlank(productsSelected) && string.IsBlank(ProductGroup ))
            {
                productSKUFlag = false;
                productGroupFlag = false;
                brandFlag = true;
                NoneFlag = false;
            }
            else
                errorFlag = true;
        }
        if(errorFlag == true)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_SKU_Group_Brand_Message));
    }
    /**
     * @Desc : method to SaveandNew
     */
    public void SaveandNew()
    {
        try
        {
            PageReference pref;
            integer flag = SaveLocalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert localInitiative;
                if(SaveUnAllocatedBanner() == 0)
                {
                    localInitiative = new Local_Initiative__c();
                    ClearSelection();
                }
                else if(SaveUnAllocatedBanner() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Sub_Banner_Allocation_Message));
                }
                /*
                pref=new PageReference('/apex/NationalStrategyItem?ClientId='+ ClientId);
                pref.setRedirect(false);
                return pref;
                */
            }
            else if(HasaTarget() == 1)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));

            }
            else if(HasaTarget() == 2)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_No_Message));

            }
            else if(flag == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));

            }
            else if(flag == 2)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_Selection_Message));

            }
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            //return null;
        }
    }
    /**
     * @Desc : method to SaveUnAllocatedBanner
     */
    private integer SaveUnAllocatedBanner()
    {
        try
        {
            integer i =0;
            if(objCcRel.Customer__r.RecordType.Name == 'Customer - Banner - L4' && objCcRel.Status__c == 'Active')
            {
                Local_Banner_Allocation__c objLocalbnrAll;
                List<Local_Banner_Allocation__c> listLocalbnrAll = new List<Local_Banner_Allocation__c>([Select Id, Allocated_Target__c , Local_Banner_Allocation_Name__c, Proposed_Target__c , System_Account_Name__c, System_Account_Id__c,Status__c From Local_Banner_Allocation__c Where Local_Initiative__c =:localInitiative.Id and System_Account_Id__c =:objCcRel.Customer__c]);
                if(listLocalbnrAll !=null && listLocalbnrAll.size()>0)
                {
                    for(Local_Banner_Allocation__c lba : listLocalbnrAll)
                    {
                        objLocalbnrAll = new Local_Banner_Allocation__c(Id = lba.Id);
                        objLocalbnrAll.Proposed_Target__c = localInitiative.Target__c;
                        objLocalbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                        objLocalbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                        objLocalbnrAll.Local_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    }
                    update objLocalbnrAll;
                }
                else
                {
                    objLocalbnrAll = new Local_Banner_Allocation__c();
                    objLocalbnrAll.Proposed_Target__c = localInitiative.Target__c;
                    objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                    objLocalbnrAll.Client_Customer_Relationship__c = objCcRel.Id;
                    objLocalbnrAll.Status__c = 'Unallocated';
                    objLocalbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                    objLocalbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                    objLocalbnrAll.Local_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    insert objLocalbnrAll;
                }
                i= 0;

            }
            else if(objCcRel.Customer__r.RecordType.Name == 'Customer - Sub Banner - L5' && objCcRel.Status__c == 'Active')
            {
                system.debug('CCRelId-->' + CCRelId);
                i = SaveUnAllocatedBannerwithoutsharing(objCcRel,localInitiative);

            }
            return i;

        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return 1;
        }
    }
    /**
     * @Desc : method to SaveAllocatedBanner
     */
    private integer SaveAllocatedBanner()
    {
        try
        {
            integer i =0;
            if(objCcRel.Customer__r.RecordType.Name == 'Customer - Banner - L4' && objCcRel.Status__c == 'Active')
            {
                Local_Banner_Allocation__c objLocalbnrAll;
                List<Local_Banner_Allocation__c> listLocalbnrAll = new List<Local_Banner_Allocation__c>([Select Id, Allocated_Target__c , Proposed_Target__c ,Local_Banner_Allocation_Name__c, System_Account_Name__c, System_Account_Id__c,Status__c From Local_Banner_Allocation__c Where Local_Initiative__c =:localInitiative.Id and System_Account_Id__c =:objCcRel.Customer__c]);
                if(listLocalbnrAll !=null && listLocalbnrAll.size()>0)
                {
                    for(Local_Banner_Allocation__c lba : listLocalbnrAll)
                    {
                        objLocalbnrAll = new Local_Banner_Allocation__c(Id = lba.Id);
                        objLocalbnrAll.Allocated_Target__c = localInitiative.Target__c;
                        objLocalbnrAll.Status__c = 'Allocated';
                        objLocalbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                        objLocalbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                        objLocalbnrAll.Local_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    }
                    update objLocalbnrAll;
                }
                else
                {
                    objLocalbnrAll = new Local_Banner_Allocation__c();
                    objLocalbnrAll.Allocated_Target__c = localInitiative.Target__c;
                    objLocalbnrAll.Client_Customer_Relationship__c = objCcRel.Id;
                    objLocalbnrAll.Local_Initiative__c = localInitiative.Id;
                    objLocalbnrAll.Status__c = 'Allocated';
                    objLocalbnrAll.System_Account_Name__c = objCcRel.Customer__r.Name;
                    objLocalbnrAll.System_Account_Id__c = objCcRel.Customer__c;
                    objLocalbnrAll.Local_Banner_Allocation_Name__c = objCcRel.Customer__r.Name;
                    insert objLocalbnrAll;
                }
                i = 0;
            }
            else if(objCcRel.Customer__r.RecordType.Name == 'Customer - Sub Banner - L5' && objCcRel.Status__c =='Active')
            {
                i = SaveAllocatedBannerwithoutsharing(objCcRel,localInitiative);

            }
            return i;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return 1;
        }
    }
    /**
     * @Desc : method to HasaTarget
     */
    private integer HasaTarget()
    {
        system.debug('localInitiative.Target__c--->' + localInitiative);
        system.debug('localInitiative.Target__c--->' + localInitiative.Target__c);
        if(hasTarget == 'Yes' && (localInitiative.Target__c ==null || localInitiative.Unit_of_Measure__c == null || localInitiative.Target__c =='' || localInitiative.Unit_of_Measure__c == ''))
        {
             return 1;
        }
        else if(hastarget  == 'No' && (localInitiative.Target__c !=null || localInitiative.Unit_of_Measure__c != null) && (localInitiative.Target__c !='' || localInitiative.Unit_of_Measure__c != ''))
        {
            system.debug('Test2-->');
            return 2;
        }
        else
            return 0;
    }
    /**
     * @Desc : method to SaveandAllocateBanner
     */
    public void SaveandAllocateBanner()
    {
        try
        {
            PageReference pref;
            integer flag = SaveLocalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert localInitiative;
                if(SaveAllocatedBanner() == 0)
                {
                    localInitiative = new Local_Initiative__c();
                    ClearSelection();
                }
                else if(SaveAllocatedBanner() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Sub_Banner_Allocation_Message));
                }
                /*
                pref=new PageReference('/apex/NationalStrategyItem?ClientId='+ ClientId);
                pref.setRedirect(false);
                return pref;
                */
            }
            else if(HasaTarget() == 1)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));

            }
            else if(HasaTarget() == 2)
            {
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_No_Message));

            }
            else if(flag == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));

            }
            else if(flag == 2)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_Selection_Message));

            }
            //return null;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            //return null;
        }
    }
    /**
     * @Desc : method to SaveandAllocateBannerandExit
     */
    public PageReference SaveandAllocateBannerandExit()
    {
        try
        {
            PageReference pref;
            integer flag = SaveLocalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert localInitiative;
                if(SaveAllocatedBanner() == 0)
                {
                    pref=new PageReference('/'+ localInitiative.Local_Strategy__c);
                    pref.setRedirect(false);
                    return pref;
                }
                else if(SaveAllocatedBanner() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Sub_Banner_Allocation_Message));
                }
                /*
                pref=new PageReference('/apex/NationalStrategyItem?ClientId='+ ClientId);
                pref.setRedirect(false);
                return pref;
                */
            }
            else if(HasaTarget() == 1)
            {
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));

            }
            else if(HasaTarget() == 2)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_No_Message));

            }
            else if(flag == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));

            }
            else if(flag == 2)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_Selection_Message));

            }
            return null;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    /**
     * @Desc : method to Exit
     */
    public PageReference Exit()
    {
        PageReference pref = new PageReference('/'+ CCRelId);
        return pref;
    }
    /**
     * @Desc : method to ExitHeader
     */
    public PageReference ExitHeader()
    {
        PageReference pref = new PageReference('/'+ CCRelId);
        return pref;
    }
    /**
     * @Desc : method to SaveandAllocateSubBanner
     */
    public PageReference SaveandAllocateSubBanner()
    {
        try
        {
            PageReference pref;
            Integer flag = SaveLocalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert localInitiative;
                pref=new PageReference('/apex/LocalStrategyAllocation?initiativeId='+localInitiative.Id);
                pref.setRedirect(true);
                return pref;
            }
            else if(HasaTarget() == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));

            }
            else if(HasaTarget() == 2)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_No_Message));

            }
            else if(flag == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));

            }
            else if(flag == 2)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_Selection_Message));

            }
            return null;

        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    /**
     * @Desc : method to SaveandExitInitiative
     */
    public PageReference SaveandExitInitiative()
    {
        try
        {
            PageReference pref;
            Integer flag = SaveLocalInitiative();
            if(HasaTarget() == 0 && flag == 0 )
            {
                upsert localInitiative;
                if(SaveUnAllocatedBanner() == 0)
                {
                    pref=new PageReference('/'+ localInitiative.Local_Strategy__c);
                    pref.setRedirect(false);
                    return pref;
                }
                else if(SaveUnAllocatedBanner() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Sub_Banner_Allocation_Message));
                }
            }
            else if(HasaTarget() == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));
            }
            else if(HasaTarget() == 2)
            {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_No_Message));

            }
            else if(flag == 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));

            }
            else if(flag == 2)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Product_Selection_Message));

            }
            return null;

        }
        catch(Exception ex){
              ApexPages.addMessages(ex);
              return null;
        }
    }
    /**
     * @Desc : method to SaveLocalInitiative
     */
    private integer SaveLocalInitiative()
    {
        if(string.isBlank(localInitiative.Local_Strategy__c))
            localInitiative.Local_Strategy__c = localStrategy.Id;
        ProductSelectionType();
        if(bonusChecked == 'Yes')
            localInitiative.Bonus_Eligibility__c = true;
        else
            localInitiative.Bonus_Eligibility__c = false;
        if(hasTarget == 'Yes')
            localInitiative.Has_a_Target__c = true;
        else
            localInitiative.Has_a_Target__c = false;
        integer flagMandatory = 0;
        if(Brand != null && Brand.length() >0)
        {
            localInitiative.brand__c = Brand;
        }
        if(ProductGroup!= null && ProductGroup.length() >0)
        {
            localInitiative.Product_Group__c = ProductGroup;
        }
        if(productsSelected!= null && productsSelected.length() >0)
        {
            localInitiative.Product_SKU__c = productsSelected;
        }
        if(UPCSelected!= null && UPCSelected.length() >0)
        {
            localInitiative.UPC__c = UPCSelected;
        }
        if(string.isBlank(localInitiative.Initiatives__c) || string.isBlank(localInitiative.Objectives__c) || string.isBlank(localInitiative.Priority__c)
            || string.isBlank(bonusChecked) || localInitiative.Initiative_Start_Date__c == null || localInitiative.Initiative_End_Date__c == null)
        {
            flagMandatory = 1;
        }
        if(RadioSelection == 'ProductSKU' || RadioSelection == 'ProductGroup' || RadioSelection == 'Brand')
        {
            if(RadioSelection == 'ProductSKU' && string.isblank(localInitiative.Product_SKU__c))
            {
                flagMandatory = 2;
            }
            if(RadioSelection == 'ProductGroup' && string.isblank(localInitiative.Product_Group__c))
            {
                flagMandatory = 2;
            }
            if(RadioSelection == 'Brand' && string.isblank(localInitiative.brand__c))
            {
                flagMandatory = 2;
            }
        }
        return flagMandatory ;
    }
    /**
     * @Desc : method to SaveLocalStrategy
     */
    public PageReference SaveLocalStrategy()
    {
        try
        {
            PageReference pref;
            if(String.isNotBlank(localStrategy.Name))
            {

                if(SelectNS() == 0 && SaveLS() == 0)
                {
                    localStrategy.National_Strategy__c = NSValue ;
                    upsert localStrategy;
                    pref = new PageReference('/'+ CCRelId);
                    pref.setRedirect(false);
                    return pref;
                    //localStrategystartdate =null;
                    //localStrategyenddate = null;
                    //localStrategy = new Local_Strategy__c();

                }
                else if(SelectNS() == 1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.National_Strategy_Value_Message));
                }
                else if(SelectNS() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Local_Strategy_Message));
                }
                else if(SaveLS() == 1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));
                }

            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Strategy_Name_Message));

            }
            return null;

        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    /**
     * @Desc : method to SelectNS
     */
    Private integer SelectNS()
    {
        if(listNS !=null && listNS.size()>0)
        {
            if(string.IsBlank(NSValue))
            {
                return 1;
            }
            else
                return 0;
        }
        else
        {
            return 2;
        }
    }
    /**
     * @Desc : method to SaveAndCreateStrategyItem
     */
    public PageReference SaveAndCreateStrategyItem()
    {
        try
        {
            PageReference pref;
            if(String.isNotBlank(localStrategy.Name))
            {
                if(SelectNS() == 0 && SaveLS() == 0)
                {
                    localStrategy.National_Strategy__c = NSValue ;
                    upsert localStrategy;
                    pref = new PageReference('/apex/LocalStrategyItem?ClientId='+ ClientId );
                    pref.setRedirect(false);
                }
                else if(SelectNS() == 1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.National_Strategy_Value_Message));
                }
                else if(SelectNS() == 2)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Local_Strategy_Message));
                }
                else if(SaveLS() == 1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));
                }
            }
            else
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Strategy_Name_Message));
               pref = null;
            }
            return pref ;
        }

        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    /**
     * @Desc : method to SaveLS
     */
    private integer SaveLS()
    {
        if(string.IsBlank(localStrategy.ID))
            localStrategy.Client_Customer_Relationship__c = CCRelId;
        integer i =0;
        if(String.isBlank(localStrategy.name) || String.isBlank(localStrategy.Year__c) || localStrategy.Strategy_Period_Start__c == null || localStrategy.Strategy_Period_End__c == null || String.isBlank(localStrategy.Status__c))
        {
            i = 1;
        }
        return i;

    }
    /**
     * @Desc : method to ProductSelectionType
     */
    private Void ProductSelectionType()
    {
        if(ListBrandBrand !=null && ListBrandBrand.size()>0)
        {
            Brand ='';
            for(BrandWrapper bw : ListBrandBrand)
            {
                if(bw.checked)
                {
                    Brand += bw.bran + ',' ;
                }
            }
            if(Brand != null && Brand.length() >0)
                Brand = Brand.substring(0,Brand.length() -1);
        }
        if(ListPGProductGroup !=null && ListPGProductGroup.size()>0)
        {
            ProductGroup ='';
            for(ProductGroupWrapper pgw : ListPGProductGroup )
            {
                if(pgw.checked)
                {
                    ProductGroup += pgw.prod + ',' ;
                }
            }
            if(ProductGroup!= null && ProductGroup.length() >0)
                ProductGroup = ProductGroup.substring(0,ProductGroup.length() -1);
        }
        system.debug('ProductGroup--->' + ProductGroup);
    }

}