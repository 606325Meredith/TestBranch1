public with sharing class NationalBannerRelatedListController {

    public String recordID2 { get; set; }
    public List<National_Banner_Allocation__c> Nationalbanner { get; set; }
    public List<National_Banner_Allocation__c> natBanner { get; set; }
    public List<National_Sub_Banner_Allocation__c> natSubBanr {get;set;}
    String currentID = ApexPages.currentPage().getParameters().get('id');
    public boolean Delflag {get;set;}
    public boolean authflag {get;set;}

    public NationalBannerRelatedListController(ApexPages.StandardController controller) {

        String currentID = ApexPages.currentPage().getParameters().get('id');
        Delflag = false;
        authflag = false;
        nationalBannerList();
    }

    public void nationalBannerList() {
        Nationalbanner= [SELECT ID,Name,National_Initiative_Lookup__c,Status__c,Allocated_non_Editable__c,Proposed_editable__c,Unit_Of_Measure__c,Initiatives__c,Objectives__c,Initiative_Start_Date__c,Initiative_End_Date__c,LastModifiedBy.name FROM National_Banner_Allocation__c WHERE Status__c = 'Allocated' AND Client_Customer_Relationship__r.Id =:currentID];
    }

    public void deleteNationalBannerAllocation() {
        String nationalBannerId2 = System.currentPageReference().getParameters().get('recordID2');

            natBanner  = [SELECT Id FROM National_Banner_Allocation__c WHERE ID =: nationalBannerId2];
            natSubBanr = [SELECT ID,National_Banner_Allocation__c FROM National_Sub_Banner_Allocation__c WHERE National_Banner_Allocation__r.ID IN :natBanner];
            if(natSubBanr.size()  > 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are Sub-Banners Allocated to this Banner, you cannot delete Banner.'));
            }
            else if(natSubBanr.size()  == 0){
                delete natBanner;
                nationalBannerList();
            }
    }

    public boolean getCheckpermissions() {
        integer i = 0;
        Delflag  = false;
        List<AggregateResult> listRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Deletion_Permission_for_National_Initiatives_and_National_Allocations']);
        if(listRes!= null && listRes.size()>0)
        {
            i =(Integer) listRes[0].get('counts');
            system.debug('listRes count --->' + i);
            if(i > 0)
            {
                Delflag = true;
            }
            else if(i == 0)
            {
                Delflag = false;
            }
        }
        return Delflag;
    }

    public boolean getAsoPermissions() {
        integer i = 0;
        authflag  = false;
        List<AggregateResult> asoListMember = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'ASO_NBA_Access']);
        if(asoListMember!= null && asoListMember.size()>0)
        {
            i =(Integer) asoListMember[0].get('counts');
            system.debug('asoListMember count --->' + i);
            if(i > 0)
            {
                authflag = true;
            }
            else if(i == 0)
            {
                authflag = false;
            }
        }
        return authflag;
    }
}