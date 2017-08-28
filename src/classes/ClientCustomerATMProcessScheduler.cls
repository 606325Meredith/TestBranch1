/**************************************************************************************
Apex Class Name:  ClientCustomerATMProcessScheduler
Version     : 1.0 
Created Date    : 6 Jun 2016
Description    : Schedulable class to schedule the ClientCustomerATMProcess batch job.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yashmith Kumar            6 Jun 2016              Original Version
*************************************************************************************/
public class ClientCustomerATMProcessScheduler implements schedulable
{
    public void execute(SchedulableContext sc)
    {
      ClientCustomerATMProcess ccATMProcess = new ClientCustomerATMProcess();
      Database.executebatch(ccATMProcess, 50);
      //ProductShareClientHierarchy pShareCHierarchy = new ProductShareClientHierarchy();
      //Database.executebatch(pShareCHierarchy);
    }
}