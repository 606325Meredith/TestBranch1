public with sharing class LocalInitiativeReltdListContrlr {

 public String recordID { get; set; }
    public String recordID1 { get; set; }
    public String recordID2 { get; set; }
    public boolean AllowShowMore {get;set;}
    public List<Local_Initiative__c> Initiative { get; set; }
    public List<Local_Initiative__c> Initia { get; set; }
    public List<Local_Banner_Allocation__c> listLocalBanner {get;set;}
    String currentID = ApexPages.currentPage().getParameters().get('id');
    public boolean Delflag{get;set;}
       
    public LocalInitiativeReltdListContrlr(ApexPages.StandardController controller) {
        String currentID = ApexPages.currentPage().getParameters().get('id');
        Delflag = false;
        AllowShowMore = true;
        initiativeList();
    }

    public void initiativeList() {
          Initiative = [SELECT Active__c,Bonus_Eligibility__c,Brand__c,Id,Initiatives__c,Initiative_End_Date__c,Initiative_Start_Date__c,
                        Name,Objectives__c,Priority__c,Local_Strategy__c,Unit_of_Measure__c,Target__c,Comments__c,Product_Group__c,Product_SKU__c,
                        (SELECT Id From Local_Banner_Allocations__r)
                        FROM Local_Initiative__c WHERE Local_Strategy__r.Id =:currentID];
    }
    
    public PageReference allocate() {
          String InitiativeId = System.currentPageReference().getParameters().get('recordID');
          PageReference pfRef = new PageReference('/apex/LocalErrorPage?id='+InitiativeId);
          pfRef.setRedirect(false);
          return pfRef ;
    }


    public PageReference viewDetails() {
          String InitiativeId1 = ApexPages.currentPage().getParameters().get('recordID1');
          PageReference pfRef = new PageReference('/'+InitiativeId1);
          return pfRef ;
      }

    public PageReference newInitiative() {
         String strategyID = ApexPages.currentPage().getParameters().get('id');
         PageReference pfRef = new PageReference('/apex/LocalErrorPage?strategyID='+strategyID);
         return pfRef ;
    }
    
    public void deleteInitiatives() {
         String InitiativeId2 = System.currentPageReference().getParameters().get('recordID2');
             
                     Initia  = [SELECT Id FROM Local_Initiative__c WHERE ID =: InitiativeId2];
                     listLocalBanner  = [SELECT ID,Local_Initiative__c FROM Local_Banner_Allocation__c WHERE Local_Initiative__r.Id IN : Initia];
                     
                     if(listLocalBanner.size()  > 0){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are Banners Allocated to this Initiatives, you cannot delete Initiative.'));
                     }
                     else if(listLocalBanner.size()  == 0){
                     delete Initia;
                     initiativeList(); 
                     }

    }
    
       public boolean getCheckpermissions()
    {
        integer i = 0;
        Delflag  = false;
        List<AggregateResult> listRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Deletion_Permission_for_Local_Initiatives_and_Local_Allocations']);
        if(listRes!= null && listRes.size()>0)
        {
            i =(Integer) listRes[0].get('counts');
            system.debug('i--->' + i);
            if(i > 0)
            {  
                Delflag = true;
            } 
            else if(i == 0)
            {
                Delflag = false;              
            }        
        }
        return Delflag ;
        
        
    }

  
}