/*****************************************************************************************
Class Name: ClientCustomerRelationshipTriggerHandler
Purpose: Handler class for Client Customer Relationship trigger. Preventing the CCR records from losing Sharing priviledges to other users when CCR record ownership changes.
******************************************************************************************
Version         DateModified         ModifiedBy                           Change
1.0             19/04/2017           Rakesh Ramaswamy(PwC)               Initial Development
1.1             20/04/2017           Rakesh Ramaswamy(PwC)               Inclusion of OwnerId check with type-casting.
******************************************************************************************/
public class ClientCustomerRelationshipTriggerHandler 
 {
    
    /*********************************
    Method: executeOnBeforeUpdate
    Purpose: Method executed for before update event on CCR object records
    *********************************/
    public void executeOnBeforeUpdate(list<Client_Customer_Relationship__c> CCRUpdtList, map<Id, Client_Customer_Relationship__c> oldCCRMap)
     {
        Set<ID> setCCRID = new Set<ID>();
        
        //lopping over all the Client Customer Relationsip(CCR) record details, that had ownership updates.
        for(Client_Customer_Relationship__c CCRObj : CCRUpdtList)           
         {   
            //getting all CCR record Id(s) where the owner has changed.
            if(CCRObj.OwnerId != oldCCRMap.get(CCRObj.Id).OwnerId)
             {
                setCCRID.add(CCRObj.Id);       
             }
         }                
        
        //getting list of CCR share records for those CCR records which underwent ownership changes.
        // Capturing the CCR related share records and storing them on an application constant collection list of CCRShares.
        if(!setCCRID.isEmpty())
         {
            AcostaConstants.lstCCRShareToInsert = [SELECT Id, RowCause, ParentId, UserOrGroupId, AccessLevel from Client_Customer_Relationship__Share WHERE RowCause = 'Manual' AND ParentId IN:setCCRID limit 10000];
         }   
        
        // Setting Application constant to true so that this before update context does not get executed from other transactions.
        // Since this logic has to run only when CCR records are having their ownership updated and so need to retain existing Manual Share records on CCR records.        
        AcostaConstants.CCRBeforeUpdateExecuted = true;    
     }
    
    /*********************************
    Method: executeOnAfterUpdate
    Purpose: Method executed for after update event on CCR object
    *********************************/
    public void executeOnAfterUpdate()
     {
        //if there are CCR share records to be inserted
        if(!AcostaConstants.lstCCRShareToInsert.isEmpty())
         {
            // Inserting those CCR_Share records back again
            list<Client_Customer_Relationship__Share> lstCCRShare = new list<Client_Customer_Relationship__Share>();
            // Processing all the share records related to CCR(s) to be re-inserted back to respective CCR(s).
            for(Client_Customer_Relationship__Share CCRShare :AcostaConstants.lstCCRShareToInsert)
             {
                lstCCRShare.add(CCRShare.clone());
             } 
            
            // Inserting the share records back again in order to retain access to the respective CCR record, even though access has changed.
            if(!lstCCRShare.isEmpty())
             {
                insert lstCCRShare;
             }             
        }   
         // Setting Application constant to true so that this after update context does not get executed from other transactions.
        // Since this logic has to run only when CCR records are having their ownership updated and so need to retain existing Manual Share records on CCR records.
        AcostaConstants.CCRAfterUpdateExecuted = true;     
    }
}