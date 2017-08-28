trigger AssociateDepartmentsToCustomerAccounts on Department__c (before insert, before update) {
	List<RecordType> l4AndL5RecordTypes = [SELECT id, name FROM RecordType WHERE name = 'Customer - Sub Banner - L5' OR name =  'Customer - Banner - L4' LIMIT 2];
	Set<Id> recordTypeIds = (new Map<Id, RecordType>(l4AndL5RecordTypes)).keySet();
	List<Account> l4AndL5CustomerAccounts = [SELECT id, Account_External_ID__c, name FROM Account WHERE recordTypeId IN: recordTypeIds LIMIT 50000];
	Map<Id,Account> idToAccountName = new Map<Id,Account>(l4AndL5CustomerAccounts);
	Map<String, Id> externalToInternalIdMap = new Map<String, Id>();
	for(Account acct: l4AndL5CustomerAccounts) {externalToInternalIdMap.put(acct.Account_External_Id__c, acct.id);}
	for(Department__c dept : Trigger.new) {
		if(dept.Acosta_External_ID__c != null) {
			if(externalToInternalIdMap.get(dept.Acosta_External_ID__c) != null) {
				dept.bannerAccountId__c = externalToInternalIdMap.get(dept.Acosta_External_ID__c);
				dept.fullDepartmentName__c = dept.name + ' - ' + idToAccountName.get(externalToInternalIdMap.get(dept.Acosta_External_ID__c)).name;
			}
		}
	}
}