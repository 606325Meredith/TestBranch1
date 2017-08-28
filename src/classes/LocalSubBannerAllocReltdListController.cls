public with sharing class LocalSubBannerAllocReltdListController {

    public String recordID2 { get; set; }
    public List<Local_Sub_Banner_Allocation__c> localSubBanner { get; set; }
    public List<Local_Sub_Banner_Allocation__c> locSubBanner { get; set; }
    String currentID = ApexPages.currentPage().getParameters().get('id');
    public boolean Delflag{get;set;}


     public LocalSubBannerAllocReltdListController(ApexPages.StandardController controller) {
        String currentID = ApexPages.currentPage().getParameters().get('id');
        Delflag  = false;
        localSubBannerList();
    }

    public void localSubBannerList() {
              localSubBanner = [SELECT ID,Name,Status__c,Allocated_Traget__c,Unit_of_Measure__c,Initiatives__c,Objectives__c,Intitiative_Start_Date__c,Initiative_End_Date__c FROM Local_Sub_Banner_Allocation__c WHERE Status__c = 'Allocated' AND Client_Customer_Relationship__r.Id =:currentID ]; 
    }
    
    public void deletelocalSubBannerAllocation() {
         String localSubBannerId2 = System.currentPageReference().getParameters().get('recordID2');
             try {
                     locSubBanner  = [SELECT Id FROM Local_Sub_Banner_Allocation__c WHERE ID =: localSubBannerId2];
                     if(locSubBanner.size()  > 0){
                       delete locSubBanner;
                     }
                 }
                 catch(DmlException e) {
                                            System.debug('The following exception has occurred: ' + e.getMessage());
                                       }      
            localSubBannerList();

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