/**
 * @description Controller class for Subject__c object operations
 * Provides CRUD operations and data retrieval for Subject records
 * @author Salesforce Developer
 * @date 2024
 * @version 1.0
 */
public with sharing class OPC_SubjectController {
    
    // Constants for better maintainability
    private static final String ERROR_RETRIEVING_SUBJECTS = 'Error retrieving subjects: ';
    private static final String ERROR_RETRIEVING_SUBJECT = 'Error retrieving subject: ';
    private static final String ERROR_CREATING_SUBJECT = 'Error creating subject: ';
    private static final String ERROR_UPDATING_SUBJECT = 'Error updating subject: ';
    private static final String ERROR_DELETING_SUBJECT = 'Error deleting subject: ';
    private static final String SUBJECT_ID_REQUIRED = 'Subject ID is required';
    private static final String SUBJECT_NOT_FOUND = 'Subject not found';
    
    /**
     * @description Retrieves subjects related to a specific case
     * @param caseId The ID of the case to get subjects for
     * @return List of Subject__c records with related data
     * @throws AuraHandledException if an error occurs during retrieval
     */
    @AuraEnabled(cacheable=true)
    public static List<Subject__c> getSubjects(Id caseId) {
        try {
            if (caseId == null) {
                return new List<Subject__c>();
            }
            
            // Validate caseId format
            if (!String.valueOf(caseId).startsWith('500')) {
                throw new AuraHandledException('Invalid Case ID format');
            }
            
            // Query subjects related to the case with standard fields only
            List<Subject__c> subjects = [
                SELECT Id, Name, Case__c, CreatedDate, LastModifiedDate
                FROM Subject__c 
                WHERE Case__c = :caseId
                ORDER BY CreatedDate DESC
                LIMIT 1000
            ];
            
            return subjects;
            
        } catch (QueryException e) {
            throw new AuraHandledException(ERROR_RETRIEVING_SUBJECTS + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_RETRIEVING_SUBJECTS + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves a single subject by ID
     * @param subjectId The ID of the subject to retrieve
     * @return Subject__c record
     * @throws AuraHandledException if subjectId is null or subject not found
     */
    @AuraEnabled(cacheable=true)
    public static Subject__c getSubjectById(Id subjectId) {
        try {
            if (subjectId == null) {
                throw new AuraHandledException(SUBJECT_ID_REQUIRED);
            }
            
            // Validate subjectId format
            if (!String.valueOf(subjectId).startsWith('a0')) {
                throw new AuraHandledException('Invalid Subject ID format');
            }
            
            List<Subject__c> subjects = [
                SELECT Id, Name, Case__c, CreatedDate, LastModifiedDate
                FROM Subject__c 
                WHERE Id = :subjectId
                LIMIT 1
            ];
            
            if (subjects.isEmpty()) {
                throw new AuraHandledException(SUBJECT_NOT_FOUND);
            }
            
            return subjects[0];
            
        } catch (QueryException e) {
            throw new AuraHandledException(ERROR_RETRIEVING_SUBJECT + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_RETRIEVING_SUBJECT + e.getMessage());
        }
    }
    
    /**
     * @description Creates a new subject record
     * @param subjectData Map containing subject field values
     * @return Id of the created subject record
     * @throws AuraHandledException if required fields are missing or creation fails
     */
    @AuraEnabled
    public static Id createSubject(Map<String, Object> subjectData) {
        try {
            if (subjectData == null || subjectData.isEmpty()) {
                throw new AuraHandledException('Subject data is required');
            }
            
            Subject__c newSubject = new Subject__c();
            
            // Validate and set required fields
            if (subjectData.containsKey('Case__c') && subjectData.get('Case__c') != null) {
                Id caseId = (Id) subjectData.get('Case__c');
                if (!String.valueOf(caseId).startsWith('500')) {
                    throw new AuraHandledException('Invalid Case ID format');
                }
                newSubject.Case__c = caseId;
            } else {
                throw new AuraHandledException('Case ID is required');
            }
            
            // Set optional fields with validation
            if (subjectData.containsKey('Name') && subjectData.get('Name') != null) {
                String name = (String) subjectData.get('Name');
                if (name.length() > 255) {
                    throw new AuraHandledException('Name cannot exceed 255 characters');
                }
                newSubject.Name = name;
            }
            
            insert newSubject;
            return newSubject.Id;
            
        } catch (DmlException e) {
            throw new AuraHandledException(ERROR_CREATING_SUBJECT + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_CREATING_SUBJECT + e.getMessage());
        }
    }
    
    /**
     * @description Updates an existing subject record
     * @param subjectId The ID of the subject to update
     * @param subjectData Map containing updated field values
     * @return Boolean indicating success
     */
    @AuraEnabled
    public static Boolean updateSubject(Id subjectId, Map<String, Object> subjectData) {
        try {
            if (subjectId == null) {
                throw new AuraHandledException(SUBJECT_ID_REQUIRED);
            }
            
            Subject__c subjectToUpdate = new Subject__c(Id = subjectId);
            
            // Update fields from the provided data
            if (subjectData.containsKey('Name')) {
                subjectToUpdate.Name = (String) subjectData.get('Name');
            }
            
            update subjectToUpdate;
            return true;
            
        } catch (DmlException e) {
            throw new AuraHandledException(ERROR_UPDATING_SUBJECT + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_UPDATING_SUBJECT + e.getMessage());
        }
    }
    
    /**
     * @description Deletes a subject record
     * @param subjectId The ID of the subject to delete
     * @return Boolean indicating success
     */
    @AuraEnabled
    public static Boolean deleteSubject(Id subjectId) {
        try {
            if (subjectId == null) {
                throw new AuraHandledException(SUBJECT_ID_REQUIRED);
            }
            
            Subject__c subjectToDelete = new Subject__c(Id = subjectId);
            delete subjectToDelete;
            return true;
            
        } catch (DmlException e) {
            throw new AuraHandledException(ERROR_DELETING_SUBJECT + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_DELETING_SUBJECT + e.getMessage());
        }
    }
}