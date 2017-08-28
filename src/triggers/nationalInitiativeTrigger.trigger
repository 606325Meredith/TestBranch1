trigger nationalInitiativeTrigger on National_Initiative__c (after update ) {

      nationalInitiativeTriggerHelper.updateNBAandNSBA(Trigger.newMap);
        
  }