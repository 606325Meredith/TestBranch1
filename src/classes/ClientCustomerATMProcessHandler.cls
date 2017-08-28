/**************************************************************************************
Apex Class Name:  ClientCustomerATMProcessHandler
Version     : 1.1
Created Date    :
Description    : Batch class to bring all account team members from client and customer account in the client customer junction object. This class is also responsible for
                 deletion of atm members from the client customer junction object. Also, This batch job will give READ access to L1, L2, L3 and L4 clients
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rakesh Ramaswamy(PwC)      04/07/2017				 Initial Development.
* Rakesh Ramaswamy(PwC)		 04/21/2017				 Updated code by removing ATM_Client_Account_Access__c & ATM_Customer_Account_Access__c from the code.
													 Removed all references of the above mentioned field from the code as it is irrelevant.
*************************************************************************************/

public class ClientCustomerATMProcessHandler
{
    public void CCATInsertUpdtDeleteHandler(list<Client_Customer_Relationship__c> scope, DateTime startDateVal)
    {
        try
        {
            Set<Id> setClientId = new Set<Id>();
            Set<Id> setCustId = new Set<Id>();
            Set<Id> setRelId = new Set<Id>();
            for(Client_Customer_Relationship__c rel : scope)
            {
                setClientId.add(rel.Client__c);
                setCustId.add(rel.Customer__c);
                setRelId.add(rel.Id);
            }
            system.debug('scope ====> '+scope);

            //get all the atm records for the setClientId and setCustId and construct the map. This is required for the insertion logic
            map<Id, list<AccountTeamMember>> mapClientATM = new map<Id, list<AccountTeamMember>>();
            map<Id, list<AccountTeamMember>> mapCustATM = new map<Id, list<AccountTeamMember>>();

            for(AccountTeamMember atm : [Select id, AccountId, Account.RecordType.Name, TeamMemberRole, UserId, AccountAccessLevel, CreatedById, CreatedDate, LastModifieddate from AccountTeamMember where AccountId in : setClientId OR AccountId in : setCustId])
            {
                //builds a nested map on Account ID of all the Client Account team members for multiple Client accounts
                if(setClientId.contains(atm.AccountId))
                {
                    if(mapClientATM.containsKey(atm.AccountId))
                    {
                        mapClientATM.get(atm.AccountId).add(atm);
                    }
                    else
                    {
                        mapClientATM.put(atm.AccountId, new List<AccountTeamMember>{atm});
                    }
                }
                //builds a nested map on Account ID of all the Customer Account team members for multiple Customer accounts
                else
                {
                    if(mapCustATM.containsKey(atm.AccountId))
                    {
                        mapCustATM.get(atm.AccountId).add(atm);
                    }
                    else
                    {
                        mapCustATM.put(atm.AccountId, new List<AccountTeamMember>{atm});
                    }
                }
            }
            system.debug('mapClientATM ====> '+JSON.serialize(mapClientATM));
            system.debug('mapCustATM ====> '+JSON.serialize(mapCustATM));

            //get all the atm records associated to the junction object and construct the map. This is required for the delete logic.
            map<Id, List<Client_Customer_Account_Team__c>> mapIdCCATM = new map<Id, List<Client_Customer_Account_Team__c>>();
            map<String, Client_Customer_Account_Team__c> mapUniqCCATM = new map<String, Client_Customer_Account_Team__c>();
            map<String, list<AccountTeamMember>> mapCCRIdUsrIdlstATMs = new map<String,  list<AccountTeamMember>>();

            for(Client_Customer_Account_Team__c ccATM1 : [Select Id, Name, Client_Customer_Relationship__c, Client_Customer_Relationship__r.Client__c, Client_Customer_Relationship__r.Customer__c, CC_Access__c, Client_Customer_Access__c, User__c, CreatedById, Source__c, ATM_Client_Account_Access__c, ATM_Customer_Account_Access__c  from Client_Customer_Account_Team__c where Client_Customer_Relationship__c in : setRelId])
            {
                //builds a nested map based on CCR ID of either the client or the customer
                if(mapIdCCATM.containsKey(ccATM1.Client_Customer_Relationship__c))
                {
                    mapIdCCATM.get(ccATM1.Client_Customer_Relationship__c).add(ccATM1);
                }
                else
                {
                    mapIdCCATM.put(ccATM1.Client_Customer_Relationship__c, new List<Client_Customer_Account_Team__c>{ccATM1});
                }

                //combines all CCR records from both the client and customer into one map with a unique key based on CCR ID + User ID
                if(ccATM1.Client_Customer_Relationship__c != null && ccATM1.User__c != null)
                {
                    mapUniqCCATM.put(String.valueOf(ccATM1.Client_Customer_Relationship__c)+String.valueOf(ccATM1.User__c), ccATM1);
                }
            }
            //loop through the junction object and construct the map.
            map<Id, list<AccountTeamMember>> mapCCIdATM = new map<Id, list<AccountTeamMember>>();
            Set<String> setCCATMId = new Set<String>();
            Set<String> setUniqueCCSource = new Set<String>();

            for(Client_Customer_Relationship__c rel : scope)
            {
                //builds out a nested map based on CCR ID of all the Account Team Members for both the Client and Customer Accounts combined
                if(mapClientATM.get(rel.Client__c) != null)
                {
                    mapCCIdATM.put(rel.Id, new List<AccountTeamMember>(mapClientATM.get(rel.Client__c)));
                }
                if(mapCustATM.get(rel.Customer__c) != null && mapClientATM.get(rel.Client__c) != null && mapCCIdATM.containsKey(rel.Id))
                {
                    mapCCIdATM.get(rel.Id).addAll(mapCustATM.get(rel.Customer__c));
                }
                else if(mapCustATM.get(rel.Customer__c) != null && mapClientATM.get(rel.Client__c) == null)
                {
                    mapCCIdATM.put(rel.Id, new List<AccountTeamMember>(mapCustATM.get(rel.Customer__c)));
                }
                //unique key for delete logic
                if(mapCCIdATM.get(rel.Id) != null)


                {
                    for(AccountTeamMember atm : mapCCIdATM.get(rel.Id))
                    {
                        //create a set of unique values based on using the CCR ID + User Id for all entries in the above mapCCIdATM map
                        setCCATMId.add(String.valueOf(rel.Id) + String.valueOf(atm.UserId));
                        //populate the unique key, which will be used to check if the common user is deleted from the client side or customer side.
                        //values added to this set are unique based on CCR ID + User ID + 'Client'
                        if(atm.Account.RecordType.Name.equalsIgnoreCase(AcostaConstants.L3ClientType) || atm.Account.RecordType.Name.equalsIgnoreCase(AcostaConstants.L4ClientType))
                        {
                            setUniqueCCSource.add(String.valueOf(rel.Id) + String.valueOf(atm.UserId) + AcostaConstants.sourceClient);
                        }
                        //values added to this set are unique based on CCR ID + User ID + 'Customer'
                        else
                        {
                            setUniqueCCSource.add(String.valueOf(rel.Id) + String.valueOf(atm.UserId) + AcostaConstants.sourceCustomer);
                        }

                        // Preparing a map collection to determine no of ATM(s) exist for a given CCAT User under a given CCR Channel.
                        list<AccountTeamMember> acctMembList;

                        if(!mapCCRIdUsrIdlstATMs.containsKey(String.valueOf(rel.Id)+String.valueOf(atm.UserId)))
                        {
                            acctMembList = new list<AccountTeamMember>();
                            acctMembList.add(atm);
                            mapCCRIdUsrIdlstATMs.put(String.valueOf(rel.Id)+String.valueOf(atm.UserId), acctMembList);
                        }
                        else
                        {
                            acctMembList = mapCCRIdUsrIdlstATMs.get(String.valueOf(rel.Id)+String.valueOf(atm.UserId));
                            acctMembList.add(atm);
                            mapCCRIdUsrIdlstATMs.put(String.valueOf(rel.Id)+String.valueOf(atm.UserId), acctMembList);
                        }
                    }
                }
            }

            //Loop through the junction object and create the account teams.
            Map<String, Client_Customer_Account_Team__c> mapCCATM = new Map<String, Client_Customer_Account_Team__c>();
            List<Client_Customer_Account_Team__c> listCCATMDelete = new List<Client_Customer_Account_Team__c>();
            for(Client_Customer_Relationship__c rel : scope)
            {
                //loop through nested map based on CCR ID of all the Account Team Members for both the Client and Customer Accounts combined
                if(mapCCIdATM.get(rel.Id) != null)
                {
                    for(AccountTeamMember atm : mapCCIdATM.get(rel.Id))
                    {
                        //only work with the records that were edited or created after the "startDateVal" below
                        //setting the value in the label to zero will set the startDateVal value to 00:00:00 of the current day
                        Integer daysInterval = Integer.valueOf(System.Label.NoOfDaysATMPicked) * -1;
                        if(atm.CreatedDate >= startDateVal.addDays(daysInterval) || atm.LastModifieddate >= startDateVal.addDays(daysInterval))
                        {
                            //check values from the map that combines all CCR records from both the client and customer
                            //into one map with a unique key based on CCR ID + User ID
                            if(mapUniqCCATM.containsKey(String.valueOf(rel.Id)+String.valueOf(atm.UserId)))
                            {
                                Client_Customer_Account_Team__c ccATM = mapUniqCCATM.get(String.valueOf(rel.Id)+String.valueOf(atm.UserId));
                                system.debug('In mapUniqCCATM for user =====> '+atm.UserId);
                                //make sure the edit to the "atm" record included changing the AccountAccessLevel
                                if((((ccATM.Source__c != AcostaConstants.sourceClient) && (setClientId != null) && setClientId.contains(atm.AccountId) && (ccATM.ATM_Client_Account_Access__c != atm.AccountAccessLevel)) ||
                                    ((ccATM.Source__c != AcostaConstants.sourceCustomer) && (setCustId != null) && setCustId.contains(atm.AccountId) && (ccATM.ATM_Customer_Account_Access__c != atm.AccountAccessLevel))) &&
                                    ((mapCCRIdUsrIdlstATMs != null) && mapCCRIdUsrIdlstATMs.containsKey(String.valueOf(ccATM.Client_Customer_Relationship__c)+String.valueOf(ccATM.User__c)) &&
                                    (mapCCRIdUsrIdlstATMs.get(String.valueOf(ccATM.Client_Customer_Relationship__c)+String.valueOf(ccATM.User__c)).size() > 1)))
                                {
                                    ccATM.Source__c = AcostaConstants.sourceCC;
                                    ccATM.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
                                }
                                //set the Client or Customer access for the related account based on the AccountAccessLevel of the
                                //current mapCCIdATM record. This value is based on the access indicated at the accunt team record level
                                if((setClientId != null) && setClientId.contains(atm.AccountId))
                                {
                                    ccATM.Client_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.ATM_Client_Account_Access__c = atm.AccountAccessLevel;
                                }

                                if((setCustId != null) && setCustId.contains(atm.AccountId))
                                {
                                    ccATM.CC_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.ATM_Customer_Account_Access__c = atm.AccountAccessLevel;
                                }
                                mapCCATM.put(String.valueOf(rel.Id) + String.valueOf(atm.UserId), ccATM);
                            }
                            //check the values of the new mapCCATM declared above and modify as needed
                            //these records will update the CCR record access based on the related Account Team Record
                            else if(mapCCATM.containsKey(String.valueOf(rel.Id)+String.valueOf(atm.UserId)))
                            {
                                Client_Customer_Account_Team__c ccATM = mapCCATM.get(String.valueOf(rel.Id)+String.valueOf(atm.UserId));
                                system.debug('In mapCCATM for user =====> '+atm.UserId);
                                //make sure the edit to the "atm" record included changing the AccountAccessLevel
                                //check to see if the source should be Client-Customer?
                                if((((ccATM.Source__c != AcostaConstants.sourceClient) && (setClientId != null) && setClientId.contains(atm.AccountId) && (ccATM.ATM_Client_Account_Access__c != atm.AccountAccessLevel)) ||
                                    ((ccATM.Source__c != AcostaConstants.sourceCustomer) && (setCustId != null) && setCustId.contains(atm.AccountId) && (ccATM.ATM_Customer_Account_Access__c != atm.AccountAccessLevel))) &&
                                    ((mapCCRIdUsrIdlstATMs != null) && mapCCRIdUsrIdlstATMs.containsKey(String.valueOf(ccATM.Client_Customer_Relationship__c)+String.valueOf(ccATM.User__c)) &&
                                    (mapCCRIdUsrIdlstATMs.get(String.valueOf(ccATM.Client_Customer_Relationship__c)+String.valueOf(ccATM.User__c)).size() > 1)))
                                {
                                    ccATM.Source__c = AcostaConstants.sourceCC;
                                    ccATM.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
                                }

                                if((setClientId != null) && setClientId.contains(atm.AccountId))
                                {
                                    ccATM.Client_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.ATM_Client_Account_Access__c = atm.AccountAccessLevel;
                                }

                                if((setCustId != null) && setCustId.contains(atm.AccountId))
                                {
                                    ccATM.CC_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.ATM_Customer_Account_Access__c = atm.AccountAccessLevel;
                                }
                                mapCCATM.put(String.valueOf(rel.Id) + String.valueOf(atm.UserId), ccATM);
                            }
                            //add a new CCAT record based on the record access levels declared at the related account team record level
                            else
                            {
                                Client_Customer_Account_Team__c ccATM = new Client_Customer_Account_Team__c();
                                system.debug('In create new CCR record for user =====> '+atm.UserId);

                                ccATM.Client_Customer_Relationship__c = rel.Id;
                                ccATM.User__c = atm.UserId;
                                if((setClientId != null) && setClientId.contains(atm.AccountId))
                                {
                                    ccATM.Client_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.Source__c = AcostaConstants.sourceClient;
                                    ccATM.CC_Access__c = AcostaConstants.readAccess;
                                    ccATM.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
                                    ccATM.ATM_Client_Account_Access__c = atm.AccountAccessLevel;
                                }
                                if((setCustId != null) && setCustId.contains(atm.AccountId))
                                {
                                    ccATM.Source__c = AcostaConstants.sourceCustomer;
                                    ccATM.CC_Access__c = AcostaConstants.mapAccessLevel.get(atm.AccountAccessLevel);
                                    ccATM.Client_Access__c = AcostaConstants.noAccess;
                                    ccATM.Client_Customer_Access__c = AcostaConstants.noAccess;
                                    ccATM.ATM_Customer_Account_Access__c = atm.AccountAccessLevel;
                                }
                                mapCCATM.put(String.valueOf(rel.Id)+String.valueOf(atm.UserId), ccATM);
                            }
                        }
                    }
                }
                else
                {
                    // Logic to delete the Account Team Members from the junction object
                    // Loop through nested map of CCAT Records based on CCR ID of either the client or the customer
                    // remove all CCAT team members from the object if the CCR record no longer exists
                    if(mapIdCCATM.get(rel.Id) != null)
                    {
                        for(Client_Customer_Account_Team__c ccATMExisting : mapIdCCATM.get(rel.Id))
                        {
                            listCCATMDelete.add(ccATMExisting);
                        }
                    }
                }

                // Logic to delete the Account Team Members from the junction object
                if(mapIdCCATM.get(rel.Id) != null)
                {
                    for(Client_Customer_Account_Team__c ccATMExisting : mapIdCCATM.get(rel.Id))
                    {
                        if(mapCCIdATM.get(rel.Id) != null && !setCCATMId.contains(String.valueOf(rel.Id)+String.valueOf(ccATMExisting.User__c)))
                        {
                            listCCATMDelete.add(ccATMExisting);
                        }
                        //handle the delete scenario for the case, when the same user was previously present in both client and customer but removed from one of those now.
                        if(ccATMExisting.Source__c.equalsIgnoreCase(AcostaConstants.sourceCC))
                        {
                            //update the Client-Customer relationships to make them either Client only or Customer only if an account team member is deleted from either of the related accounts
                            if(!setUniqueCCSource.contains(String.valueOf(ccATMExisting.Client_Customer_Relationship__c)+String.valueOf(ccATMExisting.User__c)+AcostaConstants.sourceClient))
                            {
                                ccATMExisting.Source__c = AcostaConstants.sourceCustomer;
                                ccATMExisting.Client_Access__c = AcostaConstants.noAccess;
                                ccATMExisting.Client_Customer_Access__c = AcostaConstants.noAccess;
                                mapCCATM.put(String.valueOf(ccATMExisting.Client_Customer_Relationship__c)+String.valueOf(ccATMExisting.User__c), ccATMExisting);
                            }
                            else if(!setUniqueCCSource.contains(String.valueOf(ccATMExisting.Client_Customer_Relationship__c)+String.valueOf(ccATMExisting.User__c)+AcostaConstants.sourceCustomer))
                            {
                                ccATMExisting.Source__c = AcostaConstants.sourceClient;
                                ccATMExisting.CC_Access__c = AcostaConstants.readAccess;
                                ccATMExisting.Client_Customer_Access__c = AcostaConstants.readWriteAccess;
                                mapCCATM.put(String.valueOf(ccATMExisting.Client_Customer_Relationship__c)+String.valueOf(ccATMExisting.User__c), ccATMExisting);
                            }
                        }
                    }
                }
            }

            //update all CCAT records in the map if it is not empty
            if(mapCCATM.size() > 0)
            {
                list<Client_Customer_Account_Team__c> CCATTempUpsrtList = mapCCATM.values();
                if (CCATTempUpsrtList.size() > 10000) system.debug('10K Record Limit exceeded for CCATTempUpsrtList =====> '+CCATTempUpsrtList);
                Database.upsert(CCATTempUpsrtList, false);
            }
            //delete all CCAT records in the map if it is not empty
            if(listCCATMDelete.size() > 0)
            {
                if (listCCATMDelete.size() > 10000) system.debug('10K Record Limit exceeded for listCCATMDelete =====> '+listCCATMDelete);
                Database.delete(listCCATMDelete,false);
            }
        }
        catch(Exception ex)
        {
            AcostaConstants.logCustomException('ClientCustomerATMProcessHandler','CCATInsertUpdtDeleteHandler',ex.getMessage(),ex.getLineNumber());
        }
    }
}