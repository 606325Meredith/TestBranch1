trigger initiativeDispositionEventTrigger on Event (after update ) {

        
        initiativeDispositionEventTriggerHelper updateID = new initiativeDispositionEventTriggerHelper();
        updateID.associateInitiativeDispositionFromEvent(Trigger.new);
               
        
  }