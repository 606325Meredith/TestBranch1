/**************************************************************************************
Apex Class Name:  NationalStrategyController
Version     : 1.0
Created Date    : 10 Sep 2016
Description    : Controller class for the National Strategy Header and Item page.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rahul Nasa                  10 Sep-2016             Original Version
*************************************************************************************/
public without sharing class NationalStrategyController{
    public List<ProductWrapper> searchResults {get;set;}
    public string NationalInitiativeID{get;set;}
    public Account client{get;set;}
    public Boolean displayPopup {get; set;}
    public String productsSelected {get;set;}
    public string UPCSelected{get;set;}
    public string productGroupsSelected{get;set;}
    public Product__c acc{get;set;}
    public National_Initiative__c nationalInitiative{get;set;}
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
    public National_Strategy__c nationalStrategy{get;set;}
    public string searchCriteriaProd{get;set;}

    public string bonusChecked{get;set;}
    public string hastarget{get;set;}
    public boolean productSKUFlag{get;set;}
    public boolean productGroupFlag{get;set;}
    public boolean NoneFlag{get;set;}
    public boolean brandFlag{get;set;}
    public string RadioSelection{get;set;}
    public boolean editPG{get;set;}
    public boolean editBrand{get;set;}
    public boolean edit{get;set;}
    private set<Id> setChannelL4{get;set;}
    public string nationalstrategystartdate{get;set;}
    public string nationalstrategyenddate{get;set;}
    public integer totalRecs = 0;
    public integer totalbannerRecs =0;
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    public boolean AllProducts {get;set;}
    public boolean SelProducts {get;set;}
    public Integer totalPages{get;set;}
    public List<string> listItemValue{get;set;}
    public List<string> listUnitOfMeasure{get;set;}
    public List<DepartmentWrapper> ListDepartment{get;set;}
    public List<DepartmentWrapper> ListBrandDepartment{get;set;}
    public List<DepartmentWrapper> ListPGDepartment{get;set;}
    public string strategyType{get;set;}
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
    private string nationalStrategyID;
     /**
     * @Desc : public constructor
     */
    public NationalStrategyController(){

         clientID = ApexPages.currentPage().getParameters().get('ClientId');
         system.debug('clientID-->' + clientID );
         nationalStrategyID = ApexPages.currentPage().getParameters().get('strategyID');
         nationalStrategy = new National_Strategy__c();
         RadioSelection = 'None';
         NoneFlag = true;
         strategyType = 'National';
         acc = new Product__c();
         displaySubBanner = false;
         client = new Account();
         displayProductSKU = false;
         displayProductGroup = false;
         NationalInitiativeID = ApexPages.currentPage().getParameters().get('id');
         nationalInitiative = new National_Initiative__c();
         if(String.isNotBlank(NationalInitiativeID))
         {

             nationalInitiative = [Select Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Comments__c,Priority__c,Active__c,Product_SKU__c ,Brand__c ,Product_Group__c ,Bonus_Eligibility__c,Strategy__c,Strategy__r.Client__c,Has_a_Target__c   from National_Initiative__c where id=:NationalInitiativeID ];
             If(String.isBlank(clientID))
             {
                 clientID = nationalInitiative.Strategy__r.Client__c;
             }
             nationalStrategy = new National_Strategy__c(id = nationalInitiative.Strategy__c);
             if(String.isBlank(nationalStrategyID)) nationalStrategyID = nationalStrategy.Id;
             //nationalInitiative = [Select Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c,Target__c,Unit_of_Measure__c,Priority__c,Active__c,Product_SKU__c ,Brand__c ,Product_Group__c ,Bonus_Eligibility__c,Strategy__c   from National_Initiative__c where id=:NationalInitiativeID ];
             if(nationalInitiative.Initiative_Start_Date__c != null)
                 startDate = DateTime.newInstance(nationalInitiative.Initiative_Start_Date__c.year(),nationalInitiative.Initiative_Start_Date__c.month(),nationalInitiative.Initiative_Start_Date__c.day()).format('MM/dd/yyyy');

             If(nationalInitiative.Bonus_Eligibility__c )
                 bonusChecked = 'Yes';
             else
                 bonusChecked = 'No';

             if(nationalInitiative.Initiative_End_Date__c != null)
                 endDate = DateTime.newInstance(nationalInitiative.Initiative_End_Date__c.year(),nationalInitiative.Initiative_End_Date__c.month(),nationalInitiative.Initiative_End_Date__c.day()).format('MM/dd/yyyy');
             if(nationalInitiative.Product_SKU__c != null)
                 productsSelected = nationalInitiative.Product_SKU__c;
             if(nationalInitiative.Brand__c != null)
             {
                 Brand = nationalInitiative.Brand__c ;
             }
             if(nationalInitiative.Product_Group__c != null)
             {
                 ProductGroup = nationalInitiative.Product_Group__c;
             }
         }
         if(string.IsNOTBlank(nationalStrategyID))
         {
            if(string.IsNOTBlank(nationalStrategyID))
                nationalStrategy = [Select Client__c,Id,Name from National_Strategy__c where id =: nationalStrategyID];
            If(String.isBlank(clientID))
            {
                clientID = nationalStrategy.Client__c;
            }
         }

         if(String.isNOTBlank(clientID))
         {
            setChannelL4 = new set<Id>();
            List<Account> listClientL3 = new List<Account>([Select Id,ParentId from Account where ParentId =: clientID]);
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

		If(nationalInitiative.Has_a_Target__c)
			hastarget = 'Yes';
		else
			hastarget = 'No';
        setSelectedPro= new set<Id>();
        selectedProMap =new map<Id,Product__c>();
        listItemValue= new List<string>();
        listUnitOfMeasure = new List<string>();
        listStatus = new List<string>();
        listPriority = new List<string>();
        listCoreFlex = new List<string>();
        this.page = 1;
    }


    public void searchAcc(){
        totalRecs = 0;
        OffsetSize = 0;
        AllProducts = true;

        if(accountList != null && accountList.size() > 0){
			accountList=null;
        }
        holdSelected();
        searchAccounts();
    }
     /**
     * @Desc : method to search for the Products
     */
    public Void searchAccounts(){
        try
        {
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
            ListDepartment = new List<DepartmentWrapper>();
            system.debug('setChannelL4-->' + setChannelL4);
            If(setChannelL4.size() >0)
            {
                 strQuery = 'Select Product_Description__c,Id,Department__c,Category__c,Priority__c,UPC__c,Core_Flex__c,Account__c,Account__r.Name,Unit_of_Measure__c,Brand_Name__c,Product_Group_Name__c From Product__c where Status__c = \'Active\' and Account__c in : setChannelL4';
            }
            else
            {
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
            system.debug('strQuery-->' + strQuery);
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
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }

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
        searchCriteriaProd = null;
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
        try
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
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }
    public void showSelected(){
       totalRecs = 0;
       OffsetSize = 0;
       AllProducts = false;
       holdSelected();
       searchAccounts();


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
         If(depParam.size()>0)
         {
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
         }
         else
         {
             ListCategory = new List<CategoryWrapper>();
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
         if(depParam.size()>0)
         {
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
         }
         else
         {
             listBrandCategory = new List<CategoryWrapper>();
         }
         //return ListCategory;

     }
     public Void doPGDepActionSupport()
     {
         List<Product__c> ProductTemp = new List<Product__c>();
         depParam = new set<string>();
         set<string> setCategory = new set<string>() ;
         for(DepartmentWrapper dw : ListPGDepartment)
         {
             if(dw.checked)
             {
                depParam.add(dw.dep);
             }
         }
         if(depParam.size() > 0)
         {
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
          }
          else
          {
             listPGCategory = new List<CategoryWrapper>();
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
         if(catParam.size() >0 && depParam.size() >0)
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c  !=null and Department__c in: depParam and Category__c in: catParam and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c = : clientID ];
             }
             if( ProductTemp.size()>0)
             {
                 ListProductGroup = new List<ProductGroupWrapper>();
                 ProductGroupWrapper pgw = new ProductGroupWrapper();
                 for(Product__c prod : ProductTemp )
                 {

                    if(!setProductGroup.contains(prod.Product_Group_Name__c ))
                    {
                       pgw = new ProductGroupWrapper();
                       pgw.prod = prod.Product_Group_Name__c ;
                       ListProductGroup.add(pgw);
                    }
                    setProductGroup.add(prod.Product_Group_Name__c );
                 }

             }
         }
         else
         {
             ListProductGroup = new List<ProductGroupWrapper>();
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
         if(catParam.size() >0 && depParam.size() >0)
         {
             If(setChannelL4.size() >0)
             {
                 ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c in : setChannelL4];
             }
             else
             {
                 ProductTemp = [Select Brand_Name__c From Product__c where Brand_Name__c !=null and Department__c in: depParam and Category__c in: catParam and Account__c = : clientID ];
             }
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
         else
         {
             ListBrandBrand = new List<BrandWrapper>();
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
         if(catParam.size() >0 && depParam.size() >0)
         {
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
         else
         {
             ListPGProductGroup = new List<ProductGroupWrapper>();
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
         if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0 ||  (brandParam !=null && brandParam.size() > 0))
         {
             if(catParam!=null && depParam !=null &&  brandParam !=null && catParam.size() >0 && depParam.size()>0 && brandParam.size()>0)
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
             else if(brandParam !=null && brandParam.size()>0 && (catParam ==null || catParam.size() == 0))
             {
                 If(setChannelL4.size() >0)
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
                 }
                 else
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Brand_Name__c in : brandParam  and Account__c = : clientID ];
                 }
             }
             else if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0 && (brandParam ==null || brandParam.size()==0))
             {
                 If(setChannelL4.size() >0)
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam  and Account__c in : setChannelL4];
                 }
                 else
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam  and Account__c = : clientID ];
                 }
             }

             if(ProductTemp.size()>0)
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
             else
             {
                 ListPGProductGroup = new List<ProductGroupWrapper>();
             }
         }
         else
         {
             ListProductGroup = new List<ProductGroupWrapper>();
         }
     }

     public Void doBrandBrandActionSupport()
     {
         brandParam = new set<string>();
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
         if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0 ||  (brandParam !=null && brandParam.size() > 0))
         {
             if(catParam!=null && depParam !=null &&  brandParam !=null && catParam.size() >0 && depParam.size()>0 && brandParam.size()>0)
             {
                 system.debug('Test-->'+ setChannelL4);
                 system.debug('Test-->'+ catParam );
                 system.debug('Test-->'+ depParam );
                 system.debug('Test-->'+ brandParam  );
                 If(setChannelL4.size() >0)
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
                 }
                 else
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam and Brand_Name__c in : brandParam  and Account__c = : clientID ];
                 }
                 system.debug('ProductTemp-->' + ProductTemp );
             }
             else if(brandParam !=null && brandParam.size()>0 && (catParam ==null || catParam.size() == 0))
             {
                 If(setChannelL4.size() >0)
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Brand_Name__c in : brandParam  and Account__c in : setChannelL4];
                 }
                 else
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Brand_Name__c in : brandParam  and Account__c = : clientID ];
                 }
             }
             else if(catParam!=null && depParam !=null && catParam.size() >0 && depParam.size()>0 && (brandParam ==null || brandParam.size()==0))
             {
                 If(setChannelL4.size() >0)
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam  and Account__c in : setChannelL4];
                 }
                 else
                 {
                     ProductTemp = [Select Product_Group_Name__c From Product__c where Product_Group_Name__c !=null and Category__c in: catParam and Department__c in: depParam  and Account__c = : clientID ];
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
             else
             {
                 ListPGProductGroup = new List<ProductGroupWrapper>();
             }
         }
         else
         {
             ListPGProductGroup = new List<ProductGroupWrapper>();
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
        if (uomParam.isEmpty()) uomParam.add('No Values Selected');
    }

    /**
     * @Desc : method to hold selected
     */
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

    public Integer gettotalRecs(){
        return totalRecs;
    }
    public Integer gettotalBannerRecs(){
        return totalbannerRecs ;
    }

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
     * @Desc : method to Show Pop Up
     */
    public void showPopup() {
        displayPopup = true;
        totalRecs = 0;
        OffsetSize = 0;
        totalPages=0;
        this.page=1;
        searchAccounts() ;
    }
    /**
     * @Desc : method to Clear Selection
     */
    public void ClearSelection()
    {
        nationalInitiative.Brand__c='';
        nationalInitiative.Product_Group__c ='';
        nationalInitiative.Product_SKU__c ='';
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
        setSelectedPro = new set<Id>();
        selectedProMap = new map<Id,Product__c>();
        clearFilters();
        /*for(ProductWrapper cw :searchResults){

            cw.checked = false;

        } */

    }
    /**
     * @Desc : method to Change radio
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
     * @Desc : method to Save and New
     */
    public void SaveandNew()
    {
        try
        {
            PageReference pref;
            integer flag = SaveNationalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert nationalInitiative;
                nationalInitiative = new National_Initiative__c();
                ClearSelection();
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
     * @Desc : method to Save and Allocate
     */
    public PageReference SaveandAllocate()
    {
        try
        {
            PageReference pref;
            integer flag = SaveNationalInitiative();
            if(HasaTarget() == 0 && flag == 0)
            {
                upsert nationalInitiative;
                    pref=new PageReference('/apex/BannerUI1?initiativeId='+nationalInitiative.Id);
                pref.setRedirect(true);
                return pref;
            }
            else if(HasaTarget() == 1)
            {
                 system.debug('Test-->');
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Has_a_Target_Yes_Message));

            }
            else if(HasaTarget() == 2)
            {
                system.debug('Test1-->');
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
     * @Desc : method to Save and Exit Initiative
     */
    public PageReference SaveandExitInitiative()
    {
        try
        {
            PageReference pref;
            integer flag = SaveNationalInitiative();
            if(HasaTarget() == 0 && flag ==0 )
            {
                upsert nationalInitiative;
                pref=new PageReference('/'+ nationalInitiative.Strategy__c);
                pref.setRedirect(false);
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
     * @Desc : method to Save National Initiative
     */
    private integer SaveNationalInitiative()
    {
        if(String.isBlank(nationalInitiative.Strategy__c ))
            nationalInitiative.Strategy__c = nationalStrategy.Id;
        ProductSelectionType();
        if(bonusChecked == 'Yes')
            nationalInitiative.Bonus_Eligibility__c = true;
        else
            nationalInitiative.Bonus_Eligibility__c = false;
        if(hastarget == 'Yes')
            nationalInitiative.Has_a_Target__c = true;
        else
            nationalInitiative.Has_a_Target__c = false;

        integer flagMandatory = 0;
        if(Brand != null && Brand.length() >0)
        {
            nationalInitiative.brand__c = Brand;
        }
        if(ProductGroup!= null && ProductGroup.length() >0)
        {
            nationalInitiative.Product_Group__c = ProductGroup;
        }
        if(productsSelected!= null && productsSelected.length() >0)
        {
            nationalInitiative.Product_SKU__c = productsSelected;
        }
        if(UPCSelected!= null && UPCSelected.length() >0)
        {
            nationalInitiative.UPC__c = UPCSelected;
        }
        if(string.isBlank(nationalInitiative.Initiatives__c) || string.isBlank(nationalInitiative.Objectives__c) || string.isBlank(nationalInitiative.Priority__c)
            || string.isBlank(bonusChecked) || nationalInitiative.Initiative_Start_Date__c == null || nationalInitiative.Initiative_End_Date__c == null)
        {
            flagMandatory = 1;
        }
        if(RadioSelection == 'ProductSKU' || RadioSelection == 'ProductGroup' || RadioSelection == 'Brand')
        {
            if(RadioSelection == 'ProductSKU' && string.isblank(nationalInitiative.Product_SKU__c))
            {
                flagMandatory = 2;
            }
            if(RadioSelection == 'ProductGroup' && string.isblank(nationalInitiative.Product_Group__c))
            {
                flagMandatory = 2;
            }
            if(RadioSelection == 'Brand' && string.isblank(nationalInitiative.brand__c))
            {
                flagMandatory = 2;
            }
        }
        return flagMandatory ;
    }
    /**
     * @Desc : method to Exit
     */
    public PageReference Exit()
    {
        PageReference pref = new PageReference('/' + clientId);
        pref.setRedirect(false);
        return pref;
    }
    /**
     * @Desc : method to Exit Header
     */
    public PageReference ExitHeader()
    {
        PageReference pref = new PageReference('/' + clientId);
        pref.setRedirect(false);
        return pref;
    }
    /**
     * @Desc : method to SaveNationalStrategy
     */
    public PageReference SaveNationalStrategy()
    {
        try
        {
            if(SaveNS() ==0)
            {
                upsert nationalStrategy;
                PageReference pref = new PageReference('/' + clientId);
                pref.setRedirect(false);
                return pref;
            }
            else if(SaveNS() ==1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));
            }
            return null;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    /**
     * @Desc : method to SaveAndCreateStrategyItem
     */
    public PageReference SaveAndCreateStrategyItem()
    {
        try
        {
            if(SaveNS() ==0)
            {
                upsert nationalStrategy;
                PageReference pref = new PageReference('/apex/NationalStrategyItem?ClientId='+ ClientId );
                pref.setRedirect(false);
                return pref;
            }
            else if(SaveNS() ==1)
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Fields_Message));
            }
            return null;
        }

        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }

    }
    /**
     * @Desc : method to SaveNS
     */
    private integer SaveNS()
    {
        if(string.IsBlank(nationalStrategy.ID))
            nationalStrategy.Client__c = clientID ;
        integer i =0;
        if(String.isBlank(nationalStrategy.name) || String.isBlank(nationalStrategy.Year__c) || nationalStrategy.Strategy_Period_Start__c == null || nationalStrategy.Strategy_Period_End__c == null || String.isBlank(nationalStrategy.Status__c))
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
    }
    /**
     * @Desc : method to HasaTarget
     */
    private integer HasaTarget()
    {
        if(hastarget  == 'Yes' && (nationalInitiative.Target__c ==null || nationalInitiative.Unit_of_Measure__c == null || nationalInitiative.Target__c =='' || nationalInitiative.Unit_of_Measure__c == ''))
        {
             return 1;
        }

        else if(hastarget  == 'No' && (nationalInitiative.Target__c !=null || nationalInitiative.Unit_of_Measure__c != null) && (nationalInitiative.Target__c !='' || nationalInitiative.Unit_of_Measure__c != ''))
        {
            system.debug('Test2-->');
            return 2;
        }
        else
            return 0;
    }
}