public class swan_TestHelper {
   
    public static void insertTestUser() {
        String uniqueName = 'testName' + DateTime.now().getTime() + '@gmail.com';

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'userok',
            Email = 'testlolkek52343242@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueName,
            isActive = true
        );
        insert testUser;
    }

    public static void insertAmazonFilesSetting() {
        swan_AmazonFilesSettings__c amazonFilesSetting = new swan_AmazonFilesSettings__c(
            Name = swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME,
            BucketName__c = 'bucketName',
            Region__c = 'region',
            RoleARN__c = 'roleARN',
            S3BucketARN__c = 'bucketARN'
        );

        insert amazonFilesSetting;
    }

    public static void assignReadAccessToCurrentUser(Id testUserId) {
        PermissionSet amazonFilesRead = new PermissionSet(
            Name = 'test_swan_AmazonFilesView',
            Label = 'Test Amazon Files Read'
        );
        insert amazonFilesRead;

        SetupEntityAccess viewCustomPermission = new SetupEntityAccess(
            ParentId = amazonFilesRead.Id,
            SetupEntityId = [
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :swan_AmazonFilesConstants.AMAZON_FILES_VIEW_CUSTOM_PERMISSION
                LIMIT 1
            ].Id
        );

        insert new List<SetupEntityAccess>{viewCustomPermission};

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUserId,
            PermissionSetId = amazonFilesRead.Id
        );

        insert psa;
    }
    
    public static void assignEditAccessToCurrentUser(Id testUserId) {
        PermissionSet amazonFilesEdit = new PermissionSet(
            Name = 'test_swan_AmazonFilesEdit',
            Label = 'Test Amazon Files Edit'
        );
        insert amazonFilesEdit;

        SetupEntityAccess viewCustomPermission = new SetupEntityAccess(
            ParentId = amazonFilesEdit.Id,
            SetupEntityId = [
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :swan_AmazonFilesConstants.AMAZON_FILES_VIEW_CUSTOM_PERMISSION
                LIMIT 1
            ].Id
        );
        SetupEntityAccess editCustomPermission = new SetupEntityAccess(
            ParentId = amazonFilesEdit.Id,
            SetupEntityId = [
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :swan_AmazonFilesConstants.AMAZON_FILES_EDIT_CUSTOM_PERMISSION
                LIMIT 1
            ].Id
        );

        insert new List<SetupEntityAccess>{viewCustomPermission, editCustomPermission};

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUserId,
            PermissionSetId = amazonFilesEdit.Id
        );

        insert psa;
    }
}