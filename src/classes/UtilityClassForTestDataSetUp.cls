/**************************************************************************************
Apex Class Name:  UtilityClassForTestDataSetUp
Version     : 1.0
Created Date    : 6 Jun 2016
Description    : Utility class for test data set up
Modification Log :
-----------------------------------------------------------------------------
* Developer                               Date                   Description
* ----------------------------------------------------------------------------
* Yashmith Kumar, Rahul Nasa            6 Jun 2016              Original Version
*************************************************************************************/
public with sharing class UtilityClassForTestDataSetUp {

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Account records
     */
     public static List<Account> CreateAccountList(String recType, Integer count){
         List<Account> listAcc = new List<Account>();
         for(Integer i=0; i<count; i++){
             Account acc = new Account();
             acc.Name = 'Test Account';
             acc.RecordTypeId = AcostaConstants.getRecordTypeId(recType);
             listAcc.add(acc);
         }
         return listAcc;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Client Customer Relationship records.
     */
     public static List<Client_Customer_Relationship__c> createClientCustList(Account client, List<Account> listCust){
         List<Client_Customer_Relationship__c> listCC = new List<Client_Customer_Relationship__c>();
         for(Account accCust : listCust){
             Client_Customer_Relationship__c rel = new Client_Customer_Relationship__c();
             rel.Client__c = client.Id;
             rel.Customer__c = accCust.Id;
             rel.Status__c = 'Active';
             listCC.add(rel);
         }
         return listCC;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Account Team Members for the Client Customer Relationship records.
     */
     public static List<Client_Customer_Account_Team__c> createClientCustTeamList(Client_Customer_Relationship__c clientCustRel , List<User> listUser,string Source){
         List<Client_Customer_Account_Team__c> listCCT = new List<Client_Customer_Account_Team__c>();
         for(User objUser : listUser)
         {
             if(Source == AcostaConstants.sourceClient)
             {
                 Client_Customer_Account_Team__c team = new Client_Customer_Account_Team__c();
                 team.Client_Customer_Relationship__c = clientCustRel.Id;
                 team.User__c = objUser.Id;
                 team.Source__c = AcostaConstants.sourceClient;
                 team.CC_Access__c = 'Read';
                 team.Client_Access__c = 'Read/Write';
                 team.Client_Customer_Access__c ='Read/Write';
                 listCCT.add(team );
             }
             else if(Source == AcostaConstants.sourceCustomer)
             {
                 Client_Customer_Account_Team__c team = new Client_Customer_Account_Team__c();
                 team.Client_Customer_Relationship__c = clientCustRel.Id;
                 team.User__c = objUser.Id;
                 team.Source__c = AcostaConstants.sourceCustomer;
                 team.CC_Access__c = 'Read/Write';
                 team.Client_Access__c = 'No Access';
                 team.Client_Customer_Access__c ='No Access';
                 listCCT.add(team );
             }
         }

         return listCCT;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Account Team Members for the Account.
     */
     public static List<AccountTeamMember> createATMList(Account acc, List<User> listUser){
         List<AccountTeamMember> listATM = new List<AccountTeamMember>();
         for(User usr : listUser){
             AccountTeamMember atm = new AccountTeamMember();
             atm.AccountId = acc.Id;
             atm.UserId = usr.Id;
             listATM.add(atm);
         }
         return listATM;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Users.
     */
     public static List<User> createUserList(Integer count){
         Profile sysAdmin = [select id, name from Profile where name =: System.Label.BatchJob_Profile limit 1];
         List<User> listUser = new List<User>();
         Integer empId = 5555;
         for(Integer i=0; i<count; i++){
             User objUser = new User(LastName='Alex',Email='alexJohn121@test.com'+i,username='alexJohn121@test.com'+i,profileid=sysAdmin.id,FirstName='John');
             objUser.Alias='johnAlex';
             objUser.TimeZoneSidKey='America/Chicago';
             objUser.LocaleSidKey='en_US';
             objUser.EmailEncodingKey='UTF-8';
             objUser.LanguageLocaleKey='en_US';
             objUser.Acosta_Employee_Number__c =String.valueOf(empId)+'test';
             objUser.Title = 'test';
             listUser.add(objUser);
             empId++;
         }
         return listUser;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Account Team Members for the Client Customer Relationship records.
     */
     public static List<Client_Customer_Account_Team__c> createCCATM(Client_Customer_Relationship__c cc, List<AccountTeamMember> listATM, String source){
         List<Client_Customer_Account_Team__c> listCCATM = new List<Client_Customer_Account_Team__c>();
         for(AccountTeamMember atm : listATM){
             Client_Customer_Account_Team__c ccATM = new Client_Customer_Account_Team__c();
             ccATM.Client_Customer_Relationship__c = cc.Id;
             //ccATM.Role__C = atm.TeamMemberRole;
             ccATM.User__c = atm.UserId;
             ccATM.Source__c = source;
             listCCATM.add(ccATM);
         }
         return listCCATM;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Account Team Members for the Client Customer Relationship records.
     */
    public static List<Product__c> createProducts(List<Account> listAcc, Integer count){
        List<Product__c> listProducts = new List<Product__c>();
        for(Account acc :listAcc){
            for(Integer i=0;i<count;i++){
                Product__c pro = new Product__c();
                pro.Name = 'test';
                pro.Department__c = 'test';
                pro.Category__c = 'test';
                pro.Brand_Name__c = 'test';
                pro.Product_Group_Name__c ='test';
                pro.Status__c = 'Active';
                pro.New_Item__c = 'Yes';
                pro.Core_Flex__c = 'Core';
                pro.Unit_of_Measure__c = 'PN - Pounds Net';
                pro.Account__c = acc.Id;
                listProducts.add(pro);
            }
        }
        return listProducts;
    }

// Changed Relationship on the Product object to the Account object from a lookup to a Master-Detail
// As a result, the Product__Share object no longer exists and makes the following two Utility methods invalid
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Product Sharing records
     */
    /*
    public static List<Product__Share> createProductShareList(List<Product__c> listPro, List<AccountTeamMember> listATM){
        List<Product__Share> listPShare = new List<Product__Share>();
        for(Product__c pro : listPro){
            for(AccountTeamMember atm : listATM){
                Product__Share pShare = new Product__Share();
                pShare.ParentID = pro.Id;
                pShare.UserOrGroupId = atm.UserId;
                pShare.AccessLevel = 'READ';
                pShare.RowCause = Schema.Product__Share.RowCause.AccountTeam__c;
                listPShare.add(pShare);
            }
        }
        return listPShare;
    }
    */

    /**
     * @Description : Utility Method to create Product Sharing records
     */
    /*
    public static List<Product__Share> createProductShareList(List<Product__c> listPro, List<User> listUser){
        List<Product__Share> listPShare = new List<Product__Share>();
        for(Product__c pro : listPro){
            for(User user : listUser){
                Product__Share pShare = new Product__Share();
                pShare.ParentID = pro.Id;
                pShare.UserOrGroupId = user.Id;
                pShare.AccessLevel = 'READ';
                pShare.RowCause = Schema.Product__Share.RowCause.CustomerAccountTeam__c;
                listPShare.add(pShare);
            }
        }
        return listPShare;
    }
    */

     /**
     * @Description : Utility Method to create Client Cust Rel Sharing records
     */
    public static List<Client_Customer_Relationship__Share> createClientCustShareList(List<Client_Customer_Relationship__c> listClientCustRel, List<User> listUser){
        List<Client_Customer_Relationship__Share> listClientCustRelShare = new List<Client_Customer_Relationship__Share>();
        for(Client_Customer_Relationship__c pro : listClientCustRel){
            for(User user : listUser){
                Client_Customer_Relationship__Share clientCustRelShare = new Client_Customer_Relationship__Share ();
                clientCustRelShare.ParentID = pro.Id;
                clientCustRelShare.UserOrGroupId = user.Id;
                clientCustRelShare.AccessLevel = 'READ';
                listClientCustRelShare.add(clientCustRelShare );
            }
        }
        return listClientCustRelShare;
    }

    /**
     * @Description : Utility Method to create Account Sharing records
     */
    public static List<AccountShare> createaccountShareList(List<Account> listAcnt, List<User> listUser){
        List<AccountShare> listAcntShare = new List<AccountShare>();
        for(Account acnt : listAcnt){
            for(User user : listUser){
                AccountShare acntShare = new AccountShare();
                acntShare.AccountId= acnt.Id;
                acntShare.UserOrGroupId = user.Id;
                acntShare.AccountAccessLevel = 'READ';
                acntShare.OpportunityAccessLevel = 'None';
                acntShare.CaseAccessLevel = 'None';
                listAcntShare.add(acntShare );
            }
        }
        return listAcntShare;
    }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Client Customer Relationship records.
     */
     public static List<Client_Customer_Relationship__c> createListClientCust(List<Account> listClient, List<Account> listCust){
         List<Client_Customer_Relationship__c> listCC = new List<Client_Customer_Relationship__c>();
         for(Account accCust : listCust){
             for(Account accClient : listClient){
                 Client_Customer_Relationship__c rel = new Client_Customer_Relationship__c();
                 rel.Client__c = accClient.Id;
                 rel.Customer__c = accCust.Id;
                 listCC.add(rel);
             }
         }
         return listCC;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create National Strategy records.
     */
     public static List<National_Strategy__c> createNSList(List<Account> listClients){
         List<National_Strategy__c> listNS = new List<National_Strategy__c>();
         for(Account acc : listClients){
             National_Strategy__c ns = new National_Strategy__c();
             ns.Client__c = acc.Id;
             listNS.add(ns);
         }
         return listNS;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Strategy records.
     */
     public static List<Local_Strategy__c> createLSList(List<Client_Customer_Relationship__c> listCC, Map<Id,Id> mapClientIdNSIS){
         List<Local_Strategy__c> listLS = new List<Local_Strategy__c>();
         for(Client_Customer_Relationship__c cc : listCC){
             Local_Strategy__c ls = new Local_Strategy__c();
             ls.Client_Customer_Relationship__c = cc.Id;
             ls.National_Strategy__c = mapClientIdNSIS.get(cc.Client__c);
             listLS.add(ls);
         }
         return listLS;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create National Initiative records.
     */
     public static List<National_Initiative__c> createNIList(List<National_Strategy__c> listNS){
         List<National_Initiative__c> listNI = new List<National_Initiative__c>();
         for(National_Strategy__c ns : listNS){
             National_Initiative__c ni = new National_Initiative__c();
             ni.Strategy__c = ns.Id;
             listNI.add(ni);
         }
         return listNI;
     }
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Initiative records.
     */
     public static List<Local_Initiative__c> createLIList(List<Local_Strategy__c> listLS){
         List<Local_Initiative__c> listLI = new List<Local_Initiative__c>();
         for(Local_Strategy__c ls : listLS){
             Local_Initiative__c li = new Local_Initiative__c();
             li.Local_Strategy__c = ls.Id;
             listLI.add(li);
         }
         return listLI;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create National Banner Allocation records.
     */
     public static List<National_Banner_Allocation__c> createNBAList(List<National_Initiative__c> listNI){
         List<National_Banner_Allocation__c> listNBA = new List<National_Banner_Allocation__c>();
         for(National_Initiative__c ni : listNI){
             National_Banner_Allocation__c nba = new National_Banner_Allocation__c();
             nba.National_Initiative_Lookup__c  = ni.Id;
             listNBA.add(nba);
         }
         return listNBA;
     }


//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Banner Allocation records.
     */
     public static List<Local_Banner_Allocation__c> createLBAList(List<Local_Initiative__c> listLI){
         List<Local_Banner_Allocation__c> listLBA = new List<Local_Banner_Allocation__c>();
         for(Local_Initiative__c li : listLI){
             Local_Banner_Allocation__c lba = new Local_Banner_Allocation__c();
             lba.Local_Initiative__c = li.Id;
             listLBA.add(lba);
         }
         return listLBA;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create National Sub Banner Allocation records.
     */
     public static List<National_Sub_Banner_Allocation__c> createNSBAList(List<National_Banner_Allocation__c> listNBA){
         List<National_Sub_Banner_Allocation__c> listNSBA = new List<National_Sub_Banner_Allocation__c>();
         for(National_Banner_Allocation__c nba : listNBA){
             National_Sub_Banner_Allocation__c nsba = new National_Sub_Banner_Allocation__c();
             nsba.National_Banner_Allocation__c  = nba.Id;
             listNSBA.add(nsba);
         }
         return listNSBA;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Sub Banner Allocation records.
     */
     public static List<Local_Sub_Banner_Allocation__c> createLSBAList(List<Local_Banner_Allocation__c> listLBA){
         List<Local_Sub_Banner_Allocation__c> listLSBA = new List<Local_Sub_Banner_Allocation__c>();
         for(Local_Banner_Allocation__c lba : listLBA){
             Local_Sub_Banner_Allocation__c lsba = new Local_Sub_Banner_Allocation__c();
             lsba.Local_Banner_Allocation__c  = lba.Id;
             listLSBA.add(lsba);
         }
         return listLSBA;
     }

     //---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Sub Banner Allocation records.
     */
     public static National_Initiative__c  createNI(Id aId){
         National_Initiative__c  nationalInitiative = new National_Initiative__c();

         nationalInitiative.Initiatives__c = 'Forecast';
         nationalInitiative.Objectives__c = 'Volume';
        //conInitiative.nationalInitiative.Objectives__c = 'Shippers/Displays';
         nationalInitiative.Priority__c = 'High';
         nationalInitiative.Initiative_Start_Date__c  = system.Today();
         nationalInitiative.Initiative_End_Date__c = system.Today();
         nationalInitiative.Strategy__c = aId;
         return nationalInitiative;
     }
      //---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Local Sub Banner Allocation records.
     */
     public static Local_Initiative__c  createLI(Id aId){
         Local_Initiative__c  localInitiative = new Local_Initiative__c();

         localInitiative.Initiatives__c = 'Forecast';
         localInitiative.Objectives__c = 'Volume';
        //conInitiative.nationalInitiative.Objectives__c = 'Shippers/Displays';
         localInitiative.Priority__c = 'High';
         localInitiative.Initiative_Start_Date__c  = system.Today();
         localInitiative.Initiative_End_Date__c = system.Today();
         localInitiative.Local_Strategy__c = aId;
         return localInitiative;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to create Users.
     */
     public static List<User> createAdminUserList(Integer count){
         Profile sysAdmin = [select id, name from Profile where name = 'System Administrator' limit 1];
         List<User> listUser = new List<User>();
         Integer empId = 5555;
         for(Integer i=0; i<count; i++){
             User objUser = new User(LastName='Alex',Email='alexJohn121@test.com'+i,username='alexJohn121@test.com'+i,profileid=sysAdmin.id,FirstName='John');
             objUser.Alias='johnAlex';
             objUser.TimeZoneSidKey='America/Chicago';
             objUser.LocaleSidKey='en_US';
             objUser.EmailEncodingKey='UTF-8';
             objUser.LanguageLocaleKey='en_US';
             objUser.Acosta_Employee_Number__c =String.valueOf(empId) + 'test';
             objUser.Title = 'test';
             listUser.add(objUser);
             empId++;
         }
         return listUser;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to Initiative Plan.
     */
     public static Customer_Visit__c createInitiativePlan(){
         Customer_Visit__c initPlan = new Customer_Visit__c();
         initPlan.Name = 'Test Init Plan';
         initPlan.Start_Date__c = System.Today();
         initPlan.End_Date__c = System.Today() + 10;
         return initPlan;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to Initiative Plan Account Relationship.
     */
     public static List<Customer_Visit_Account_Relationship__c> createInitiativePlanAccRelList(Customer_Visit__c initPlan, List<Account> listAcc){
         List<Customer_Visit_Account_Relationship__c> listInitPlanAccRel = new List<Customer_Visit_Account_Relationship__c>();
         for(Account acc : listAcc){
             Customer_Visit_Account_Relationship__c cvar = new Customer_Visit_Account_Relationship__c();
             cvar.Account__c = acc.Id;
             cvar.Customer_Visit__c = initPlan.Id;
             listInitPlanAccRel.add(cvar);
         }
         return listInitPlanAccRel;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to Initiative Plan Initiative Relationship.
     */
     public static List<Customer_Visit_Initiative_Relationship__c> createInitiativePlanInitRelList(Customer_Visit__c initPlan, List<Local_Initiative__c> listLI, List<National_Initiative__c> listNI){
         List<Customer_Visit_Initiative_Relationship__c> listInitPlanInitRel = new List<Customer_Visit_Initiative_Relationship__c>();
         for(Local_Initiative__c li : listLI){
             Customer_Visit_Initiative_Relationship__c cvir = new Customer_Visit_Initiative_Relationship__c();
             cvir.Local_Initiative__c = li.Id;
             cvir.Customer_Visit__c = initPlan.Id;
             listInitPlanInitRel.add(cvir);
         }
         for(National_Initiative__c ni : listNI){
             Customer_Visit_Initiative_Relationship__c cvir = new Customer_Visit_Initiative_Relationship__c();
             cvir.National_Initiative__c = ni.Id;
             cvir.Customer_Visit__c = initPlan.Id;
             listInitPlanInitRel.add(cvir);
         }
         return listInitPlanInitRel;
     }

//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Description : Utility Method to Initiative Plan User Relationship.
     */
     public static List<Customer_Visit_User_Relationship__c> createInitiativePlanUserRelList(Customer_Visit__c initPlan, List<User> listUser){
         List<Customer_Visit_User_Relationship__c> listInitPlanUserRel = new List<Customer_Visit_User_Relationship__c>();
         for(User usr : listUser){
             Customer_Visit_User_Relationship__c cvur = new Customer_Visit_User_Relationship__c();
             cvur.User__c = usr.Id;
             cvur.Customer_Visit__c = initPlan.Id;
             listInitPlanUserRel.add(cvur);
         }
         return listInitPlanUserRel;
     }

}