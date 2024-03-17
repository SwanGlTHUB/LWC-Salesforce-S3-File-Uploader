/**
 * Constants used for AWS Service integrations.
 * This class includes configurations for STS AssumeRole operations
 * and default setting names.
 */
public class swan_AmazonFilesConstants {

    /**
     * Template for constructing the query part of the AssumeRole request URL.
     * {0} - Placeholder for the Role ARN.
     * {1} - Placeholder for a unique session name suffix.
     * {2} - Placeholder for a tokens duration.
     * This template sets up a request for assuming an AWS role with a specified
     * duration and session name, which is necessary for S3 uploads among other actions.
     */
    public static final String AWS_STS_ASSUME_ROLE_S3_UPLOAD_TEMPLATE = '?Version=2011-06-15&' +
                'Action=AssumeRole&' + 
                'RoleArn={0}&' +
                'RoleSessionName=SalesforceAmazonFiles-{1}&' + 
                'Policy={2}&' +
                'DurationSeconds={3}';

    /**
     * The default name used in custom settings for AWS role configurations.
     * This is used when a specific AWS role configuration name is not provided.
     */
    public static final String AWS_ROLE_DEFAULT_CUSTOM_SETTING_NAME = 'Default';

    public static final String AMAZON_FILES_VIEW_CUSTOM_PERMISSION = 'swan_AmazonFilesView';
    public static final String AMAZON_FILES_EDIT_CUSTOM_PERMISSION = 'swan_AmazonFilesEdit';
    public static final String AWS_STS_NAMED_CREDENTIAL = 'callout:swan_AWSSecurityTokenService/';

    public static final String AWS_INLINE_POLICY_TEMPLATE = 
    '"Version": "2012-10-17",' +
    '"Statement": [' +
        '{0}' +
    ']';

    public static final String AWS_INLINE_POLICY_STATEMENT_TEMPLATE =
    '"Effect": {0},' +
    '"Action": [{1}],' + // Assuming you'll pass a JSON-formatted string array here
    '"Resource": "{2}"';

    public static final String AWS_INLINE_POLICY_STATEMENT_WITH_CONDITION_TEMPLATE =
    '"Effect": {0},' +
    '"Action": [{1}],' + // Assuming you'll pass a JSON-formatted string array here
    '"Resource": "{2}", ' + 
    '"Condition": {3}';


    // AWS Policies
    public static final String AWS_EFFECT_ALLOW = '"Allow"';
    public static final String AWS_EFFECT_DENY = '"DENY"';

    public static final String AWS_S3_GET_OBJECT = '"s3:GetObject"';
    public static final String AWS_S3_PUT_OBJECT = '"s3:PutObject"';
    public static final String AWS_S3_DELETE_OBJECT = '"s3:DeleteObject"';
    public static final String AWS_S3_LIST_BUCKET = '"s3:ListBucket"';


    public static final String AWS_PERMISSION_LEVEL_EDIT = 'EDIT';
    public static final String AWS_PERMISSION_LEVEL_READ = 'READ';


}