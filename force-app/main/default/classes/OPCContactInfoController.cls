/******************************************************************************
 * @description Apex controller for managing Custom Metadata updates and retrievals for OPC Contact Information via LWC.
 * Implements Metadata.DeployCallback to handle asynchronous deployment callbacks.
 * @author Ozlem Ece
 * @created 05/12/2025
 * @modificationLog
 *******************************************************************************
 * Mod ID  | Date       | Mod Author | Brief Mod Description
 * --------|------------|------------|-------------------------
 * 0001    | 05/12/2025 | Ozlem Ece  | Initial code creation.
 *         |            |            | ocec@fdic.gov
 *******************************************************************************/

 public with sharing class OPCContactInfoController implements Metadata.DeployCallback {

    /**
     * @description Retrieves all OPC contact information custom metadata records.
     * @param contactType The picklist value for identifying the metadata record.
     * @return List of OPC_Contact_Information__mdt records.
     */
    
    /**
    @AuraEnabled(cacheable=true)
    public static List<OPC_Contact_Information__mdt> getMetadataRecords(String contactType){
        String conType = contactType.replaceAll(' ', '_');
        List<OPC_Contact_Information__mdt> records = new List<OPC_Contact_Information__mdt>();
        try {
            records = [SELECT Id, MasterLabel, DeveloperName, Type__c, Screen_Message__c, OPC_Email__c, OPC_Mailing_Address__c, OPC_Phone_Number__c 
                       FROM OPC_Contact_Information__mdt 
                       WHERE Type__c = :conType WITH USER_MODE];
        } catch(QueryException e){
            System.debug(e+ 'OPCContactInfoController.getMetadataRecords'); 
        }
        return records;
    }
    */

    @TestVisible
    private static Boolean simulateQueryFailure = false;

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserWithMetadata(String contactType) {
        if (simulateQueryFailure && Test.isRunningTest()) {
            // You can construct any subclass of QueryException; here we just throw the base
            throw new QueryException('Simulated user‐query failure');
        }

        Map<String, Object> result = new Map<String, Object>();
        
        String profileName = '';
        List<OPC_Contact_Information__mdt> records = new List<OPC_Contact_Information__mdt>();

        // Get user profile
        try {
            User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            profileName = currentUser.Profile.Name;
        } catch (QueryException e) {
            System.debug('Error fetching user profile: ' + e.getMessage());
            throw new AuraHandledException('exceptionText' + e.getMessage());
        }

        // Get metadata records
        try {
            String conType = contactType != null? contactType.replaceAll(' ', '_') : '';
            
            records = [SELECT Id, MasterLabel, DeveloperName, Type__c, Screen_Message__c, OPC_Email__c, OPC_Mailing_Address__c, OPC_Phone_Number__c
                FROM OPC_Contact_Information__mdt WHERE Type__c = :conType WITH USER_MODE];
        } catch (QueryException e) {
            System.debug('Error fetching metadata: ' + e.getMessage());
            throw new AuraHandledException('exceptionText'+e.getMessage());
        }

        result.put('userType', profileName);
        result.put('records', records);

        return result;
    }

    /**
     * @description Updates the custom metadata type record for the given contact type. Uses Metadata API deployment.
     * @param param
     */
    @AuraEnabled(cacheable=true)
    public static void updateMetadataContact(String param){
        String[] params = param.split('::');
        String conType = params[0];
        String screenMessage = params[1];
        String email = params[2];
        String phone = params[3];
        String address = params[4];
        OPC_Contact_Information__mdt data;

        try {
            conType = conType.replaceAll(' ', '_');
            data = OPCContactInfoController.getUserWithMetadata(conType)[0];

            // Initial setup for custom metadata
            Metadata.CustomMetadata cmdtMeta = new Metadata.CustomMetadata();
            cmdtMeta.fullName = 'OPC_Contact_Information__mdt.' + data.DeveloperName;
            cmdtMeta.label = data.MasterLabel;

            // Update Custom Values
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Screen_Message__c';
            customField.value = screenMessage;
            cmdtMeta.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'OPC_Email__c';
            customField.value = email;
            cmdtMeta.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'OPC_Phone_Number__c';
            customField.value = phone;
            cmdtMeta.values.add(customField);

            customField = new Metadata.CustomMetadataValue();
            customField.field = 'OPC_Mailing_Address__c';
            customField.value = address;
            cmdtMeta.values.add(customField);

            // Prepare deployment
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(cmdtMeta);
            OPCContactInfoController callback = new OPCContactInfoController();

            Id jobId = Test.isRunningTest() ? null :
                       Metadata.Operations.enqueueDeployment(mdContainer, callback);

        } catch(Exception e){
            System.debug(e.getMessage()+ 'OPCContactInfoController.updateMetadataContact');
        }
    }

    /**
     * @description Returns the UserType of the currently logged-in user. Used to conditionally show the content in LWC.
     * @return UserType string.
     */
    
     /*@AuraEnabled(cacheable=true)
    public static String getUserType(){
        String profileName = '';
        try {
            User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            profileName = currentUser.Profile.Name;
        } catch(QueryException e){
            System.debug(e+ 'OPCContactInfoController.getUserType');
        }
        return profileName;
    }
    */

    /**
     * @description Callback handler for Metadata deployment result.
     * @param result Metadata deployment result.
     * @param context Metadata deployment context.
     */
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if(result.status == Metadata.DeployStatus.Succeeded){
            System.debug('result: ' + result.status);
        } else {
            //System.debug('result: ' + result.status);
        }
    }

    
}


