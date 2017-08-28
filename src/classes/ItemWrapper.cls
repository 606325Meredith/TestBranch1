/**
 *  Description     :   Creaetion and update of Disposition object based on Banner and Sub Banner, this is the controller of the InitiativeDisposition page
 *                      this page will be run from a button of the 
 *
 *  Created By      :   Abhishek Tripathi 
 *  Created Date    :   8/23/2016   
 *  Version         :   V1.0     
 **/
public class ItemWrapper {
    Public String product { get; set; }
    Public String initiative { get; set; }
    Public String objective { get; set; }
    Public String initId { get; set; }
    public String initiativeType { get; set; }
    public String productGroup { get; set; }
    public String brand { get; set; }
    public Customer_Visit_Execution_Detail__c pendingFollowup { get; set; }
    public Customer_Visit_Execution_Detail__c notProposedFollowup { get; set; }
    
    public String acceptComment { get; set; }
    public String rejectComment { get; set; }
    public String pendingCommnent { get; set; }
    public String notProComment { get; set; }
    
    public Customer_Visit_Execution_Detail__c cved { get; set; }
    
    public itemWrapper(String pro, String init, String objec, String inId, String str, Customer_Visit_Execution_Detail__c pFollow, Customer_Visit_Execution_Detail__c npFollow, String productGroups, String brands, String acceptComment, String rejectComment, String pendingCommnent, String notProComment, Customer_Visit_Execution_Detail__c idd) {
        //cved = new Customer_Visit_Execution_Detail__c();
        pendingFollowup = new Customer_Visit_Execution_Detail__c();
        notProposedFollowup = new Customer_Visit_Execution_Detail__c();
        //pendingFollowup.Follow_Up_Date__c = null;
        //notProposedFollowup.Follow_Up_Date__c = null;
        
        product = pro;
        initiative = init;
        objective = objec;
        initId = inId;
        initiativeType = str;
        productGroup = productGroups;
        brand = brands;
        this.pendingFollowup = pFollow;
        this.notProposedFollowup = npFollow;
        
        cved = idd;
        this.acceptComment = acceptComment; 
        this.rejectComment = rejectComment;
        this.pendingCommnent = pendingCommnent;
        this.notProComment = notProComment;
    }
}