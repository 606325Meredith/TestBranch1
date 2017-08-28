@isTest
private class DepartmentTriggerTest {

	@isTest(SeeAllData=true)
	static void validateDepartmentInsert() {
		List<RecordType> l4AndL5RecordTypes = [SELECT id, name FROM RecordType WHERE name = 'Customer - Sub Banner - L5' OR name =  'Customer - Banner - L4' LIMIT 1];
		Set<Id> recordTypeIds = (new Map<Id, RecordType>(l4AndL5RecordTypes)).keySet();
		Account testAccount = [SELECT id, name, Account_External_ID__c FROM Account WHERE recordTypeId IN: recordTypeIds LIMIT 1];		
		Department__c department = new Department__c(Acosta_External_ID__c = testAccount.Account_External_Id__c, Department_Status__c='valid');
		Database.insert(department);
		department = [SELECT bannerAccountId__r.name FROM Department__c WHERE id =: department.id];
		System.assertEquals(department.bannerAccountId__r.name, testAccount.name);
	}

	@isTest(SeeAllData=true)
	static void validateDepartmentUpdate() {
		List<RecordType> l4AndL5RecordTypes = [SELECT id, name FROM RecordType WHERE name = 'Customer - Sub Banner - L5' OR name =  'Customer - Banner - L4' LIMIT 1];
		Set<Id> recordTypeIds = (new Map<Id, RecordType>(l4AndL5RecordTypes)).keySet();
		Account testAccount = [SELECT id, name, Account_External_ID__c FROM Account WHERE recordTypeId IN: recordTypeIds LIMIT 1];	
		Department__c department = [SELECT id FROM Department__c LIMIT 1];
		department.Acosta_External_ID__c = testAccount.Account_External_Id__c;
		Database.update(department);
		department = [SELECT bannerAccountId__r.name FROM Department__c WHERE id =: department.id];
		System.assertEquals(department.bannerAccountId__r.name, testAccount.name);
	}

}