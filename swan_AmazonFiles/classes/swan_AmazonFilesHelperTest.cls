@isTest
public  class swan_AmazonFilesHelperTest {
    
    @TestSetup
    static void setupData(){
        swan_TestHelper.insertTestUser();
        swan_TestHelper.insertAmazonFilesSetting();
    }

    @isTest
    public static void currentUserHasAccessToFunctionality_userHasReadAcceess_hasReadAccessToFunctionality() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        swan_TestHelper.assignReadAccessToCurrentUser(testUser.Id);

        Boolean hasAccessToFunctionality = false;
        Boolean hasEditAccessToFunctionality = false;

        Test.startTest();
            System.runAs(testUser) {
                hasAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasAccessToFunctionality();
                hasEditAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasEditAccessToFunctionality();
            }
        Test.stopTest();

        Assert.isTrue(hasAccessToFunctionality, 'User must have access to the functionality.');
        Assert.isFalse(hasEditAccessToFunctionality, 'User must not have EDIT access to the functionality.');
    }

    @isTest
    public static void currentUserHasAccessToFunctionality_userHasEditAcceess_hasEditAccessToFunctionality() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        swan_TestHelper.assignEditAccessToCurrentUser(testUser.Id);

        Boolean hasAccessToFunctionality = false;
        Boolean hasEditAccessToFunctionality = false;

        Test.startTest();
            System.runAs(testUser) {
                hasAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasAccessToFunctionality();
                hasEditAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasEditAccessToFunctionality();
            }
        Test.stopTest();

        Assert.isTrue(hasAccessToFunctionality, 'User must have access to the functionality.');
        Assert.isTrue(hasEditAccessToFunctionality, 'User must have EDIT access to the functionality.');
    }


    @isTest
    public static void currentUserHasAccessToTheRecord_userCreateAccount_hasReadAccessToAccount() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        

        Test.startTest();
            System.runAs(testUser) {
                Account testAcc = new Account(
                    Name = 'test'
                );
                insert testAcc;

                Assert.isTrue(swan_AmazonFilesHelper.currentUserHasAccessToTheRecord(testAcc.Id), 'User must have an access to the testAcc');
            }
        Test.stopTest();
    }

    @isTest
    public static void getCurrentUserInlinePolicyForRecord_userHasEditAcceess_hasGetObjectPolicy() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        swan_TestHelper.assignReadAccessToCurrentUser(testUser.Id);

        String resultPolicy = '';

        Test.startTest();
            System.runAs(testUser) {
                Account testAcc = new Account(
                    Name = 'test'
                );

                insert testAcc;

                resultPolicy = swan_AmazonFilesHelper.getCurrentUserInlinePolicyForRecord(testAcc.Id);
            }
        Test.stopTest();

        Assert.isTrue(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_GET_OBJECT), 'User must have GetObject Policy.');
        Assert.isFalse(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_PUT_OBJECT), 'User must NOT have PutObject Policy.');
        Assert.isFalse(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_DELETE_OBJECT), 'User must NOT have DeleteObject Policy.');
    }

    @isTest
    public static void getCurrentUserInlinePolicyForRecord_userHasEditAcceess_hasGetPutDeleteObjectPolicies() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        swan_TestHelper.assignEditAccessToCurrentUser(testUser.Id);

        String resultPolicy = '';

        Test.startTest();
            System.runAs(testUser) {
                Account testAcc = new Account(
                    Name = 'test'
                );

                insert testAcc;

                resultPolicy = swan_AmazonFilesHelper.getCurrentUserInlinePolicyForRecord(testAcc.Id    );
            }
        Test.stopTest();

        Assert.isTrue(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_GET_OBJECT), 'User must have GetObject Policy.');
        Assert.isTrue(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_PUT_OBJECT), 'User must have PutObject Policy.');
        Assert.isTrue(resultPolicy.contains(swan_AmazonFilesConstants.AWS_S3_DELETE_OBJECT), 'User must have DeleteObject Policy.');
    }

    @isTest
    public static void getCurrentUserInlinePolicyForRecord_userNotHaveAccess_EmptyPolicy() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        String resultPolicy = '';

        Test.startTest();
            System.runAs(testUser) {
                Account testAcc = new Account(
                    Name = 'test'
                );

                insert testAcc;

                resultPolicy = swan_AmazonFilesHelper.getCurrentUserInlinePolicyForRecord(testAcc.Id);
            }
        Test.stopTest();

        Assert.isTrue(String.isEmpty(resultPolicy), 'Policy must be empty.');
    }
}