/*****************************************************************************************
Class Name: AccountTriggerTest
Purpose: Test class for account trigger
******************************************************************************************
Version         DateModified         ModifiedBy              	 			Change
1.0             12/04/2017           Rakesh Ramaswamy (PwC)               Initial Development.
1.1				19/04/2017			 Rakesh Ramaswamy (PwC) 			  System assert checks.
******************************************************************************************/
@isTest(seeAllData = false)
private class AccountTriggerTest
 {
    static testMethod void changeAccountOwner()
     {
        //creating client account
        list<Account> listClientAcc = UtilityClassForTestDataSetUp.CreateAccountList('Client - Channel - L3', 51);   
        insert listClientAcc;
        
        //creating user
        list<User> listUser = UtilityClassForTestDataSetUp.createUserList(5);
        insert listUser;
        
        //creating account share
        list<AccountShare> listClientShare = UtilityClassForTestDataSetUp.createaccountShareList(listClientAcc, listUser);   
        insert listClientShare; 
        
        //updating owner to ensure sharing records are retained in the system.
        try
         {
            Account acc = new Account();
            acc.id = listClientAcc[0].ID;
            acc.OwnerID = listUser[3].ID;
            update acc;
         }
        catch(exception ex)
         {
            System.debug(ex.getMessage());
         }
        
        // Assert check to determine whether no. of users is equal to the no. of share records for Account object.
        system.AssertEquals(listUser.size(),AcostaConstants.lstAccountShareToInsert.size());
    }
}