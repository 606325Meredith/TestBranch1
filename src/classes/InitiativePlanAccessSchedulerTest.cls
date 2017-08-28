/**************************************************************************************
Apex Class Name:    InitiativePlanAccess
Version     : 1.0 
Created Date    : 19 Sep 2016
Description    : Test class for the class   InitiativePlanAccess
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anil Nedunuri            19 Sep 2016              Original Version
*************************************************************************************/
@isTest
private class  InitiativePlanAccessSchedulerTest{
public static String CRON_EXP = '0 15 * * * ?';
//---------------------------------------------------------------------------------------------------------------------

  /**
     * @Description : test method to test the National Initiative List
     */ 
         
    private static testMethod void InitiativeClientInsertTest() {

        List<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);    
        List<Account> listCustAcc = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 51);
        List<Account> listAcc = new List<Account>();
        listAcc.addAll(listClientAcc);
        listAcc.addAll(listCustAcc);
        insert listAcc;
        
        List<User> listUser = UtilityClassForTestDataSetUp.createUserList(50);
        insert listUser;
         System.Debug('TocheckUserInsert'+listUser);
         
        List<AccountTeamMember> listATM = UtilityClassForTestDataSetUp.createATMList(listClientAcc[0], listUser);
        insert listATM;
        System.Debug('TocheckATMInsert'+listATM);
        
        System.assertEquals(50, listATM.size()); 
         
        
        List<Recordtype> recType = new List<Recordtype>();
        recType = [SELECT Id from RecordType Where Sobjecttype ='Customer_Visit__c' and Name='Master'];
        
        List<Recordtype> recTypeChild = new List<Recordtype>();
        recTypeChild = [SELECT Id from RecordType Where Sobjecttype ='Customer_Visit__c' and Name='Refine'];
        
        
        List<Customer_Visit__c> listCV = new List<Customer_Visit__c>();
        for(integer i=0;i<10;i++){
            Customer_Visit__c cvList = new Customer_Visit__c(); 
            cvList.Name = 'Test CV Name';
            cvList.Master__c =null;
            cvList.RecordtypeId = recType[0].Id;
            cvList.Start_Date__c = system.today();
            cvList.End_Date__c = system.today() + 1;
            listCV.add(cvList);
        }
        insert listCV;
        
        
        List<Customer_Visit__c> listCVChild = new List<Customer_Visit__c>();
        for(integer i=0;i<10;i++){
            Customer_Visit__c cvList = new Customer_Visit__c(); 
            cvList.Name = 'Test CV Name' + string.valueOf(i);
            cvList.Master__c =listCV[0].Id;
            cvList.RecordtypeId = recTypeChild[0].Id;
            cvList.Start_Date__c = system.today();
            cvList.End_Date__c = system.today() + 1;
            listCVChild.add(cvList);
        }
        insert listCVChild;
        
        set<Id> setCV = new set<Id>();
        for(Customer_Visit__c  objCV : listCV)
        {
            setCV.add(objCV.Id);
        }
        System.Debug('TocheckCVInsert'+listCV);
                
        
        List<Customer_Visit_Account_Relationship__c> lstClientCVAR = new List<Customer_Visit_Account_Relationship__c>();
        for(integer j=0;j<10;j++){
            Customer_Visit_Account_Relationship__c cvarClLst = new Customer_Visit_Account_Relationship__c();
            cvarClLst.Account__c = listClientAcc[0].Id;
            cvarClLst.Customer_Visit__c = listCV[0].Id;
            lstClientCVAR.add(cvarClLst);
        }
        insert lstClientCVAR;
        
        
        List<Customer_Visit__Share> lstCVS = new List<Customer_Visit__Share>();
        for(integer k=0;k<10;k++){
            Customer_Visit__Share cvs = new Customer_Visit__Share();
            cvs.ParentId = listCV[0].Id;
            cvs.UserOrGroupId = listUser[0].Id;
            cvs.Accesslevel ='Read';
            cvs.RowCause = Schema.Customer_Visit__share.RowCause.AccountTeamMember__c;
            lstCVS.add(cvs);
        }
        insert lstCVS;
        //List<Customer_Visit_Account_Relationship__c> listCVAR = [Select id from Customer_Visit_Account_Relationship__c where Customer_Visit__c in : setCV];
        
        
        //System.assertEquals(550, listCVAR.size());   
            
        Test.startTest();   
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new InitiativePlanAccessScheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);
         

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();  
        
        
               
    
    }
      
    
}