/**************************************************************************************
Apex Class Name:  initiativeDispositionEventTriggerHelper
Version     : 1.0 
Created Date    : 9 Sept 2016
Description    :  Whenever an Event is updated with Customer Name (Account lookup) and Initiative Disposition, 
                  the values from Customer are copied from Event onto the assoicated Initiatve Disposition record by this class

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raj Balla        9 Sept 2016              Original Version
*************************************************************************************/





public class initiativeDispositionEventTriggerHelper {


   public void associateInitiativeDispositionFromEvent(List<Event> lstEvent)
       
   {
      List<Event> eventList  = new List<Event>(); 
      List<Customer_Visit_Execution__c> iDtoUpdateList = new List<Customer_Visit_Execution__c>(); 
      Map<Id,Event> initiativeEventMap = new Map<Id,Event>();    
      
     
      
      for(Event eve : lstEvent)
       {
                        
           if(eve.Initiative_Disposition__c != NULL && eve.Customer_Name__c != NULL )
            {
                  initiativeEventMap.put(eve.Initiative_Disposition__c, eve);          
            }
       }
       
              
         if(initiativeEventMap.values().size() > 0)
             {
         //Query the Initiative Disposition records that are to be updated     
              
                       for(Event eve : eventList)
                         {
                           initiativeEventMap.put(eve.Initiative_Disposition__c,eve);
                         }
                         system.debug('**initiativeEventMap - '+initiativeEventMap);
                         
                       iDtoUpdateList = [Select id, Customer_Name__c, Customer_MDM_ID__c, Customer_Level__c, Customer_Country__c, Distributor_NARS_ID__c 
                                                                                                                                      from Customer_Visit_Execution__c             
                                                                                                                                          where id in : initiativeEventMap.keyset()];
                 
                                
                                  if(iDtoUpdateList.size() > 0)    
                                  {
                            
                                // Update the list
                                for(Customer_Visit_Execution__c cvRec : iDtoUpdateList)
                                  {
                                       cvRec.Customer_Name__c = initiativeEventMap.get(cvRec.Id).Customer_Name_Text__c;
                                       cvRec.Customer_MDM_ID__c = initiativeEventMap.get(cvRec.Id).Customer_MDM_ID__c;
                                       cvRec.Customer_Level__c = initiativeEventMap.get(cvRec.Id).Customer_Level__c;
                                       cvRec.Customer_Country__c = initiativeEventMap.get(cvRec.Id).Customer_Country__c;
                                       cvRec.Distributor_NARS_ID__c = initiativeEventMap.get(cvRec.Id).Distributor_NARS_ID__c;
                                      
                                  }
                                  
                        
                             //Once the list is ready, update it back        
                                 try
                                        {
                                         update iDtoUpdateList;
                                        }
                        
                                     catch (Exception e)
                                     {} 
             
         }    
    }


  }

}