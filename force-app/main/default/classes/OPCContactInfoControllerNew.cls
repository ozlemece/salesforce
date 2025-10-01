/*******************************************************************************************************
 * @description Apex controller for managing Custom Metadata updates and retrievals for OPC Contact Information via LWC.
 * Implements Metadata.Deployback to handle asynchronous deployment callbacks.
 *
 * @author Ozlem Ece
 * @date   05/12/2025
 * @modificationlog
 *
 * Mod ID   Date         Mod Author   Brief Mod Description
 * 0001     05/12/2025   Ozlem Ece    Initial code creation
 *                                   oece@fdic.gov
 *******************************************************************************************************/
public with sharing class OPCContactInfoControllerNew {

    @TestVisible
    private static Boolean simulateMetadataFailure = false;

    /**
     * @description Retrieves all OPC Contact Information custom metadata records and user types.
     * @param contactType the picklist value for identifying the metadata record.
     * @return result Map of OPC_Contact_Information__mdt records and user type.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMetadata(String contactType){
        Map<String, Object> result = new Map<String, Object>();
        String conType = '';
        List<OPC_Contact_Information__mdt> records = new List<OPC_Contact_Information__mdt>();

        try {
            if (simulateMetadataFailure && Test.isRunningTest()) {
                throw new QueryException('Simulated metadata failure');
            }

            conType = contactType.replaceAll(' ', '');
            records = [
                SELECT Id, MasterLabel, DeveloperName, Type__c, Screen_Message__c, 
                       OPC_Email__c, OPC_Mailing_Address__c, OPC_Phone_Number__c
                FROM OPC_Contact_Information__mdt
                WHERE Type__c = :conType
                WITH USER_MODE LIMIT 1
            ];

        } catch (QueryException qe) {
            FDICTUtil.processError(qe, 'OPCContactInfoController.getMetadata');
            throw new AuraHandledException('Metadata Query Error: ' + qe.getMessage());
        }

        result.put('records', records);
        return result;
    }
}
