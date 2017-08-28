public with sharing class NationalSubBannerRelatedListController {


    public String recordID2 { get; set; }
    public List<National_Sub_Banner_Allocation__c> nationalSubBanner { get; set; }
    public List<National_Sub_Banner_Allocation__c> natSubBanner { get; set; }
    String currentID = ApexPages.currentPage().getParameters().get('id');
    public boolean Delflag{get;set;}

    public NationalSubBannerRelatedListController(ApexPages.StandardController controller) {
        String currentID = ApexPages.currentPage().getParameters().get('id');
        Delflag  = false;
        nationalSubBannerList();
    }

    public void nationalSubBannerList() {
          nationalSubBanner = [SELECT ID,Name,Status__c,Allocated_Target__c,Proposed_Target__c,Unit_Of_Measure__c,Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c,CreatedBy.name FROM National_Sub_Banner_Allocation__c WHERE Status__c = 'Allocated' AND Client_Customer_Relationship__r.Id =:currentID ];

    }


    public void deleteNationalSubBannerAllocation() {
         String nationalSubBannerId2 = System.currentPageReference().getParameters().get('recordID2');
             try {
                     natSubBanner  = [SELECT Id FROM National_Sub_Banner_Allocation__c WHERE ID =: nationalSubBannerId2];
                     if(natSubBanner.size()  > 0){
                       delete natSubBanner;
                     }
                 }
                 catch(DmlException e) {
                                            System.debug('The following exception has occurred: ' + e.getMessage());
                                       }
            nationalSubBannerList();

    }

         public boolean getCheckpermissions()
    {
        integer i = 0;
        Delflag  = false;
        List<AggregateResult> listRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Deletion_Permission_for_National_Initiatives_and_National_Allocations']);
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