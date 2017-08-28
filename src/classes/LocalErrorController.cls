public without sharing class LocalErrorController
{
    public string ErrorText{get;set;}
    private string CCRelID ;
    private string localStrategyID;
    private string localInitiativeID;
    public LocalErrorController()
    {
        CCRelID = ApexPages.currentPage().getParameters().get('CCRelId');      
        localStrategyID = ApexPages.currentPage().getParameters().get('strategyID');
        localInitiativeID = ApexPages.currentPage().getParameters().get('id');
    }
    public PageReference Checkpermissions()
    {
        integer i = 0;
        integer j = 0;
        PageReference pRef;
        List<AggregateResult> listRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Create_Ability_On_Local_Strategy']);
        List<Local_Strategy__c> listLS = new List<Local_Strategy__c>([select id,Client_Customer_Relationship__r.Status__c from Local_Strategy__c where id=:localStrategyID and Client_Customer_Relationship__r.Status__c = 'Active']);
        List<Local_Initiative__c> listLI = new List<Local_Initiative__c>([select id,Local_Strategy__r.Client_Customer_Relationship__r.Status__c from Local_Initiative__c where id=:localInitiativeID and Local_Strategy__r.Client_Customer_Relationship__r.Status__c = 'Active']);
        List<Client_Customer_Relationship__c> listCCRel = new List<Client_Customer_Relationship__c>([select id from Client_Customer_Relationship__c where id=:CCRelID and Status__c = 'Active']);
        if(listRes!= null && listRes.size()>0)
        {
            i =(Integer) listRes[0].get('counts');
            if((listCCRel !=null && listCCRel.size()>0) || (listLS !=null && listLS.size()>0) || (listLI!=null && listLI.size()>0 ))
            {
                j = 0;
            }
            else
            {
                j = 1;
            }
            if(i > 0 && j == 0)
            {  
                if(string.isnotBlank(CCRelId))
                    pRef = new pageReference('/apex/LocalStrategyHeader?CCRelID='+ CCRelId);
                else if(string.isnotBlank(localstrategyID))
                    pRef = new pageReference('/apex/LocalStrategyItem?strategyID='+ localStrategyID);
                else if(string.isnotBlank(localInitiativeID ))
                    pRef = new pageReference('/apex/LocalStrategyItem?id='+ localInitiativeID);
                pref.setRedirect(true);
                return pref;
            } 
            else if(i == 0 && j == 0)
            {
                ErrorText = 'You do not have permissions to create Local Strategy or Local Initiative';                 
            }  
            else if(j == 1)
            {
                ErrorText = 'You do not have permissions to create Local Strategy or Local Initiative on inactive Client Customer Relationship record';                 
            }      
        }
        return null;
        
    }
}