/**
 * @description Apex controller to retrieve Case records related to the current complainant.
 * This controller is designed for use with LWC
 * @author Ozen Ece
 * @created 07/17/2025
 * @modified 07/17/2025
 * @modificationlog:
 *   Mod ID   Date        Mod Author   Brief Mod Description
 *   0001     07/17/2025  oecep@fdic.gov Initial code creation
 */

public without sharing class ComplainantCasesController {

    /**
     * @description Retrieve Case records related to the current complainant
     */
    @TestVisible private static String testShareQuery = null;
    @TestVisible private static String testCaseQuery = null;

    /**
     * @description Retrieves a list Case records where the user is listed as complainant in the related ComplainantParticipant junction object.
     * @annotations @AuraEnabled(cacheable=true) — allows method to be invoked from LWC and supports client-side caching.
     * @return caseList — list case records with selected fields Id, CaseNumber, Status
     */
    @AuraEnabled
    public static List<Case> getCasesForComplainant(){
        // Initialize the return list
        List<Case> caseList = new List<Case>();

        // Get the current user Id
        Id currentUserId = UserInfo.getUserId();

        // Retrieve the cases where user is complainant in the ComplainantParticipant junction object.
        caseList = fetchCasesforComplainant(currentUserId);

        // Share each case manually with the complainant
        manualCaseShare(caseList, currentUserId);

        return caseList;
    }

    /**
     * @description fetches Cases for Complainant
     * @param userId
     * @return caseList
     */
    private static List<Case> fetchCasesforComplainant(Id userId){
        List<Case> caseList = new List<Case>();
        try{
            if(Test.isRunningTest() && !String.isBlank(testCaseQuery)){
                caseList = (List<Case>)Database.query(testCaseQuery);
            } else{
                caseList = [SELECT Id, CaseNumber, Status 
                            FROM Case 
                            WHERE Id IN (SELECT Case__c 
                                         FROM ComplainantParticipant 
                                         WHERE Role = 'Complainant' 
                                         AND ParticipantId = :userId) 
                            WITH SYSTEM_MODE];
            }
        }catch(QueryException e){
            FDICUtil.processError(e,'ComplainantCasesController.fetchCasesforComplainant(userId)');
            throw new AuraHandledException('Metadata Query Error: ' + e.getMessage());
        }
        return caseList;
    }

    /**
     * @description gets already shared case Ids
     * @param userId
     * @return sharedCaseIds
     */
    private static Set<Id> getAlreadySharedCasesId(Id userId){
        Set<Id> sharedCaseIds = new Set<Id>();
        try{
            List<CaseShare> shareList;
            if(Test.isRunningTest() && !String.isBlank(testShareQuery)){
                shareList = (List<CaseShare>)Database.query(testShareQuery);
            } else{
                shareList = [SELECT CaseId 
                             FROM CaseShare 
                             WHERE UserOrGroupId = :userId 
                             AND RowCause = 'Manual' 
                             WITH USER_MODE];
            }
            for(CaseShare cs : shareList){
                sharedCaseIds.add(cs.CaseId);
            }
        }catch(QueryException e){
            FDICUtil.processError(e,'ComplainantCasesController.getAlreadySharedCasesId(userId)');
            throw new AuraHandledException('Metadata Query Error: ' + e.getMessage());
        }
        return sharedCaseIds;
    }

    /**
     * @description ensures manual case share
     * @param caseList
     * @param userId
     */
    private static void manualCaseShare(List<Case> caseList, Id userId){
        Set<Id> alreadySharedCaseIds = getAlreadySharedCasesId(userId);

        List<CaseShare> caseShares = new List<CaseShare>();
        for(Case c : caseList){
            if(!alreadySharedCaseIds.contains(c.Id)){
                CaseShare cs = new CaseShare();
                cs.CaseId = c.Id;
                cs.UserOrGroupId = userId;
                cs.CaseAccessLevel = 'Read';
                cs.RowCause = Schema.CaseShare.RowCause.Manual;
                caseShares.add(cs);
            }
        }

        if(!caseShares.isEmpty()){
            try{
                insert as system caseShares;
            }catch(DMLException e){
                FDICUtil.processError(e,'ComplainantCasesController.manualCaseShare(caseList, userId)');
            }
        }
    }
}
