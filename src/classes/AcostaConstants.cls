/*
* AcostaConstants
* @description      : Constants class for Acosta Project. All String literal constants are captured in this class. This is an Application Constant class.
					  Changes connected with revamp of ClientCustomerATMProcess also has some new literals in place within this constants class.
					  
* @author           : Rakesh Ramaswamy
* @createddate      : May 30, 2016
* @lastmodified     : April 21, 2017
* @last modified by :   
*/
public class AcostaConstants { 
    //Static Constants
    public static final Map<String,String> mapAccessLevel = new Map<String,String>{'Read' => 'Read', 'Edit' => 'Read/Write'}; 
    public static final Map<String,String> mapAccessLevelShare = new Map<String,String>{'Read' => 'Read', 'Read/Write' => 'Edit'};  
    public static final String batchJobStatusTest = 'Completed'; 
    public static final String readAccess ='Read';
    public static final String readWriteAccess ='Read/Write';
    public static final String readWriteAccessAPI ='Edit';
    public static final String noAccess ='No Access';
    public static final String allAccess ='All';
    public static final String L3ClientType = 'Client - Channel - L3';
    public static final String L4ClientType = 'Client - BU - L4';
    public static final String L4CustomerType =  'Customer - Banner - L4';
    public static final String L5CustomerType = 'Customer - Sub Banner - L5';
    public static final String sourceClient = 'Client';
    public static final String sourceCustomer = 'Customer';    
    public static final String sourceCC = 'Client-Customer';     
    public static final String InsDML= 'Ins';
    public static final String UpdDML= 'Upd';
    public static final String DelDML= 'Del';
    public static final String eventCategoryType = 'Category';
    public static final String eventClientType = 'Client Event'; 
    public static final String eventCustomerType = 'Customer Event';
    public static final String eventInitPlanType = 'Initiative Planning Event';
    public static final Map<Id,RecordType> accountRecTypes = new Map<Id,RecordType>([Select SobjectType, Name, Id From RecordType where SobjectType='Account' AND IsActive = true]);
    public static final String StatusAllocated = 'Allocated';
    public static final String StatusUnAllocated = 'Unallocated';
    public static final String StatusNew = 'New';
    public static final String StatusIPDraft = 'In-Draft';
    public static final String StatusIPSubmitted = 'Submitted';
    public static final Map<Id,RecordType> initiativePlanRecTypes = new Map<Id,RecordType>([Select SobjectType, Name, Id From RecordType where SobjectType='Customer_Visit__c' AND IsActive = true]);
    public static final Map<Id,RecordType> eventRecTypes = new Map<Id,RecordType>([Select SobjectType, Name, Id From RecordType where SobjectType='Event' AND IsActive = true]);
    public static final String custBannerLevelLabel = 'Banner';
    public static final String custBannerLevelvalue = 'Customer Banner';
    public static final String custSBannerLevelLabel = 'Sub-Banner';
    public static final String custSBannerLevelvalue = 'Customer Sub-Banner';   
    public static final String clntChannelLevel = 'Client Channel';
    public static final String clntBULevel = 'Client Business Unit';
    public static final String custypeDistributer = 'Distributor';
    // A map collection that captures the no. of CCAT records tagged to a user for a client or customer account across CCR records in HQ Sales System.
    // This collection captures possibilities of CCAT records existing for a user across CCR(s) to help determine the appropriate access to be finally set based on access updates done via CCAT for that user.
    public static map<String, list<Client_Customer_Account_Team__c>> dupCCATsFromCustClientMap = new map<String, list<Client_Customer_Account_Team__c>>();
    // Static Application level constant that captures the Account Share records. This collection is used in the Account Trigger and Handler, which is responsible for retaining
    // share records of Account records, whenever Account records are updated in the system.
    public static list<AccountShare> lstAccountShareToInsert = new list<AccountShare>();
    // Static Application level constant that captures the CCR Share records. This collection is used in the CCR Trigger and Handler, which is responsible for retaining
    // share records of CCR records, whenever CCR records are updated in the system.
    public static list<Client_Customer_Relationship__Share> lstCCRShareToInsert = new list<Client_Customer_Relationship__Share >();  
    // The following boolean variables are used in the Account Trigger, when accounts are undergoing ownership changes.
    public static boolean accountBeforeUpdateExecuted = false;
    public static boolean accountAfterUpdateExecuted = false;
    // The following boolean variables are used in the CCR Trigger, when CCR records are updated w.r.t ownerships.
    public static boolean CCRBeforeUpdateExecuted = false;
    public static boolean CCRAfterUpdateExecuted = false;    
    
    public static Id getRecordTypeId(String recTypeName){
        for(Id id : accountRecTypes.keySet()){
            if(String.isNotBlank(recTypeName) && accountRecTypes.get(id).Name.equals(recTypeName)){
                return id;    
            }        
        }  
        return null;  
    }
    
    public static Id getIPRecordTypeId(String recTypeName){
        for(Id id : initiativePlanRecTypes.keySet()){
            if(String.isNotBlank(recTypeName) && initiativePlanRecTypes.get(id).Name.equals(recTypeName)){
                return id;    
            }        
        }  
        return null;  
    }
    
    public static Id getEventRecordTypeId(String recTypeName){
        for(Id id : eventRecTypes.keySet()){
            if(String.isNotBlank(recTypeName) && eventRecTypes.get(id).Name.equals(recTypeName)){
                return id;    
            }        
        }  
        return null;  
    }        
    
    public static String GetAppSettingValue(String Key, String DefaultValue) 
    { 
        String AppSettingValue = DefaultValue;
        Map<String, Application_Settings__c> mapApplicationSettings = Application_Settings__c.getAll();
        Application_Settings__c oApplicationSettings;
        if (mapApplicationSettings.size() > 0 && mapApplicationSettings.containsKey(Key))
        {
            oApplicationSettings = mapApplicationSettings.get(Key);
            AppSettingValue = oApplicationSettings.Value__c; 
        } 
        return AppSettingValue;   
     } 
     
//---------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc : Method to log the Custom Exception
     */  
     public static void logCustomException(String className, String methodName, String errorDesc, Integer lineNumber){
         Custom_Exception__c ex = new Custom_Exception__c();
         ex.Class_Name__c = className;
         ex.Method_Name__c = methodName;
         ex.Error_Description__c = errorDesc;
         ex.Error_Line_Number__c = lineNumber;
         Insert ex;
     }   
     
     public static List<selectOption> getPickValues(String object_name, String field_name, String first_val) {
         List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
         if (first_val != null) { //if there is a first value being provided
             options.add(new selectOption(first_val, first_val)); //add the first option
         }
         Schema.sObjectType sobject_type = Schema.getGlobalDescribe().get(object_name); //grab the sobject that was passed
         Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
         Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
         List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
         for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list                 
             options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
         }
         return options; //return the List     
     }  
    
}