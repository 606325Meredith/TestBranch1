trigger localInitiativeTrigger on Local_Initiative__c (after update ) {

      localInitiativeTriggerHelper.updateLBAandLSBA(Trigger.newMap);
        
  }