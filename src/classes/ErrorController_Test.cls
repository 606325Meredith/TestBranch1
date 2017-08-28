/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
 * Description  :   Test class for the LocalStrategyAllocation  class.
 * 
 * Created By   :   Rahul Nasa 
 * Created Date :   9/19/2016
 */
@isTest(seeAllData=false)
public class ErrorController_Test {

    //unit test method
    static testMethod void testMethod1() {
        List<PermissionSetAssignment> ListPSA = new List<PermissionSetAssignment>([SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Create_Ability_On_National_Strategy']);
        system.debug('ListPSA-->'+ListPSA );
        List<User> ListUser ;
        if(ListPSA !=null && ListPSA.size()>0)
        {
            ListUser = new List<User>([Select Id from user where Id=:ListPSA[0].AssigneeId]);
        }
        List<Account> listL3Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 1);        
        Insert listL3Client;
        List<Account> listL4Client = UtilityClassForTestDataSetUp.CreateAccountList('Client - BU - L4', 5);
        for(Account acc : listL4Client){
            acc.ParentId = listL3Client[0].Id;
        }
        insert listL4Client ;
        
        List<National_Strategy__c> ListNS =  UtilityClassForTestDataSetUp.createNSList(listL3Client);
        insert ListNS;
                
                
                
                List<National_Initiative__c>  NI = UtilityClassForTestDataSetUp.createNIList(ListNS);
                Insert NI;        
        // setup the page parameters and select the clients and add them
        system.debug('ListUser-->'+ListUser);
        Test.startTest();
        if(ListUser !=null && ListUser.size()>0)
        {
            system.runAs(ListUser[0])
            {
                system.debug('Test-->');
                System.currentPageReference().getParameters().put('ClientId', listL3Client[0].Id);  
                ErrorController conEC = new ErrorController();
                conEC.Checkpermissions();
                
                
                System.currentPageReference().getParameters().put('strategyID', ListNS[0].Id); 
                System.currentPageReference().getParameters().put('ClientId', null); 
                ErrorController con1 = new ErrorController();
                con1.Checkpermissions();
                
                // setup the page parameters and select the clients and add them
                
                System.currentPageReference().getParameters().put('id', NI[0].Id);
                System.currentPageReference().getParameters().put('strategyID', null);
                ErrorController con2 = new ErrorController();
                con2.Checkpermissions();
                
            }   
        
    }
    Test.stopTest();
    }
}