/**************************************************************************************
Apex Class Name:  ClientCustomerATMProcessSchedulerTest
Version     : 1.0 
Created Date    : 6 Jun 2016
Description    : Test class for the batch class ClientCustomerATMProcessScheduler
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar            6 Jun 2016              Original Version
*************************************************************************************/
@isTest
private class ClientCustomerATMProcessSchedulerTest{

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : test method to test the ClientCustomerATMProcessScheduler
     */ 
    private static testMethod void clientCustomerATMProcessSchedulerTest() {
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new ClientCustomerATMProcessScheduler()); 
        Test.stopTest();
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);     
    } 
}