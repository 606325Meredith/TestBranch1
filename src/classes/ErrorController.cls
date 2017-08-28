public without sharing class ErrorController
{
    public string ErrorText{get;set;}
    private string clientID ;
    private string nationalStrategyID;
    private string NationalInitiativeID;

    public ErrorController() {
        clientID = ApexPages.currentPage().getParameters().get('ClientId');      
        nationalStrategyID = ApexPages.currentPage().getParameters().get('strategyID');
        NationalInitiativeID = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference Checkpermissions() {
        integer i = 0;
        PageReference pRef;
        List<AggregateResult> listRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Create_Ability_On_National_Strategy']);
        if(listRes!= null && listRes.size()>0)
        {
            i = (Integer) listRes[0].get('counts');
            system.debug('listRes count --->' + i);
            if(i > 0)
            {  
                if(string.isnotBlank(clientID))
                    pRef = new pageReference('/apex/NationalStrategyHeader?clientId='+ clientID);
                else if(string.isnotBlank(nationalStrategyID))
                    pRef = new pageReference('/apex/NationalStrategyItem?strategyID='+ nationalStrategyID);
                else if(string.isnotBlank(NationalInitiativeID))
                    pRef = new pageReference('/apex/NationalStrategyItem?id='+ NationalInitiativeID);
                pref.setRedirect(true);
                return pref;
            } 
            else if(i == 0)
            {
                ErrorText = 'You do not have permission to create a National Strategy or National Initiative';
            }        
        }
        return null;
    }

    public PageReference CheckASOpermissions() {
        integer i = 0;
        PageReference pRef;
        List<AggregateResult> asoListRes = new List<AggregateResult>([SELECT count(Id) counts FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'ASO_NBA_Access']);
        if(asoListRes!= null && asoListRes.size()>0)
        {
            i = (Integer) asoListRes[0].get('counts');
            system.debug('asoListRes count --->' + i);
            if(i > 0)
            {
                if(string.isnotBlank(NationalInitiativeID))
                    pRef = new pageReference('/apex/BannerUI1?initiativeId='+NationalInitiativeID+'&type=SBA');
                pref.setRedirect(true);
                return pref;
            }
            else if(i == 0)
            {
                ErrorText = 'You do not have the proper access to allocate NBA records down to the National Sub-Banner level';
            }
        }
        return null;
    }
}