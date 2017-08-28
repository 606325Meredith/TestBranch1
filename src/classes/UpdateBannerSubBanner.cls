/**
  *  Description     :   This class is to update the banners and Sub banner fields, fetching the values from the related 
  * 						Dispostion details records 
  *  Created By      :   Abhishek Tripathi 
  *  Created Date    :   9/6/2016   
  *  Version         :   V1.0     
 **/
public class UpdateBannerSubBanner {

    //Method for updating the Banner and Sub Banners
    public void populateBannerSubBanner(List<Customer_Visit_Execution_Detail__c> listOfBSBabbers) {
        
        //List of banners and sub banners
        List<Local_Banner_Allocation__c> localBanners = new List<Local_Banner_Allocation__c>();
        List<Local_Sub_Banner_Allocation__c> localSubBanners = new List<Local_Sub_Banner_Allocation__c>();
        List<National_Banner_Allocation__c> nationalBanners = new List<National_Banner_Allocation__c>();
        List<National_Sub_Banner_Allocation__c> nationalSubBanners = new List<National_Sub_Banner_Allocation__c>();
        
        Set<Id> nationalInitiatives = new Set<Id>();
        Set<Id> localInitiatives = new Set<Id>();
        
        for(Customer_Visit_Execution_Detail__c cved : listOfBSBabbers) {
            
            if(cved.Local_Banner_Allocation__c != null) {
                Local_Banner_Allocation__c lb = new Local_Banner_Allocation__c();
                lb.Id = cved.Local_Banner_Allocation__c;
                lb = (Local_Banner_Allocation__c)createData(cved, lb);
        		localBanners.add(lb);
                
            } else if(cved.Local_Sub_Banner_Allocation__c != null) {
                Local_Sub_Banner_Allocation__c lb = new Local_Sub_Banner_Allocation__c();
                lb.Id = cved.Local_Sub_Banner_Allocation__c;
                lb = (Local_Sub_Banner_Allocation__c)createData(cved, lb);
        		localSubBanners.add(lb);
                
            } else if(cved.National_Banner_Allocation__c != null) {
                National_Banner_Allocation__c lb = new National_Banner_Allocation__c();
                lb.Id = cved.National_Banner_Allocation__c;
                lb = (National_Banner_Allocation__c)createData(cved, lb);
        		nationalBanners.add(lb);
                
            } else if(cved.National_Sub_Banner_Allocation__c != null) {
                National_Sub_Banner_Allocation__c lb = new National_Sub_Banner_Allocation__c();
                lb.Id = cved.National_Sub_Banner_Allocation__c;
                lb = (National_Sub_Banner_Allocation__c)createData(cved, lb);
        		nationalSubBanners.add(lb);
            }
        }
        
        //Check for the list and update
        if(!nationalSubBanners.isEmpty())
            update nationalSubBanners;
        
        if(!nationalBanners.isEmpty())
            update nationalBanners;
        
        if(!localSubBanners.isEmpty())
            update localSubBanners;
        
        if(!localBanners.isEmpty())
            update localBanners;
        
    }
    
    private SObject createData( Customer_Visit_Execution_Detail__c cved , SObject lb) {
        lb.put('ID_Customer_Code__c',cved.Customer_Code__c);
        lb.put('ID_Customer_Code__c', cved.Customer_Code__c);
        lb.put('ID_Follow_up_Date__c', cved.Follow_Up_Date__c);
        lb.put('ID_Pending_Reason__c', cved.Pending_Reason__c);
        lb.put('ID_Pipeline__c', cved.Forecast__c);
        lb.put('ID_Pipeline_UOM__c', cved.Pipeline_UOM__c);
        lb.put('ID_Rejected_Reason__c', cved.Rejected_Reason__c);
        lb.put('ID_Retail_Availability_Date__c', cved.Retail_Availability_Date__c);
        lb.put('ID_Shipment_Date__c', cved.Shipment_Date__c);
        lb.put('ID_Status__c', cved.Status__c);
        return lb;
    }
}