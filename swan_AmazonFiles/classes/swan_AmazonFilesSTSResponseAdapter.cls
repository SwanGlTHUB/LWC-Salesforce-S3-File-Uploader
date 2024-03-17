/**
 * Adapter class to handle the response from an AWS STS callout.
 * Parses the HTTP response to extract AWS credentials or error messages.
 */
public class swan_AmazonFilesSTSResponseAdapter {

    private HTTPResponse AWSResponse;
    private AWSCredentials credentials;

    /**
     * Constructor that initializes the adapter with an HTTPResponse from AWS STS.
     * Parses the response based on the status code.
     * @param AWSResponse The HTTP response received from AWS STS.
     */
    public swan_AmazonFilesSTSResponseAdapter(HTTPResponse AWSResponse) {
        this.AWSResponse = AWSResponse;
        this.credentials = new AWSCredentials();

        if (AWSResponse.getStatusCode() == 200) {
            parseAWSResponse();
        } else {
            credentials.setErrorMessage(AWSResponse.getBody());
        }
    }

    /**
     * Returns the extracted AWS credentials or error message.
     * @return AWSCredentials The credentials extracted from the AWS STS response.
     */
    public AWSCredentials getCredentials() {
        return this.credentials;
    }

    /**
     * Parses the XML response from AWS to extract the temporary security credentials.
    */
    private void parseAWSResponse() {
        Dom.Document doc = this.AWSResponse.getBodyDocument();
        Dom.XMLNode root = doc.getRootElement();
        String namespaceUri = root.getNamespace();
                
        // Extract and assign credentials
        Dom.XMLNode credentialsNode = root.getChildElement('AssumeRoleResult', namespaceUri)
                                          .getChildElement('Credentials', namespaceUri);
        
        if(credentialsNode != null) {
            this.credentials.setAccessKeyId(credentialsNode.getChildElement('AccessKeyId', namespaceUri).getText());
            this.credentials.setSecretAccessKey(credentialsNode.getChildElement('SecretAccessKey', namespaceUri).getText());
            this.credentials.setSessionToken(credentialsNode.getChildElement('SessionToken', namespaceUri).getText());
        } else {
            System.debug('AWS STS Response parsing error: Credentials node is missing.');
        }
    }

    /**
     * Inner class to encapsulate AWS credentials or an error message.
     */
    public class AWSCredentials {
        private String accessKeyId;
        private String secretAccessKey;
        private String sessionToken;
        private String errorMessage;
        private String region;
        private String bucket;
        private String bucketName;
        private String currentUserName;
        private Boolean userHasPermission;
        private String userPermissionLevel;
        private List<swan_AmazonFile__c> amazonFiles = new List<swan_AmazonFile__c>();

        // Getters
        @AuraEnabled public String getAccessKeyId() { return accessKeyId; }
        @AuraEnabled public String getSecretAccessKey() { return secretAccessKey; }
        @AuraEnabled public String getSessionToken() { return sessionToken; }
        @AuraEnabled public String getErrorMessage() { return errorMessage; }
        @AuraEnabled public String getRegion() { return region; }
        @AuraEnabled public String getBucket() { return bucket; }
        @AuraEnabled public String getBucketName() { return bucketName; }
        @AuraEnabled public String getCurrentUserName() { return currentUserName; }
        @AuraEnabled public Boolean getUserHasPermission() { return userHasPermission; }
        @AuraEnabled public String getUserPermissionLevel() { return userPermissionLevel; }
        @AuraEnabled public List<swan_AmazonFile__c> getAmazonFiles() { return amazonFiles; }

        // Setters
        public void setAccessKeyId(String accessKeyId) { this.accessKeyId = accessKeyId; }
        public void setSecretAccessKey(String secretAccessKey) { this.secretAccessKey = secretAccessKey; }
        public void setSessionToken(String sessionToken) { this.sessionToken = sessionToken; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
        public void setRegion(String region) { this.region = region; }
        public void setBucket(String bucket) { this.bucket = bucket; }
        public void setBucketName(String bucketName) { this.bucketName = bucketName; }
        public void setCurrentUserName(String userName) { this.currentUserName = userName; }
        public void setUserHasPermission(Boolean userHasPermission) { this.userHasPermission = userHasPermission; }
        public void setUserPermissionLevel(String userPermissionLevel) { this.userPermissionLevel = userPermissionLevel; }
        public void setAmazonFiles(List<swan_AmazonFile__c> files) { this.amazonFiles = files; }

    }
   
}