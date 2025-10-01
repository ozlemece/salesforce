/**
 * @description: Test class for ComplainantCasesController Apex class
 * @author: Ozlem Ece
 * @created date: 07/17/2025
 * @modificationlog:
 *   Mod ID   Date        Mod Author   Brief Mod Description
 *   0001     07/23/2025  oecep@fdic.gov Initial code creation
 */

@IsTest
public class ComplainantCasesControllerTest {

    // User to insert in test class
    static User adminUser = FDICUtil.createUser('Admin', 'TestUser', 'OzlemTester@test.com', null, 'System Administrator', 'tadmin1234', true);
    static User opcUser   = FDICUtil.createUser('Admin', 'TestUser', 'OPCTester@test.com', null, 'OPC User', 't1234', true);

    /**
     * @description when the method is invoked, it returns the case and the field that fits the expectations.
     * @param u
     * @param createManualShare
     * @return testCase
     */
    private static Case createCaseWithParticipant(User u, Boolean createManualShare){
        // Create Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case for Complainant';
        testCase.Status = 'New';
        testCase.Type = 'Harassment';
        testCase.Consent_to_Disclose_Identity__c = 'No restrictions';
        testCase.Sub_Type__c = 'Bullying';
        insert testCase;

        // Create PublicComplaint
        PublicComplaint pc = new PublicComplaint();
        pc.OPC_Case__c = testCase.Id;
        pc.IncidentDate = Date.newInstance(2025, 7, 24);
        pc.Type__c = 'Harassment';
        pc.Sub_Type__c = 'Bullying';
        insert pc;

        // Create Complainant Participant linking test user to Case
        ComplainantParticipant participant = new ComplainantParticipant();
        participant.Case__c = testCase.Id;
        participant.ParticipantId = u.Id;
        participant.Role = 'Complainant';
        participant.Status = 'Active';
        participant.PublicComplaintId = pc.Id;
        insert participant;

        // Create manual share
        if(createManualShare){
            CaseShare cs = new CaseShare();
            cs.CaseId = testCase.Id;
            cs.UserOrGroupId = u.Id;
            cs.CaseAccessLevel = 'Read';
            cs.RowCause = Schema.CaseShare.RowCause.Manual;
            insert cs;
        }

        return testCase;
    }

    /**
     * @description when the method is invoked, it returns the case and the field that fits the expectations.
     */
    @IsTest
    static void testGetCasesForComplainant(){
        // Run the logic as admin user
        System.runAs(adminUser){
            Case testCase = createCaseWithParticipant(adminUser, false);

            // Call the method under test
            Test.startTest();
            List<Case> result = ComplainantCasesController.getCasesForComplainant();
            Test.stopTest();

            // Assertions
            Assert.areNotEqual(null, result, 'Result should not be null');
            Assert.areEqual(testCase.Id, result[0].Id, 'Returned case Id should match');
            Assert.areEqual('New', result[0].Status, 'Returned case status should match');
        }
    }

    /**
     * @description Validates alternate access to case with case share.
     */
    @IsTest
    static void testGetCaseAfterShare(){
        Case testCase = createCaseWithParticipant(opcUser, true);

        // Run the logic as test user
        System.runAs(opcUser){
            // Call the method under test
            Test.startTest();
            List<Case> result = ComplainantCasesController.getCasesForComplainant();
            Test.stopTest();

            // Assertions
            Assert.areNotEqual(null, result, 'Result should not be null');
            Assert.areEqual(testCase.Id, result[0].Id, 'Returned case Id should match');
            Assert.areEqual('New', result[0].Status, 'Returned case status should match');
        }
    }

    /**
     * @description Fail Case Query.
     */
    @IsTest
    static void testFaultyCaseString(){
        System.runAs(adminUser){
            Case testCase = createCaseWithParticipant(adminUser, false);

            Test.startTest();
            ComplainantCasesController.testCaseQuery = 'Select FROM Case';
            Boolean gotException = false;

            try {
                ComplainantCasesController.getCasesForComplainant();
                System.assert(false, 'Expected exception is thrown');
            } catch (Exception e) {
                gotException = true;
                System.assertEquals('Script-thrown exception', e.getMessage(),
                                    'Script thrown exception is caught');
            } finally {
                ComplainantCasesController.testCaseQuery = null;
            }

            Test.stopTest();
            Assert.isTrue(gotException, 'We should have caught AuraHandledException');
        }
    }

    /**
     * @description Fail CaseShare Query.
     */
    @IsTest
    static void testFaultyCaseShareString(){
        System.runAs(adminUser){
            Case testCase = createCaseWithParticipant(adminUser, false);

            Test.startTest();
            ComplainantCasesController.testShareQuery = 'Select FROM CaseShare';
            Boolean gotException = false;

            try {
                ComplainantCasesController.getCasesForComplainant();
                System.assert(false, 'Expected exception is thrown');
            } catch (Exception e) {
                gotException = true;
                System.assertEquals('Script-thrown exception', e.getMessage(),
                                    'Script thrown exception is caught');
            } finally {
                ComplainantCasesController.testShareQuery = null;
            }

            Test.stopTest();
            Assert.isTrue(gotException, 'We should have caught AuraHandledException');
        }
    }
}
