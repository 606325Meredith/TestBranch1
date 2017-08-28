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
 * Description  :   Test class for the LocalErrorController class.
 * 
 * Created By   :   Rahul Nasa 
 * Created Date :   9/19/2016
 */
@isTest(seeAllData=false)
public class LocalErrorController_Test {

    //unit test method
    static testMethod void testMethod1() {
        List<PermissionSetAssignment> ListPSA = new List<PermissionSetAssignment>([SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Create_Ability_On_Local_Strategy']);
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
        
        List<National_Strategy__c> listNS = UtilityClassForTestDataSetUp.createNSList(listL3Client);        
        Insert listNS ;
        system.debug('listNS[0].Id-->' + listNS[0].Id);
        List<Account> listL4Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Banner - L4', 5);       
        insert listL4Customer;
        List<Account> listL5Customer = UtilityClassForTestDataSetUp.CreateAccountList('Customer - Sub Banner - L5', 5);       
        insert listL5Customer;
       
        List<Client_Customer_Relationship__c> listCCRL4 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL4Customer );       
        insert listCCRL4;
        List<Client_Customer_Relationship__c> listCCRL5 = UtilityClassForTestDataSetUp.createClientCustList(listL3Client[0], listL5Customer );       
        insert listCCRL5;
        
        
        Map<Id,Id> mapClientIdNSIS ;
        for(Client_Customer_Relationship__c cc : listCCRL4)
        {
           for(National_Strategy__c NS : listNS)
           {
               if(NS.Client__c == cc.Client__c)
               {
                   mapClientIdNSIS= new Map<Id,Id>();
                   mapClientIdNSIS.put(cc.Client__c , NS.Id); 
               }
           }
        }
        List<Local_Strategy__c> listLS = UtilityClassForTestDataSetUp.createLSList(listCCRL4,mapClientIdNSIS);        
        Insert listLS ;       
                
                
                List<Local_Initiative__c>  LI = UtilityClassForTestDataSetUp.createLIList(ListLS);
                Insert LI;        
        // setup the page parameters and select the clients and add them
        system.debug('ListUser-->'+ListUser);
        Test.startTest();
        if(ListUser !=null && ListUser.size()>0)
        {
            system.runAs(ListUser[0])
            {
                system.debug('Test-->');
                System.currentPageReference().getParameters().put('CCRelId', listCCRL4[0].Id);  
                LocalErrorController conEC = new LocalErrorController();
                conEC.Checkpermissions();
                
                
                System.currentPageReference().getParameters().put('strategyID', ListLS[0].Id); 
                System.currentPageReference().getParameters().put('CCRelId', null); 
                LocalErrorController con1 = new LocalErrorController();
                con1.Checkpermissions();
                
                // setup the page parameters and select the clients and add them
                
                System.currentPageReference().getParameters().put('id', LI[0].Id);
                System.currentPageReference().getParameters().put('strategyID', null);
                LocalErrorController con2 = new LocalErrorController();
                con2.Checkpermissions();
                
            }   
        
    }
    Test.stopTest();
    }
}