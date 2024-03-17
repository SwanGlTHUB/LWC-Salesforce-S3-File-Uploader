/**
 * AWSService provides functionalities to interact with AWS Services,
 */
public class swan_AmazonFilesService {

    /**
     * Assumes an AWS role suitable for uploading files by making a callout to AWS STS.
     * The role and session details are fetched from custom settings and user information.
     *
     * @return AWSCredentials The temporary security credentials for the assumed role
     */
    public static swan_AmazonFilesSTSResponseAdapter.AWSCredentials assumeRoleForCurrentUserToUploadFiles(Id recordId) {

        // Retrieve role ARN from custom settings
        String roleArn = swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).RoleARN__c;
        // Construct the RoleSessionName
        String roleSessionName = UserInfo.getOrganizationId() + '%2B' + UserInfo.getUserId();
        
        // Prepare request parameters
        Map<String, String> bodyParams = new Map<String, String>{
            'RoleArn' => roleArn,
            'RoleSessionName' => roleSessionName,
            'Policy' => EncodingUtil.urlEncode(swan_AmazonFilesHelper.getCurrentUserInlinePolicyForRecord(recordId), 'UTF-8'),
            'DurationSeconds' => '1800' // Explicitly set for clarity
        };


        // Construct the endpoint with parameters
        String endpoint = swan_AmazonFilesConstants.AWS_STS_NAMED_CREDENTIAL + formatParamsForSTS(bodyParams);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET'); // Adjust based on the AWS STS action requirements

        try {
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            // Parse the response and extract credentials
            swan_AmazonFilesSTSResponseAdapter responseAdapter = new swan_AmazonFilesSTSResponseAdapter(res);
            swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials = responseAdapter.getCredentials();
    
            tuneCredentials(credentials);

            return credentials;
            
        } catch(System.CalloutException ex) {
            // Log and handle the callout exception
            System.debug('Callout to AWS STS failed: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * Formats the parameters for the STS request.
     * @param params Map<String, String> containing the request parameters
     * @return String The formatted parameters for inclusion in the request URL
     */
    private static String formatParamsForSTS(Map<String, String> params) {
        return String.format(swan_AmazonFilesConstants.AWS_STS_ASSUME_ROLE_S3_UPLOAD_TEMPLATE, params.values());
    }

    private static void tuneCredentials(swan_AmazonFilesSTSResponseAdapter.AWSCredentials credentials) {
        credentials.setRegion(swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).Region__c);
        credentials.setBucket(swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).S3BucketARN__c);
        credentials.setBucketName(swan_AmazonFilesSettings__c.getInstance(swan_AmazonFilesConstants.AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME).BucketName__c);
        credentials.setCurrentUserName(UserInfo.getName());
    }
}