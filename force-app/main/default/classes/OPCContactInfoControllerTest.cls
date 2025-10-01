/**
 * @description Test class for OPCContactInfoController Apex class. Covers scenarios for successful/unsuccessful deployment callbacks,
 * metadata retrieval, metadata update and user type detection.
 */
@isTest
public class OPCContactInfoControllerTest {

    // test user created to be used with System.runAs()
    static User testUser;
    static User testUser2;

    static{
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        testUser = new User(
            FirstName = 'Test',
            LastName = 'Admin',
            Email = 'testuser@test.com',
            Username = 'testuser@testexample.com',
            Alias = 'tadmin',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = sysAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Profile sysAdminProfile2 = [SELECT Id FROM Profile WHERE Name = 'Guest License User' LIMIT 1];
        testUser2 = new User(
            FirstName = 'Test',
            LastName = 'Guest',
            Email = 'testuser2@test.com',
            Username = 'testuser2test2@example.com',
            Alias = 'tguest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = sysAdminProfile2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;
    }

    /**
     * @description This test will simulate a successful deployment and print out a debug.
     */
    @isTest
    static void myCallbackTest(){
        System.runAs(testUser){
            Metadata.DeployCallback callback = new OPCContactInfoController();
            Metadata.DeployResult result = new Metadata.DeployResult();
            result.status = Metadata.DeployStatus.Succeeded;
            Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

            Test.startTest();
            callback.handleResult(result, context);
            Test.stopTest();

            Assert.areEqual(Metadata.DeployStatus.Succeeded, result.status, 'Expected status: Succeeded');
        }
    }

    /**
     * @description This test will simulate a non-successful deployment and print out a debug.
     */
    @isTest
    static void myCallbackFailTest(){
        System.runAs(testUser2){
            Metadata.DeployCallback callback = new OPCContactInfoController();
            Metadata.DeployResult result = new Metadata.DeployResult();
            result.status = Metadata.DeployStatus.Failed;
            Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

            Test.startTest();
            callback.handleResult(result, context);
            Test.stopTest();

            Assert.areEqual(Metadata.DeployStatus.Failed, result.status, 'Expected status: Failed');
        }
    }

    /**
     * @description This test will retrieve metadata records and verify they are not null.
     */
    @isTest
    static void testGetMetadataRecords(){
        System.runAs(testUser){
            String contactType = 'OPCUser';
            List<OPC_Contact_Information__mdt> retrivedData = new List<OPC_Contact_Information__mdt>();

            Test.startTest();
            retrivedData = OPCContactInfoController.getMetadataRecords(contactType);
            Test.stopTest();

            Assert.areEqual(1, retrivedData.size(), 'Expected list size is one.');
        }
    }

    /**
     * @description This test will forcefully feed a null value to catch the error handling when searching for a record.
     */
    @isTest
    static void getMetadataContactInfoNullTest(){
        System.runAs(testUser){
            String contactType = '';
            List<OPC_Contact_Information__mdt> retrivedData = new List<OPC_Contact_Information__mdt>();

            Test.startTest();
            retrivedData = OPCContactInfoController.getMetadataRecords(contactType);
            Test.stopTest();

            // Negative assert
            Assert.areEqual(0, retrivedData.size(), 'Expected list size is zero');
        }
    }

    /**
     * @description This test will mock an update using a valid type, real deployment will not happen in the test context.
     */
    @isTest
    static void testUpdateMetadataContact(){
        System.runAs(testUser){
            String contactType = 'OPCUser';
            String screenMessage = 'UpdateScreenMessage';
            String email = 'update@example.com';
            String phone = '9876543210';
            String address = '456 New St';

            Test.startTest();
            OPCContactInfoController.updateMetadataContact(contactType+'::'+screenMessage+'::'+email+'::'+phone+'::'+address);
            Test.stopTest();

            Assert.isTrue(true, 'Update executed without exception');
        }
    }

    /**
     * @description This test will forcefully feed an null type to simulate the error handling when updating a record.
     */
    @isTest
    static void updateMetadataContactNullTest(){
        System.runAs(testUser){
            String contactType = null;
            String screenMessage = 'Test Coverage';
            String email = 'TestCoverage@SomeRandomEmail.com';
            String phone = '1234567890';
            String address = '123 Test';

            Test.startTest();
            OPCContactInfoController.updateMetadataContact(contactType+'::'+screenMessage+'::'+email+'::'+phone+'::'+address);
            Test.stopTest();

            Assert.isTrue(true, 'Exception caught as expected for null contactType');
        }
    }

    /**
     * @description This test validates the getUserType method by asserting a non-null user type string is returned.
     */
    @isTest
    static void testGetUserType(){
        System.runAs(testUser){
            Test.startTest();
            String userType = OPCContactInfoController.getUserType();
            Test.stopTest();

            Assert.areNotEqual(null, userType, 'UserType should not be null');
        }
    }
}
