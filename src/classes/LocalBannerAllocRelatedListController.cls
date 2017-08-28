public with sharing class LocalBannerAllocRelatedListController {

    public String recordID2 { get; set; }
    public List<Local_Banner_Allocation__c> localBanner { get; set; }
    public List<Local_Banner_Allocation__c> locBanner { get; set; }
    public List<Local_Sub_Banner_Allocation__c> locSubBanr{get;set;}
    String currentID = ApexPages.currentPage().getParameters().get('id');
    public boolean Delflag{get;set;}

   public LocalBannerAllocRelatedListController(ApexPages.StandardController controller) {
        String currentID = ApexPages.currentPage().getParameters().get('id');
        System.Debug('CurentIDCheck'+currentID);
        Delflag  = false;
        localBannerList();
    }

    public void localBannerList() {
                localBanner = [SELECT ID,Name,Status__c,Allocated_Target__c,Unit_Of_Measure__c,Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c FROM Local_Banner_Allocation__c WHERE Status__c = 'Allocated' AND Client_Customer_Relationship__r.Id =:currentID ]; 
    }

    public void deletelocalBannerAllocation() {
         String localBannerId2 = System.currentPageReference().getParameters().get('recordID2');
             
                     locBanner  = [SELECT Id FROM Local_Banner_Allocation__c WHERE ID =: localBannerId2];
                     locSubBanr = [SELECT Id,Local_Banner_Allocation__c FROM Local_Sub_Banner_Allocation__c WHERE Local_Banner_Allocation__r.Id IN : locBanner];
                     if(locSubBanr.size()  > 0){
                          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are Sub-Banners Allocated to this Banner, you cannot delete Banner.'));
                       
                     }
                  else if(locSubBanr.size()  == 0){
                      delete locBanner;
                      localBannerList();
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