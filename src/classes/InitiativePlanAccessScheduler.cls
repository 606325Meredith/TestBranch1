/**************************************************************************************
Apex Class Name:    InitiativePlanAccess
Version     : 1.0 
Created Date    : Sep 7 2016
Description    : Schedulable class to schedule the ClientCustomerATMProcess batch job.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anil Nedunuri            7 Sep 2016              Original Version
*************************************************************************************/
public class    InitiativePlanAccessScheduler implements schedulable
{
    public void execute(SchedulableContext sc)
    {
        InitiativePlanAccess IniPlanProcess = new   InitiativePlanAccess();
        Database.executebatch(IniPlanProcess);
      
    }
}