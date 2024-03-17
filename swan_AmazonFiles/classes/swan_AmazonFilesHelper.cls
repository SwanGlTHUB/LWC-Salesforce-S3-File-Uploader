public without sharing class swan_AmazonFilesHelper {
    
    public static Boolean currentUserHasAccessToFunctionality() {
        return FeatureManagement.checkPermission(swan_AmazonFilesConstants.AMAZON_FILES_VIEW_CUSTOM_PERMISSION) ||
                FeatureManagement.checkPermission(swan_AmazonFilesConstants.AMAZON_FILES_EDIT_CUSTOM_PERMISSION);
    }

    public static Boolean currentUserHasEditAccessToFunctionality() {
        return FeatureManagement.checkPermission(swan_AmazonFilesConstants.AMAZON_FILES_EDIT_CUSTOM_PERMISSION);
    }

    public static Boolean currentUserHasAccessToTheRecord(Id recordId) {
        List<UserRecordAccess> records = [
            SELECT RecordId, HasReadAccess 
            FROM UserRecordAccess 
            WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId
            LIMIT 1
        ];

        if (records.isEmpty()) return false;

        return records[0].HasReadAccess;
    }

    public static String getCurrentUserInlinePolicyForRecord(Id recordId) {
        swan_AmazonFilesInlinePolicyBuilder policyBuilder = new swan_AmazonFilesInlinePolicyBuilder();
        
        if (FeatureManagement.checkPermission(swan_AmazonFilesConstants.AMAZON_FILES_EDIT_CUSTOM_PERMISSION)) {
            policyBuilder.addStatement(
                swan_AmazonFilesConstants.AWS_EFFECT_ALLOW,
                new List<String> {
                    swan_AmazonFilesConstants.AWS_S3_GET_OBJECT,
                    swan_AmazonFilesConstants.AWS_S3_PUT_OBJECT,
                    swan_AmazonFilesConstants.AWS_S3_DELETE_OBJECT
                },
                swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).S3BucketARN__c + '/' + String.valueOf(recordId) + '/*'
            );
        } else if (FeatureManagement.checkPermission(swan_AmazonFilesConstants.AMAZON_FILES_VIEW_CUSTOM_PERMISSION)) {
            policyBuilder.addStatement(
                swan_AmazonFilesConstants.AWS_EFFECT_ALLOW,
                new List<String> {
                    swan_AmazonFilesConstants.AWS_S3_GET_OBJECT
                },
                swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).S3BucketARN__c + '/' + String.valueOf(recordId) + '/*'
            );
        } else {
            return '';
        }


        return policyBuilder.getResultPolicy();
    }

    public static swan_AmazonFile__c createAmazonFileMetadataRecord(String mimeType, String key, String note, Integer size, String fileName) {
        swan_AmazonFile__c newAmazonFile = new swan_AmazonFile__c(
            Key__c = key, 
            MIME__c = mimeType,
            Note__c = note,
            Size__c = size,
            FileName__c = fileName,
            UploadedById__c = UserInfo.getUserId(),
            UploadedByName__c = UserInfo.getName()
        );

        insert newAmazonFile;

        return newAmazonFile;
    }

    public static List<swan_AmazonFile__c> getAmazonFilesByPrefix(String prefix) {
        List<swan_AmazonFile__c> amazonFiles = [
            SELECT Id, Key__c, MIME__c, Note__c, Size__c, FileName__c, UploadedById__c, UploadedByName__c
            FROM swan_AmazonFile__c
            WHERE Key__c LIKE :prefix + '%'
        ];

        return amazonFiles;
    }

    public static void deleteAmazonFile(Id amazonFileId) {
        swan_AmazonFile__c amazonFile = new swan_AmazonFile__c(Id = amazonFileId);
        delete amazonFile;
        
    }

 
}