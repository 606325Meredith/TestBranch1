trigger ResearchRequestTrigger on Research_Request__c (after insert, after update, before update, before insert) {

    List<Research_Request__c> researchRequests = Trigger.new;   

    List<Group> queues = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue'];

    Map<String,Id> queueNameToQueueIdMap = new Map<String,Id>();

    List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType];

    Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>(recordTypes);   

    Id trainingRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Training'].Id;

    for(Group q : queues) {queueNameToQueueIdMap.put(q.DeveloperName,q.Id);} 

    if(Trigger.isBefore && Trigger.isInsert) {

        Set<Id> ccrIds = new Set<Id>();
        
        for(Research_Request__c rr : researchRequests) {

            if(rr.RecordTypeId != trainingRecordTypeId) {

                if(rr.Client__c !=null && rr.Customer__c != null) {rr.addError(' You cannot select both a client and a customer. If you wish, select a CCR'); return;}

                else if(rr.Client__c != null && rr.Client_Customer_Relationship__c != null) {rr.addError(' You cannot select both a Client and a CCR.'); return;}

                else if(rr.Customer__c != null && rr.Client_Customer_Relationship__c != null) {rr.addError(' You cannot select both a Customer and a CCR.'); return;}

                else if (rr.Client_Customer_Relationship__c == null && rr.Client__c == null && rr.Customer__c == null) {rr.addError(' You need to at least select a Client, Customer, or CCR'); return;}    
                      
            }

            if(rr.Client_Customer_Relationship__c != null && rr.Client__c == null && rr.Customer__c == null) {

                rr.sourceType__c = 'CCR';

                ccrIds.add(rr.Client_Customer_Relationship__c);

            }

            else if(rr.Client__c !=null && rr.Customer__c == null && rr.Client_Customer_Relationship__c == null) {rr.sourceType__c = 'Client Account';}

            else if(rr.Customer__c !=null && rr.Client__c == null && rr.Client_Customer_Relationship__c == null) {rr.sourceType__c = 'Customer Account';}

            String queueName = recordTypeMap.get(rr.RecordTypeId).DeveloperName;

            rr.OwnerId = queueNameToQueueIdMap.get(queueName);

            rr.dateOfCurrentStatusAssignment__c = DateTime.now();

        }

        List<Client_Customer_Relationship__c> ccrs = [SELECT Client__c, Customer__c FROM Client_Customer_Relationship__c WHERE Id IN: ccrIds];

        Map<Id,Client_Customer_Relationship__c> ccrMap = new Map<Id,Client_Customer_Relationship__c>(ccrs); 

        for(Research_Request__c rr : researchRequests) {

            if(rr.sourceType__c == 'CCR') {
                        
                rr.Client__c = ccrMap.get(rr.Client_Customer_Relationship__c).Client__c;

                rr.Customer__c = ccrMap.get(rr.Client_Customer_Relationship__c).Customer__c;   

            }

        }  

    }

    else if(Trigger.isBefore && Trigger.isUpdate) {

        Set<Id> ownerIds = new Set<Id>();

        for(Research_Request__c rr : researchRequests) {ownerIds.add(rr.OwnerId);}

        if(Trigger.old != null){for(Research_Request__c rr : Trigger.old) {ownerIds.add(rr.OwnerId);}}

        List<User> userOwners = [SELECT Id, Name FROM User WHERE id IN: ownerIds];

        Map<Id,User> userMap = new Map<Id,User>(userOwners);

        List<Group> queueOwners = [SELECT Id, Name FROM Group WHERE Id IN: ownerIds AND Type = 'Queue'];

        Map<Id,Group> queueMap = new Map<Id,Group>(queueOwners);

        for(Research_Request__c rr : researchRequests) {

            Boolean r2IsNull = rr.Requester_2__c == null;

            Boolean r3IsNull = rr.Requester_3__c == null;

            Research_Request__c oldRecord = Trigger.oldMap.get(rr.Id);

            Boolean ownerHasChanged = oldRecord.OwnerId != rr.OwnerId;

            Boolean newOwnerIsQueue = queueMap.keySet().contains(rr.OwnerId);

            Boolean hasAlreadyBeenAssigned = rr.hasBeenAssignedToNewUserOwner__c;

            Boolean recordTypeHasChanged = oldRecord.RecordTypeId != rr.RecordTypeId;

            String status = rr.Status_of_Request__c;

            if (recordTypeHasChanged || ownerHasChanged) {

                String oldOwnerName = '';

                Id oldOwnerId = oldRecord.OwnerId;

                Boolean oldOwnerIsQueue = (queueMap.keySet().contains(oldRecord.OwnerId));

                if(oldOwnerIsQueue) {oldOwnerName = queueMap.get(oldOwnerId).Name + ' (Queue)';}

                else {oldOwnerName = userMap.get(oldOwnerId).Name;}

                rr.previousOwner__c = oldOwnerName;   

                if(recordTypeHasChanged) {             

                    String queueName = recordTypeMap.get(rr.RecordTypeId).DeveloperName;

                    rr.OwnerId = queueNameToQueueIdMap.get(queueName); 

                    rr.Status_of_Request__c = 'New';

                }

                else if(ownerHasChanged) {               
                
                    if(!hasAlreadyBeenAssigned && !newOwnerIsQueue) {rr.Status_of_Request__c = 'Assigned'; rr.hasBeenAssignedToNewUserOwner__c = true;}

                    else if(newOwnerIsQueue) {rr.Status_of_Request__c = 'New';}

                    else if(hasAlreadyBeenAssigned) {rr.Status_of_Request__c = 'Reassigned';}

                }

            }

            if(oldRecord.Status_of_Request__c != rr.Status_of_Request__c) {rr.dateOfCurrentStatusAssignment__c = DateTime.now();}  

        }

    }

    else if (Trigger.isAfter) {

        final Id currentUserId = UserInfo.getUserId();

        final Id csbiRecordTypeId = [SELECT id FROM RecordType WHERE DeveloperName = 'CSBI' LIMIT 1].Id;

        final List<EmailTemplate> rrEmailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'RR%'];  

        Map<String,Id> templateMap = new Map<String,Id>();

        for(EmailTemplate tmp : rrEmailTemplates) {templateMap.put(String.valueOf(tmp.DeveloperName), tmp.id);}         

        Map<Id, Set<Id>> rrMap = new Map<Id,Set<Id>>();

        Set<Id> allIds = new Set<Id>();

        for(Research_Request__c rr : researchRequests) {

            if(rrMap.get(rr.Id) == null) {rrMap.put(rr.Id, new Set<Id>());}

            if(rr.sourceType__c == 'Client Account') {rrMap.get(rr.Id).add(rr.Client__c);}

            if(rr.sourceType__c == 'Customer Account') {rrMap.get(rr.Id).add(rr.Customer__c);}

            if(rr.sourceType__c == 'CCR') {rrMap.get(rr.Id).add(rr.Client_Customer_Relationship__c);}

        }

        for(Id rrId : rrMap.keySet()) {allIds.addAll(rrMap.get(rrId));}

        List<AccountShare> accountShares = [SELECT

            AccountId,

            UserOrGroupId,

            AccountAccessLevel

            FROM AccountShare

            WHERE (AccountAccessLevel = 'Read' OR AccountAccessLevel = 'Edit' OR AccountAccessLevel = 'All')

                AND

                (AccountId IN: allIds)

        ];

        Map<Id,Set<AccountShare>> accountIdToAccountShareMap = new Map<Id,Set<AccountShare>>();

        Map<Id,Set<Id>> accountIdToUserIdsMap = new Map<Id,Set<Id>>();

        for(AccountShare shr : accountShares) {

            if(accountIdToAccountShareMap.get(shr.AccountId) == null) {accountIdToAccountShareMap.put(shr.AccountId, new Set<AccountShare>());}

            accountIdToAccountShareMap.get(shr.AccountId).add(shr);

            if(accountIdToUserIdsMap.get(shr.AccountId) == null) {accountIdToUserIdsMap.put(shr.AccountId, new Set<Id>());}

            accountIdToUserIdsMap.get(shr.AccountId).add(shr.UserOrGroupId);

        }     

        System.debug(accountIdToUserIdsMap);

        List<Client_Customer_Relationship__Share> ccrShares = [SELECT

            ParentId,

            UserOrGroupId,

            AccessLevel

            FROM Client_Customer_Relationship__Share

            WHERE (AccessLevel = 'Read' OR AccessLevel = 'Edit' OR AccessLevel = 'All')

                AND

                (ParentId IN: allIds)

        ];  

        Map<Id,Set<Client_Customer_Relationship__Share>> ccrIdToCcrShareMap = new Map<Id,Set<Client_Customer_Relationship__Share>>();

        Map<Id,Set<Id>> ccrIdToUserIdsMap = new Map<Id,Set<Id>>();    

        for(Client_Customer_Relationship__Share shr : ccrShares) {

            if(ccrIdToCcrShareMap.get(shr.ParentId) == null) {ccrIdToCcrShareMap.put(shr.ParentId, new Set<Client_Customer_Relationship__Share>());}

            ccrIdToCcrShareMap.get(shr.ParentId).add(shr);

            if(ccrIdToUserIdsMap.get(shr.ParentId) == null) {ccrIdToUserIdsMap.put(shr.ParentId, new Set<Id>());}

            ccrIdToUserIdsMap.get(shr.ParentId).add(shr.UserOrGroupId);

        }       

        Map<Id, Set<Research_Request__Share>> rrToShareMap = new Map<Id, Set<Research_Request__Share>>();

        for(Research_Request__c rr : researchRequests) {

            Boolean r2IsNull = (rr.Requester_2__c == null);

            Boolean r3IsNull = (rr.Requester_3__c == null);

            Set<Id> usersIdsWithAccess = new Set<Id>();

            if(rr.sourceType__c == 'Client Account') {usersIdsWithAccess = accountIdToUserIdsMap.get(rr.Client__c);}

            else if(rr.sourceType__c == 'Customer Account') {usersIdsWithAccess = accountIdToUserIdsMap.get(rr.Customer__c);}

            else if(rr.sourceType__c == 'CCR') {usersIdsWithAccess = ccrIdToUserIdsMap.get(rr.Client_Customer_Relationship__c);}       

            if((!r3IsNull && !usersIdsWithAccess.contains(rr.Requester_3__c))
                                                ||
                (!r2IsNull && !usersIdsWithAccess.contains(rr.Requester_2__c))) {

                    rr.addError(' A user you\'ve selected does not have access to the account or CCR selected for this research request');

                    return;

            }

            Boolean isCsbiRequest = (rr.RecordTypeId == csbiRecordTypeId);

            Set<Id> accountOrCcrIds = rrMap.get(rr.Id);

            for(Id accountOrCcrId : accountOrCcrIds) {

                Set<Client_Customer_Relationship__Share> rrCcrShares = null;

                Set<AccountShare> rrAccountShares = null;

                rrCcrShares = ccrIdToCcrShareMap.get(accountOrCcrId);

                rrAccountShares = accountIdToAccountShareMap.get(accountOrCcrId);

                if(rrCcrShares != null) {

                    if(rrToShareMap.get(rr.Id) == null) {rrToShareMap.put(rr.Id, new Set<Research_Request__Share>());}

                    for(Client_Customer_Relationship__Share shr : rrCcrShares) {

                        Research_Request__Share rrShare = new Research_Request__Share();

                        rrShare.ParentId = rr.Id;

                        rrShare.RowCause = 'Manual';

                        rrShare.UserOrGroupId = shr.UserOrGroupId;

                        if(shr.AccessLevel == 'Edit' || shr.AccessLevel == 'All') {rrShare.AccessLevel = 'Edit';}

                        else {rrShare.AccessLevel = 'Read';}

                        rrToShareMap.get(rr.Id).add(rrShare);

                    }

                }

                else if(rrAccountShares != null) {

                    if(rrToShareMap.get(rr.Id) == null) {rrToShareMap.put(rr.Id, new Set<Research_Request__Share>());}

                    for(AccountShare shr : rrAccountShares) {

                        Research_Request__Share rrShare = new Research_Request__Share();

                        rrShare.ParentId = rr.Id;

                        rrShare.RowCause = 'Manual';

                        rrShare.UserOrGroupId = shr.UserOrGroupId;

                        if(shr.AccountAccessLevel == 'Edit' || shr.AccountAccessLevel == 'All' ) {rrShare.AccessLevel = 'Edit';}

                        else {rrShare.AccessLevel = 'Read';}

                        rrToShareMap.get(rr.Id).add(rrShare);

                    }

                }

            }            

        }  

        List<Research_Request__Share> rrSharesToInsert = new List<Research_Request__Share>();

        for(Id rrId : rrToShareMap.keySet()) {

            Id rrCreatorId = ((Research_Request__c)Trigger.newMap.get(rrId)).CreatedById;

            Boolean creatorIsInShares = false;

            Set<Research_Request__Share> rrShares = rrToShareMap.get(rrId);

            for(Research_Request__Share shr : rrShares) {

                if(shr.UserOrGroupId.equals(rrCreatorId)) {creatorIsInShares = true; break;}

            }

            if(!creatorIsInShares) {
                            
                Research_Request__Share rrShare = new Research_Request__Share();

                rrShare.ParentId = rrId;

                rrShare.RowCause = 'Manual';

                rrShare.UserOrGroupId = rrCreatorId;

                rrShare.AccessLevel = 'Edit';

                rrToShareMap.get(rrId).add(rrShare);

            }

            rrSharesToInsert.addAll(rrShares);

        }

        Database.insert(rrSharesToInsert, false);

    }

}