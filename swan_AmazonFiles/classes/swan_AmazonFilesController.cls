/**
 * Controller class for Swan_AmazonFiles Lightning Web Component.
 * This class provides methods to interact with AWS services, such as assuming a role for file uploads.
 */
public with sharing class swan_AmazonFilesController {
    
    /**
     * Assumes an AWS role for the current user to upload files. This method checks
     * if the current user has the necessary custom permission before attempting to
     * assume the AWS role and returns the AWS credentials.
     *
     * @return AWSCredentials Object containing AWS credentials or an error message.
     */
    @AuraEnabled
    public static swan_AmazonFilesSTSResponseAdapter.AWSCredentials assumeRoleForCurrentUserToUploadFiles(Id recordId) {
        // Check if the current user has access to this functionality
        Boolean hasAccessToFunctionality = swan_AmazonFilesHelper.currentUserhasAccessToFunctionality() &&
        swan_AmazonFilesHelper.currentUserHasAccessToTheRecord(recordId);
        
        // Initialize credentials object;
        swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials;

        if (!hasAccessToFunctionality) {
            credentials = new swan_AmazonFilesSTSResponseAdapter.AWSCredentials();
            credentials.setUserHasPermission(false);
        } else {
            try {
                credentials = swan_AmazonFilesService.assumeRoleForCurrentUserToUploadFiles(recordId);
                credentials.setUserHasPermission(true);
                credentials.setAmazonFiles(swan_AmazonFilesHelper.getAmazonFilesByPrefix(String.valueOf(recordId)));
            
                if (swan_AmazonFilesHelper.currentUserHasEditAccessToFunctionality()) {
                    credentials.setUserPermissionLevel(swan_AmazonFilesConstants.AWS_PERMISSION_LEVEL_EDIT);
                } else {
                    credentials.setUserPermissionLevel(swan_AmazonFilesConstants.AWS_PERMISSION_LEVEL_READ);
                }
            } catch(Exception e) {
                credentials.setErrorMessage(Label.swan_UnexpectedError + e.getMessage());
            }
        }

       

        return credentials;
    }

    @AuraEnabled
    public static swan_AmazonFile__c createAmazonFileMetadataRecord(Id recordId, String mimeType, String key, String note, Integer size, String fileName) {
        Boolean hasAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasEditAccessToFunctionality() &&
                                            swan_AmazonFilesHelper.currentUserHasAccessToTheRecord(recordId);
        
        if (!hasAccessToFunctionality) {
            throw new AuraHandledException(Label.swan_AccessDeniedNeedEditPermission);
        }      
        
        return swan_AmazonFilesHelper.createAmazonFileMetadataRecord(mimeType, key, note, size, fileName);
    }

    @AuraEnabled
    public static void deleteAmazonFile(Id recordId, Id metadataRecordId) {
        Boolean hasAccessToFunctionality = swan_AmazonFilesHelper.currentUserHasEditAccessToFunctionality() &&
                                            swan_AmazonFilesHelper.currentUserHasAccessToTheRecord(recordId);
        
        if (!hasAccessToFunctionality) {
            throw new AuraHandledException(Label.swan_AccessDeniedNeedEditPermission);
        }      
        
        swan_AmazonFilesHelper.deleteAmazonFile(metadataRecordId);
    }
}