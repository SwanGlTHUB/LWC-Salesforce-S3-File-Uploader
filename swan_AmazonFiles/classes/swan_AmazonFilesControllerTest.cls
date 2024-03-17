@isTest
public class swan_AmazonFilesControllerTest {
    
    @TestSetup
    static void setupData(){
        swan_TestHelper.insertTestUser();
        swan_TestHelper.insertAmazonFilesSetting();
    }

    @isTest
    public static void createAmazonFileMetadataRecord_editAccessSomeRecord_recordCreated() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        String key = 'h583gh9583hg5h23g87h2385g347g6w47h5g';

        swan_TestHelper.assignEditAccessToCurrentUser(testUser.Id);

        Test.startTest();
            System.runAs(testUser){
                Account testAcc = new Account(
                    Name = 'test'
                );
                insert testAcc;

                swan_AmazonFilesController.createAmazonFileMetadataRecord(
                UserInfo.getUserId(),
                'image/jpeg', 
                key,
                'note',
                4234,
                'filename'
            );
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM swan_AmazonFile__c WHERE Key__c = :key].size() == 1, 'Expected 1 Amazon File record.');
    }

    @isTest
    public static void deleteAmazonFileMetadataRecord_someRecord_recordDeleted() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];
        
        String key = 'h583gh9583hg5h23g87h2385g347g6w47h5g';

        swan_TestHelper.assignEditAccessToCurrentUser(testUser.Id);

        
        Test.startTest();
            System.runAs(testUser){
                swan_AmazonFile__c amazonFile = swan_AmazonFilesController.createAmazonFileMetadataRecord(
                    UserInfo.getUserId(),
                    'image/jpeg', 
                    key,
                    'note',
                    4234,
                    'filename'
                );

                Account testAcc = new Account(
                    Name = 'test'
                );

                insert testAcc;
                swan_AmazonFilesController.deleteAmazonFile(testAcc.Id, amazonFile.Id);
            }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM swan_AmazonFile__c WHERE Key__c = :key].isEmpty(), 'Expected 0 Amazon File records.');
    }

    @isTest
    public static void createAmazonFileMetadataRecord_readAccessSomeRecord_exceptionThrew() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        String key = 'h583gh9583hg5h23g87h2385g347g6w47h5g';

        swan_TestHelper.assignReadAccessToCurrentUser(testUser.Id);

        Test.startTest();
            try {
                System.runAs(testUser){
                    Account testAcc = new Account(
                        Name = 'test'
                    );
                    insert testAcc;
    
                    swan_AmazonFilesController.createAmazonFileMetadataRecord(
                    UserInfo.getUserId(),
                    'image/jpeg', 
                    key,
                    'note',
                    4234,
                    'filename'
                );
                }
            }  catch (Exception e) {
                Assert.isTrue(true);
                return;
            }
            
        Test.stopTest();
       
        Assert.isFalse(true, 'Expected error.');
    }

    @isTest
    public static void assumeRoleForCurrentUserToUploadFiles_readAccess_validCredentials() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];


        swan_TestHelper.assignReadAccessToCurrentUser(testUser.Id);

        swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials;

        String accessKeyId = 'accessKeyIdTest';
        String secretAccessKey = 'secretAccessKeyTest';
        String sessionToken = 'sessionTokenTest';

        Test.setMock(HttpCalloutMock.class, new AwsStsMockHttpResponse(accessKeyId, secretAccessKey, sessionToken));

        Test.startTest();
            System.runAs(testUser){
                credentials = swan_AmazonFilesController.assumeRoleForCurrentUserToUploadFiles(UserInfo.getUserId());
            }
        Test.stopTest();
            
        Assert.areEqual(credentials.getAccessKeyId(), accessKeyId, 'Wrong accessKeyId.');
        Assert.areEqual(credentials.getSecretAccessKey(), secretAccessKey, 'Wrong secretAccessKey.');
        Assert.areEqual(credentials.getSessionToken(), sessionToken, 'Wrong sessionToken.');
        Assert.areEqual(credentials.getRegion(), 'region', 'Wrong region.');
        Assert.areEqual(credentials.getBucket(), 'bucketARN', 'Wrong bucket.');
        Assert.areEqual(credentials.getBucketName(), 'bucketName', 'Wrong bucketName.');
        Assert.areEqual(credentials.getUserHasPermission(), true, 'Wrong userHasPermission.');
        Assert.areEqual(credentials.getUserPermissionLevel(), swan_AmazonFilesConstants.AWS_PERMISSION_LEVEL_READ, 'Wrong permission level.');
    }

    @isTest
    public static void assumeRoleForCurrentUserToUploadFiles_editAccess_validCredentials() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];


        swan_TestHelper.assignEditAccessToCurrentUser(testUser.Id);

        swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials;

        String accessKeyId = 'accessKeyIdTest';
        String secretAccessKey = 'secretAccessKeyTest';
        String sessionToken = 'sessionTokenTest';

        Test.setMock(HttpCalloutMock.class, new AwsStsMockHttpResponse(accessKeyId, secretAccessKey, sessionToken));

        Test.startTest();
            System.runAs(testUser){
                credentials = swan_AmazonFilesController.assumeRoleForCurrentUserToUploadFiles(UserInfo.getUserId());
            }
        Test.stopTest();
            
        Assert.areEqual(credentials.getAccessKeyId(), accessKeyId, 'Wrong accessKeyId.');
        Assert.areEqual(credentials.getSecretAccessKey(), secretAccessKey, 'Wrong secretAccessKey.');
        Assert.areEqual(credentials.getSessionToken(), sessionToken, 'Wrong sessionToken.');
        Assert.areEqual(credentials.getRegion(), 'region', 'Wrong region.');
        Assert.areEqual(credentials.getBucket(), 'bucketARN', 'Wrong bucket.');
        Assert.areEqual(credentials.getBucketName(), 'bucketName', 'Wrong bucketName.');
        Assert.areEqual(credentials.getUserHasPermission(), true, 'Wrong userHasPermission.');
        Assert.areEqual(credentials.getUserPermissionLevel(), swan_AmazonFilesConstants.AWS_PERMISSION_LEVEL_EDIT, 'Wrong permission level.');
    }

    @isTest
    public static void assumeRoleForCurrentUserToUploadFiles_noAccess_validCredentials() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testlolkek52343242@gmail.com'
        ];

        swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials;

        String accessKeyId = 'accessKeyIdTest';
        String secretAccessKey = 'secretAccessKeyTest';
        String sessionToken = 'sessionTokenTest';

        Test.setMock(HttpCalloutMock.class, new AwsStsMockHttpResponse(accessKeyId, secretAccessKey, sessionToken));

        Test.startTest();
            System.runAs(testUser){
                credentials = swan_AmazonFilesController.assumeRoleForCurrentUserToUploadFiles(UserInfo.getUserId());
            }
        Test.stopTest();

        Assert.areEqual(credentials.getUserHasPermission(), false, 'Wrong userHasPermission.');
    }

    private class AwsStsMockHttpResponse implements HttpCalloutMock {

        private final String AWS_STS_RESPONSE = 
            '<AssumeRoleResponse xmlns="https://sts.amazonaws.com/doc/2011-06-15/">' + 
                '<AssumeRoleResult>' + 
                    '<AssumedRoleUser>' + 
                        '<AssumedRoleId>0004vDwwMAE+005Qy0000039I8rIAE</AssumedRoleId>' + 
                        '<Arn>assumed-role/kek/AWSkek-00DQy000004vDwwMAE+005Qy0000039I8rIAE</Arn>' + 
                    '</AssumedRoleUser>' + 
                    '<Credentials>' + 
                        '<AccessKeyId>{0}</AccessKeyId>' + 
                        '<SecretAccessKey>{1}</SecretAccessKey>' + 
                        '<SessionToken>{2}</SessionToken>' + 
                        '<Expiration>2024-03-15T13:25:05Z</Expiration>' +
                    '</Credentials>' + 
                    '<PackedPolicySize>19</PackedPolicySize>' +
                '</AssumeRoleResult>' + 
                '<ResponseMetadata>' + 
                    '<RequestId>bf733f3c-a754-46fd-aa84-6c3682f12a95</RequestId>' + 
                '</ResponseMetadata>' + 
            '</AssumeRoleResponse>';
        
        private String accessKeyId;
        private String secretAccessKey;
        private String sessionToken;

        public AwsStsMockHttpResponse(String accessKeyId, String secretAccessKey, String sessionToken) {
            this.accessKeyId = accessKeyId;
            this.secretAccessKey = secretAccessKey;
            this.sessionToken = sessionToken;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            String xmlResponse = String.format(
                this.AWS_STS_RESPONSE, 
                new List<String>{this.accessKeyId, this.secretAccessKey, this.sessionToken}
            );
            res.setBody(xmlResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}