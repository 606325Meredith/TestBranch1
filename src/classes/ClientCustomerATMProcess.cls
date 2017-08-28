/**************************************************************************************
Apex Class Name:  ClientCustomerATMProcess
Version     : 1.0 
Created Date    : 30th May 2016
Description    : Batch class to bring all account team members from client and customer account in the client customer junction object. This class is also responsible for 
                 deletion of atm members from the client customer junction object. Also, This batch job will give READ access to L1, L2, L3 and L4 clients
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar        30th May 2016              Original Version
* Rakesh Ramaswamy    4th April 2017         Update query batch locator
*************************************************************************************/

public class ClientCustomerATMProcess implements Database.Batchable<sObject>{
//---------------------------------------------------------------------------------------------------------------------
    //start date value for records impacted by the batch job
    //public Datetime startDateVal = System.Today().addDays(-Integer.ValueOf(System.Label.NoOfDaysATMPicked));  --- old value
    //changed at the request of Jackie Love to only include updates from the last 24 hours
    public Datetime startDateVal = System.Today();

    /**
     * @Desc : Start method to query all the Account Teams
     */
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        List<String> ccrIDs = new List<String>{'a023600000EkbZGAAZ'};
        return Database.getQueryLocator([SELECT Id, Name, Client__c, Customer__c FROM Client_Customer_Relationship__c where id not in : ccrids]);
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Execute method to add the account team members to the client customer junction method.
     */
    public void execute(Database.BatchableContext bc, List<Client_Customer_Relationship__c> scope)
    {
        ClientCustomerATMProcessHandler CCAThandlerObj = new ClientCustomerATMProcessHandler();
        CCAThandlerObj.CCATInsertUpdtDeleteHandler(scope, startDateVal);  
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Finish method for post process logic
     */
    public void finish(Database.BatchableContext bc){}
}