public with sharing class DRRClaimsPortalController {
    @AuraEnabled
    public static string getNetworkDetails(){
        String networkName='';
        try {
            networkName=[Select name From Network Where id=:Network.getNetworkId()].name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }return networkName;
    }
    @AuraEnabled
    public static string loginSSOMRM(){
        String ssoUrl='';
        try {
            String networkName=getNetworkDetails();
            if(test.isRunningTest()){ networkName = 'mrm';}
            List<SAML_details_mdt> samlMapRecords=[
                Select id, Saml_Id_c, DeveloperName, Start_url__c, Community_Url__c 
                From SAML_details_mdt 
                ];

            Map<String, SAML_details_mdt> samlMap= new Map<String, SAML_details_mdt>();
                for(SAML_details_mdt saml:samlMapRecords){
                    samlMap.put(saml.developer_name__c, saml);
                }
                String startUrl=samlMap.get(networkName).Start_url__c;
                String communityUrl=samlMap.get(networkName).Community_Url__c;
                String samlId=samlMap.get(networkName).Saml_Id_c;

            ssoUrl=Auth.AuthConfiguration.getSamlSsoUrl(samlId, communityUrl, startUrl);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }return ssoUrl;
    }
    @AuraEnabled
    public static string loginSSOMRMAlternative() {
        String ssoUrl = '';
        try {
            String networkName = getNetworkDetails();
            if (Test.isRunningTest()) {networkName = 'mrm';}           
            // Query the records
            List<SAML_details_mdt> samlRecords = [
                SELECT Saml_Id_c, DeveloperName, Start_url__c, Community_Url__c
                FROM SAML_details_mdt
                WHERE DeveloperName = :networkName AND isActive__c = true
            ];  
            // Use the first record directly if the query returned results
            if (!samlRecords.isEmpty()) {
                SAML_details_mdt saml = samlRecords[0];
                String startUrl = saml.Start_url__c;
                String communityUrl = saml.Community_Url__c;
                String samlId = saml.Saml_Id_c;
    
                // Generate the SSO URL
                ssoUrl = Auth.AuthConfiguration.getSamlSsoUrl(samlId, communityUrl, startUrl);
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return ssoUrl;
    }
    
}