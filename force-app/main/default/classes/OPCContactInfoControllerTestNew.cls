/*******************************************************************************************************
 * @description Test class for OPCContactInfoController Apex class. 
 * Cover scenarios for successful/unsuccessful deployment callbacks,
 * metadata retrieval, metadata update and user type detection.
 *******************************************************************************************************/
@IsTest
public class OPCContactInfoControllerTest {

    // User to insert in test class
    static User testUser = FDICTUtil.createUser('Admin', 'TestUser', 'OzlemeTester@test.com', null, 'System Administrator', 'tadmin1234', true);

    /**
     * @description This test will retrieve metadata records and verify they are not null.
     */
    @IsTest
    static void testGetMetadataRecords(){
        System.runAs(testUser){
            String contactType = 'OPCUser';
            Map<String, Object> result = OPCContactInfoController.getMetadata(contactType);
            List<OPC_Contact_Information__mdt> retrivedData = 
                (List<OPC_Contact_Information__mdt>) result.get('records');

            Test.startTest();
            Assert.areEqual(0, retrivedData.size(), 'Expected list size is one.');
            Assert.areNotEqual(0, retrivedData.size(), 'Expected list size is not zero.');
            Test.stopTest();
        }
    }

    /**
     * @description This test will forcefully feed an NULL value to catch the error handling 
     *              when searching for a record.
     */
    @IsTest
    static void getMetadataContactInfoNullTest(){
        System.runAs(testUser){
            String contactType = null;
            Map<String, Object> result = OPCContactInfoController.getMetadata(contactType);
            List<OPC_Contact_Information__mdt> retrivedData = 
                (List<OPC_Contact_Information__mdt>) result.get('records');

            Test.startTest();
            // Negative assert
            Assert.areEqual(0, retrivedData.size(), 'Expected list size is zero');
            Assert.areNotEqual(0, retrivedData.size(), 'Expected list size is zero');
            Test.stopTest();
        }
    }

    /**
     * @description This test will mock the metadata query exception handling
     */
    /*
    @IsTest
    static void testMetadataQueryExceptionHandling(){
        System.runAs(testUser){
            OPCContactInfoController.simulateMetadataFailure = true;

            Test.startTest();
            try {
                OPCContactInfoController.getMetadata('SomeType');
                System.assert(false, 'Expected AuraHandledException not thrown');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Metadata Query Error'));
            }
            Test.stopTest();
        }
    }*/
}
