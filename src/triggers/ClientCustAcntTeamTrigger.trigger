/**
     * @Author : RAKESH RAMASWAMY
     * @Company : PricewaterhouseCoopers LLP
     * @Created Date : 3rd April, 2017.
     * @Desc : Apex Trigger to provide sharing to Client Accounts , Customer Accounts and Client Customer Relationships and also the Products linked to Client Accounts.
               This trigger is invoked whenever the CCAT record is newly inserted or updated or deleted or brought back from the recycle bin of the CRM System.
 */

trigger ClientCustAcntTeamTrigger on Client_Customer_Account_Team__c (before delete, after insert, after undelete, before update, after update) 
{
    Boolean IsTriggerEnabled = AcostaConstants.GetAppSettingValue('ClientCustAcntTeamTrigger', 'yes') == 'yes' ? true : false;
    
    // Using constructor to instantiate the necessary trigger new and old data collections on CCAT data..
    ClientCustAcntTeamTriggerHelper ccatHelperObj = new ClientCustAcntTeamTriggerHelper(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
     
     if(!IsTriggerEnabled)
       {
           return;
       }     
      
      // Logic to fire when Client Customer Account Team record is newly inserted or undeleted from the Recycle Bin.
      if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete))
      {
         ccatHelperObj.processAfterInsert();
      }
    
      // Logic to fire when Client Customer Account Team record is updated.
      if(Trigger.isAfter && Trigger.isUpdate)
      {
         ccatHelperObj.processAfterUpdate();
      }   
        
      // Logic to fire when Client Customer Account Team record is deleted.  
      if(Trigger.isBefore && Trigger.isDelete)
      {         
         ccatHelperObj.processAfterDelete();
      } 
      
      // The following logic is executed whenever Client Access or Customer Access is changed.
      // When Source is Customer, only Client Access and Client Customer Relationship Access can be changed.
      // When Source is Client, only Customer Access and Client Customer Relationship Access can be changed.
      if(Trigger.isBefore && Trigger.isUpdate)
      {      	 
      	       	       	       	       	 
      	 for(Client_Customer_Account_Team__c ccatTmpRecObj : trigger.new)
      	  {
      	  	 if(ccatTmpRecObj.isCCATSourceChanged__c)
      	  	  {
      	  	  	 ccatTmpRecObj.isCCATSourceChanged__c = false;
      	  	  } 
      	  	  
      	  	 if(trigger.newMap.get(ccatTmpRecObj.Id).Source__c <> trigger.oldMap.get(ccatTmpRecObj.Id).Source__c)
      	  	  {
      	  	  	
      	  	  	if( 
      	  	  	    ((ccatTmpRecObj.Source__c != null) && ccatTmpRecObj.Source__c.equals(AcostaConstants.sourceCustomer) && (trigger.newMap.get(ccatTmpRecObj.Id).Client_Access__c <> trigger.oldMap.get(ccatTmpRecObj.Id).Client_Access__c) && (ccatTmpRecObj.Client_Access__c.equals(AcostaConstants.noAccess))) ||
      	  	  	    ((ccatTmpRecObj.Source__c != null) && ccatTmpRecObj.Source__c.equals(AcostaConstants.sourceClient) && (trigger.newMap.get(ccatTmpRecObj.Id).CC_Access__c <> trigger.oldMap.get(ccatTmpRecObj.Id).CC_Access__c) && (ccatTmpRecObj.CC_Access__c.equals(AcostaConstants.noAccess)))      	  	  	 
      	  	  	  ) 
      	  	  	 {      	  	  	 	
      	  	  	 	// This is a flagger field on the CCAT object that will be set when access setting goes to no access.
      	  	  	 	// The same flagging field is being used in the CCAT object records when CCAT's are updated w.r.t the respective accesses.
      	  	  	 	ccatTmpRecObj.isCCATSourceChanged__c = true;            	  	  	 		  	  	 	
      	  	  	 }
      	  	  }       	  	        	  	 
      	  }      	        	       	 
      }
}