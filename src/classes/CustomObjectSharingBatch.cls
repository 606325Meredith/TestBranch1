/**************************************************************************************
Apex Class Name:  CustomObjectSharingBatch
Version     : 1.0 
Created Date    : 10/27/2016
Description    : Creates Product__Share for CCATMs that are modified in the last n hours (24 hours is default). 
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* CoastalCloud 				10/27/2016				Original Version
*************************************************************************************/

global class CustomObjectSharingBatch implements Database.Batchable<sObject> , Database.Stateful,Schedulable{
	
	String query;
	Date startDate;
	public static final Integer DEFAULT_LAST_MODIFIED_HOURS = 24;
	Set<Id>userIdsFromDeletedCCATs = new Set<Id>();
	Set<Id> userIdsFromCCATsWithAccess = new Set<Id>();
	Set<Id> userIdsFromCCATsWithNoAccess = new Set<Id>();
	Set<Id> allUserIdsAffected = new Set<Id>();
	Set<Id>clientL3AccountIds = new Set<Id>();
	Set<Id>clientL4AccountIds = new Set<Id>();

	//Default constructor. Use yesterday's date as start date in this case.
	global CustomObjectSharingBatch() 
	{
		this(DEFAULT_LAST_MODIFIED_HOURS);
	}

	global CustomObjectSharingBatch(Integer lastModifiedHours) {


		Datetime queryStartTime = System.now().addHours(-lastModifiedHours);
		//Read all the Client Customer Account Team records from the start date onwards. Include deleted records also
		//Assumption is the number of CCATMs will not be >50,000
		
		System.debug('queryStartTime=========='+queryStartTime);
		for(Client_Customer_Account_Team__c ccat: [SELECT Id, isDeleted,User__c, Client_Access__c, Client_Customer_Relationship__r.Client__r.parentId,Client_Customer_Relationship__r.Client__c 
					FROM Client_Customer_Account_Team__c 
					WHERE Source__c = 'Customer' 
					AND LASTMODIFIEDDATE>:queryStartTime ALL ROWS])
		{
			clientL3AccountIds.add(ccat.Client_Customer_Relationship__r.Client__r.parentId);
			clientL4AccountIds.add(ccat.Client_Customer_Relationship__r.Client__c);
			if(ccat.isDeleted)
			{
				userIdsFromDeletedCCATs.add(ccat.User__c);
			}else if(AcostaConstants.mapAccessLevelShare.containsKey(ccat.Client_Access__c))
			{
				userIdsFromCCATsWithAccess.add(ccat.User__c);
			}else
			{
				userIdsFromCCATsWithNoAccess.add(ccat.User__c);
			}
			allUserIdsAffected.add(ccat.User__c);
		}//end for on CCAT
		//query = 'SELECT id, isdeleted from Client_Customer_Account_Team__c WHERE LASTMODIFIEDDATE>:queryStartTime ALL ROWS';
		System.debug('clientL3AccountIds=========='+clientL3AccountIds);
		System.debug('clientL4AccountIds=========='+clientL4AccountIds);
		System.debug('userIdsFromDeletedCCATs=========='+userIdsFromDeletedCCATs);
		System.debug('userIdsFromCCATsWithAccess=========='+userIdsFromCCATsWithAccess);
		System.debug('userIdsFromCCATsWithNoAccess=========='+userIdsFromCCATsWithNoAccess);
		System.debug('allUserIdsAffected=========='+allUserIdsAffected);
		query = 'SELECT Id from Product__c WHERE  Account__c IN :clientL3AccountIds OR Account__c in :clientL4AccountIds';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new CustomObjectSharingBatch(),100); 
    }

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		/*
   		//For each set of 200 products, manipulate the product shares
   		List<Product__c> productsAffected = (List<Product__c>)scope;

   		System.debug('productsAffected=========='+productsAffected);

   		List<Product__Share> productSharesToDelete = new List<Product__Share>();
   		List<Product__Share> productSharesToInsert = new List<Product__Share>();

   		for(Product__Share ps: [SELECT AccessLevel ,ParentId ,UserOrGroupId 
   								FROM Product__Share 
   								WHERE UserOrGroupId IN : this.allUserIdsAffected 
   								AND RowCause =: Schema.Product__Share.RowCause.CustomerAccountTeam__c 
   								AND ParentId IN: productsAffected])
		{
			if(this.userIdsFromDeletedCCATs.contains(ps.UserOrGroupId)
				|| this.userIdsFromCCATsWithNoAccess.contains(ps.UserOrGroupId))
			{
				productSharesToDelete.add(ps);	
			}
			/if(userIdsFromCCATsWithAccess.contains(ps.UserOrGroupId))
			{
				productSharesToInsert.add(ps);	
			}
			
		}

		for(Id userId: this.userIdsFromCCATsWithAccess)
		{
			for(Product__c p: productsAffected)
			{
				Product__Share ps = new Product__Share();
				ps.UserOrGroupId = userId;
                ps.ParentId = p.Id;                                 
                ps.AccessLevel = 'Read'; 
                ps.RowCause = Schema.Product__Share.RowCause.CustomerAccountTeam__c; 
				productSharesToInsert.add(ps);	
			}//end for on productsAffected
			
		}//end for on userIdsFromCCATsWithAccess
		
		System.debug('productSharesToInsert---'+JSON.serialize(productSharesToInsert));
		System.debug('productSharesToDelete---'+JSON.serialize(productSharesToDelete));
		System.debug('productsAffected---'+JSON.serialize(productsAffected));
		System.debug('allUserIdsAffected---'+JSON.serialize(allUserIdsAffected));

		try
		{
			if(!productSharesToInsert.isEmpty())
			{
				Database.insert(productSharesToInsert,false);
			}
			if(!productSharesToDelete.isEmpty())
			{
				Database.delete(productSharesToDelete,false);
			}

		}catch(Exception e)
		{
			AcostaConstants.logCustomException('CustomObjectSharingBatch','execute',e.getMessage(),e.getLineNumber()); 
		}

		*/
		
	}//end execute
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}