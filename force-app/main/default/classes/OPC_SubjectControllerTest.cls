/**
 * @description Test class for OPC_SubjectController
 * Provides comprehensive test coverage for all controller methods
 * @author Salesforce Developer
 * @date 2024
 * @version 1.0
 */
@isTest
public class OPC_SubjectControllerTest {
    
    // Test data constants
    private static final String TEST_CASE_SUBJECT = 'Test Case for Subject Controller';
    private static final String TEST_CASE_STATUS = 'New';
    private static final String TEST_CASE_ORIGIN = 'Web';
    private static final String TEST_SUBJECT_NAME_PREFIX = 'Test Subject ';
    private static final Integer TEST_SUBJECT_COUNT = 5;
    
    /**
     * @description Setup test data for all test methods
     * Creates test case and related subjects with comprehensive field data
     */
    @TestSetup
    static void setupTestData() {
        // Create test case
        Case testCase = new Case(
            Subject = TEST_CASE_SUBJECT,
            Status = TEST_CASE_STATUS,
            Origin = TEST_CASE_ORIGIN
        );
        insert testCase;
        
        // Create test subjects with comprehensive data
        List<Subject__c> testSubjects = new List<Subject__c>();
        for (Integer i = 1; i <= TEST_SUBJECT_COUNT; i++) {
            Subject__c testSubject = new Subject__c(
                Name = TEST_SUBJECT_NAME_PREFIX + i,
                Case__c = testCase.Id
            );
            testSubjects.add(testSubject);
        }
        insert testSubjects;
    }
    
    /**
     * @description Test getSubjects method with valid case ID
     * Verifies correct retrieval and ordering of subjects
     */
    @isTest
    static void testGetSubjects_ValidCaseId() {
        // Get test case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        List<Subject__c> subjects = OPC_SubjectController.getSubjects(testCase.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(TEST_SUBJECT_COUNT, subjects.size(), 'Should return correct number of subjects');
        System.assertEquals(TEST_SUBJECT_NAME_PREFIX + '1', subjects[0].Name, 'First subject name should match');
        System.assertEquals(testCase.Id, subjects[0].Case__c, 'Case ID should match');
        
        // Verify all subjects belong to the correct case
        for (Subject__c subject : subjects) {
            System.assertEquals(testCase.Id, subject.Case__c, 'All subjects should belong to the test case');
        }
    }
    
    /**
     * @description Test getSubjects method with null case ID
     */
    @isTest
    static void testGetSubjects_NullCaseId() {
        Test.startTest();
        List<Subject__c> subjects = OPC_SubjectController.getSubjects(null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(0, subjects.size(), 'Should return empty list for null case ID');
    }
    
    /**
     * @description Test getSubjectById method with valid subject ID
     */
    @isTest
    static void testGetSubjectById_ValidId() {
        // Get test subject
        Subject__c testSubject = [SELECT Id FROM Subject__c LIMIT 1];
        
        Test.startTest();
        Subject__c subject = OPC_SubjectController.getSubjectById(testSubject.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, subject, 'Subject should not be null');
        System.assertEquals(testSubject.Id, subject.Id, 'Subject ID should match');
    }
    
    /**
     * @description Test getSubjectById method with null ID
     */
    @isTest
    static void testGetSubjectById_NullId() {
        Test.startTest();
        try {
            OPC_SubjectController.getSubjectById(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Subject ID is required', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getSubjectById method with invalid ID
     */
    @isTest
    static void testGetSubjectById_InvalidId() {
        Test.startTest();
        try {
            OPC_SubjectController.getSubjectById('001000000000000AAA');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Subject not found', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test createSubject method with valid data
     */
    @isTest
    static void testCreateSubject_ValidData() {
        // Get test case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Prepare subject data
        Map<String, Object> subjectData = new Map<String, Object>{
            'Case__c' => testCase.Id,
            'Name' => 'New Test Subject'
        };
        
        Test.startTest();
        Id subjectId = OPC_SubjectController.createSubject(subjectData);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, subjectId, 'Subject ID should not be null');
        
        // Verify the subject was created
        Subject__c createdSubject = [SELECT Id, Name, Case__c FROM Subject__c WHERE Id = :subjectId];
        System.assertEquals('New Test Subject', createdSubject.Name, 'Subject name should match');
        System.assertEquals(testCase.Id, createdSubject.Case__c, 'Case ID should match');
    }
    
    /**
     * @description Test createSubject method with null data
     */
    @isTest
    static void testCreateSubject_NullData() {
        Test.startTest();
        try {
            OPC_SubjectController.createSubject(null);
            System.assert(false, 'Should have thrown an exception for null data');
        } catch (AuraHandledException e) {
            System.assertEquals('Subject data is required', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test createSubject method with empty data
     */
    @isTest
    static void testCreateSubject_EmptyData() {
        Test.startTest();
        try {
            OPC_SubjectController.createSubject(new Map<String, Object>());
            System.assert(false, 'Should have thrown an exception for empty data');
        } catch (AuraHandledException e) {
            System.assertEquals('Case ID is required', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateSubject method with valid data
     */
    @isTest
    static void testUpdateSubject_ValidData() {
        // Get test subject
        Subject__c testSubject = [SELECT Id FROM Subject__c LIMIT 1];
        
        // Prepare update data
        Map<String, Object> updateData = new Map<String, Object>{
            'Name' => 'Updated Test Subject'
        };
        
        Test.startTest();
        Boolean result = OPC_SubjectController.updateSubject(testSubject.Id, updateData);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result, 'Update should return true');
        
        // Verify the subject was updated
        Subject__c updatedSubject = [SELECT Id, Name FROM Subject__c WHERE Id = :testSubject.Id];
        System.assertEquals('Updated Test Subject', updatedSubject.Name, 'Subject name should be updated');
    }
    
    /**
     * @description Test updateSubject method with null ID
     */
    @isTest
    static void testUpdateSubject_NullId() {
        Map<String, Object> updateData = new Map<String, Object>{
            'Name' => 'Updated Test Subject'
        };
        
        Test.startTest();
        try {
            OPC_SubjectController.updateSubject(null, updateData);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Subject ID is required', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test deleteSubject method with valid ID
     */
    @isTest
    static void testDeleteSubject_ValidId() {
        // Get test subject
        Subject__c testSubject = [SELECT Id FROM Subject__c LIMIT 1];
        
        Test.startTest();
        Boolean result = OPC_SubjectController.deleteSubject(testSubject.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result, 'Delete should return true');
        
        // Verify the subject was deleted
        List<Subject__c> remainingSubjects = [SELECT Id FROM Subject__c WHERE Id = :testSubject.Id];
        System.assertEquals(0, remainingSubjects.size(), 'Subject should be deleted');
    }
    
    /**
     * @description Test deleteSubject method with null ID
     */
    @isTest
    static void testDeleteSubject_NullId() {
        Test.startTest();
        try {
            OPC_SubjectController.deleteSubject(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Subject ID is required', e.getMessage(), 'Error message should match');
        }
        Test.stopTest();
    }
}