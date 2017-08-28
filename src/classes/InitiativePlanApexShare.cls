/**************************************************************************************
Apex Class Name:  InitiativePlanApexShare
Version     : 1.0 
Created Date    : 25 Aug 2016
Description    : Without sharing class to grant apex sharing to initiative plan records.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar        25 Aug 2016             Original Version
*************************************************************************************/ 
public without Sharing Class InitiativePlanApexShare{

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method to grant apex sharing for the master Initiative Plan records.
     */  
    public static void grantApexSharing(Set<Id> setSelectedClients, Set<Id> setSelectedCustomers, Customer_Visit__c custVisit, Set<Id> setSelectedUsers){
        List<Customer_Visit__Share> listCustVisitShare = new List<Customer_Visit__Share>();
        for(AccountTeamMember otherATM : [Select UserId from AccountTeamMember where AccountId in : setSelectedClients OR AccountId in : setSelectedCustomers]){
            Customer_Visit__Share cvShare = new Customer_Visit__Share();
            cvShare.ParentID = custVisit.Id;
            cvShare.UserOrGroupId = otherATM.UserId;
            cvShare.AccessLevel = AcostaConstants.readAccess;
            cvShare.rowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;
            listCustVisitShare.add(cvShare);
        }
        for(Id usrId : setSelectedUsers){
            Customer_Visit__Share cvShare = new Customer_Visit__Share();
            cvShare.ParentID = custVisit.Id;
            cvShare.UserOrGroupId = usrId;
            cvShare.AccessLevel = AcostaConstants.readWriteAccessAPI;
            cvShare.rowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;
            listCustVisitShare.add(cvShare);
        }
        insert listCustVisitShare;
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method to update the apex sharing for the master Initiative Plan records.
     */      
    public static void updateApexSharing(Set<Id> setRemovedExistingUser, Customer_Visit__c custVisit){
        List<Customer_Visit__Share> listCustVisitShareUpdate = [Select AccessLevel from Customer_Visit__Share where UserOrGroupId in : setRemovedExistingUser AND ParentID =: custVisit.Id];
        for(Customer_Visit__Share cvShare : listCustVisitShareUpdate){
            cvShare.AccessLevel = AcostaConstants.readAccess;    
        }
        if(listCustVisitShareUpdate.size() > 0){
            Update listCustVisitShareUpdate;
        }    
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method to grant apex sharing for the refine records.
     */      
    public static void grantApexSharingRefine(Id masterPlanId, Customer_Visit__c custVisit){
        List<Customer_Visit__Share> listCustVisitShare = new List<Customer_Visit__Share>();
        for(Customer_Visit__Share cvShareMaster : [Select UserOrGroupId,AccessLevel,rowCause,ParentID from Customer_Visit__Share where ParentID =: masterPlanId]){
            Customer_Visit__Share cvShare = new Customer_Visit__Share();
            cvShare.ParentID = custVisit.Id;
            cvShare.UserOrGroupId = cvShareMaster.UserOrGroupId;
            cvShare.AccessLevel = cvShareMaster.AccessLevel.equalsIgnoreCase(AcostaConstants.allAccess) ? AcostaConstants.readWriteAccessAPI : cvShareMaster.AccessLevel;
            cvShare.rowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;
            listCustVisitShare.add(cvShare);
        }
        insert listCustVisitShare;  
    }


    public static void onlyAddSelectedUsersToIepShare(Customer_Visit__c iep, Set<Id> selectedUserIds) {

        List<Customer_Visit__Share> sharesToInsert = new List<Customer_Visit__Share>();

        for(Id userId : selectedUserIDs) {
            Customer_Visit__Share shareToInsert = new Customer_Visit__Share();
            shareToInsert.ParentID = iep.Id;
            shareToInsert.UserOrGroupId = userId;
            shareToInsert.AccessLevel = AcostaConstants.readWriteAccessAPI;
            shareToInsert.rowCause = Schema.Customer_Visit__Share.RowCause.AccountTeamMember__c;   
            sharesToInsert.add(shareToInsert);
        }

        Database.insert(sharesToInsert);

    }
}