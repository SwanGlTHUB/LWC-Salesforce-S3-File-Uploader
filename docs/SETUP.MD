## AWS Setup Instructions

### Step 1: Create a Salesforce IAM User

Firstly, create a new IAM user dedicated to Salesforce integration, unless you've previously created one. 

1. Navigate to `IAM -> Users` in your AWS Console.
2. Click `Create User`. Note: Do not assign any permissions at this stage; simply create the user.

### Step 2: Create and Configure an S3 Bucket

You will need an S3 bucket for storing Salesforce files. Follow these steps to create and configure your S3 bucket for CORS:

1. Create an S3 bucket named `swansalesforcefiles` (or your preferred name).
2. Navigate to `S3 -> Your Bucket -> Permissions -> Cross-origin resource sharing (CORS)`.
3. Click `Edit` and paste the following configuration:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["POST", "GET", "PUT", "DELETE", "HEAD"],
        "AllowedOrigins": [
            "https://creative-wolf-4dpoz7-dev-ed.lightning.force.com",
            "https://creative-wolf-4dpoz7-dev-ed.my.site.com"
        ],
        "ExposeHeaders": ["ETag"],
        "MaxAgeSeconds": 3000
    }
]

```
### Prerequisite

In this guide, we use `https://creative-wolf-4dpoz7-dev-ed.lightning.force.com` as an example. If you plan to utilize the Experience Cloud, additional domains should be added to prevent CORS errors.

### Step 3: Creating an IAM Role and Assigning Policies

#### Creating an IAM Role

1. **Navigate to IAM Roles**: Open the AWS Management Console, go to the IAM service, and select Roles from the sidebar.
2. **Create a New Role**: Click on `Create role` and select `Custom Trust Policy`.
3. **Custom Trust Policy**: Paste the following policy into the editor. This policy configures the trust relationship for your role, allowing actions from specific AWS services and your Salesforce user.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam:::[myAccountIdDontWantToExpose]:user/AmazonFilesUser"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### Creating the Custom IAM Policy

1. **Identify the User ARN**: Refer to the ARN of the IAM user created specifically for Salesforce integration, as mentioned in Step 1 of the setup process. This ARN replaces the placeholder `[myAccountIdDontWantToExpose]:user/AmazonFilesUser` in the policy template.

2. **Navigate to the IAM Role**:
    - In the AWS Management Console, locate the IAM role you created previously for this integration.
    - Access the role's details page by clicking on the role name.
3. **Add Permissions to the Role**:
    - Within the role details page, find the `Permissions` tab.
    - Click on `Add permissions` and select the option to create a new `Inline Policy`.
4. **Define the Policy**:
    - In the policy editor, switch to the JSON view.
    - Copy and paste the following JSON policy structure into the editor:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SalesforcePolicy",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::swansalesforcefiles",
                "arn:aws:s3:::swansalesforcefiles/*"
            ]
        }
    ]
}
```

&nbsp;

## Salesforce Setup

### Step 1: Setup Named Credentials

1. **Navigate to Named Credentials**: In Salesforce, go to the Named Credentials setup page and select the AWS Security Token Service credential.
2. **Edit Named Credential**:
   - Click `Edit`.
   - In the Endpoint URL, replace `https://sts.us-east-1.amazonaws.com` with your AWS region-specific URL: `https://sts.[region].amazonaws.com`. Ensure you replace `[region]` with your actual AWS region, such as `us-east-1`.
   - Click `Save` to apply the changes.

### Step 2: Configure External Credentials

1. **Access External Credentials**: Find the External Credential named AWS User in Salesforce.
2. **Edit External Credential**:
   - Click `Edit`.
   - In the service field, replace `'AwsService'` with `'sts'`.
   - Replace `'AwsRegion'` with your AWS region (e.g., `us-east-1`).
   - For `'AwsAccountId'`, input your AWS Account ID.
3. **Generate AWS Access Keys**:
   - Go to the AWS Management Console, navigate to `IAM -> Users`, and select the user created in previous AWS setup steps.
   - Under the `Security Credentials` tab, click `Create Access Key`. This action is intended for applications running outside AWS.
   - **Important**: Securely store the Access Key ID and Secret Access Key presented to you. Once you navigate away from this page, you will not be able to retrieve the secret key again.
4. **Apply AWS Access Keys in Salesforce**:
   - Return to the Salesforce External Credential configuration page.
   - In the `Principals` section, find the Actions column and click `Edit`.
   - Enter the Access Key ID and Secret Access Key for the AWS User.
   - For the role ARN, input the ARN of the role created during the AWS setup process (e.g., `arn:aws:iam::[myAccountIdDontWantToExpose]:role/SalesforceAmazonFilesRole`). Replace `[myAccountIdDontWantToExpose]` with your actual AWS account ID.
   - Click `Save` to finalize the configuration.

### Step 3: Configure Custom Setting for Amazon Files

1. **Access Custom Settings**:
    - In Salesforce, navigate to `Setup`.
    - Enter `Custom Settings` in the Quick Find box and select `Custom Settings`.
    - Locate `Amazon Files Settings` and click `Manage`.

2. **Add New Custom Setting**:
    - Click the `New` button to create a new custom setting record.
    - In the `Name` field, enter `Default`. **Important**: This is crucial as the name is hardcoded in Apex.
    - For `S3 Bucket Name`, input the name of your AWS S3 bucket (e.g., `swansalesforcefiles`).
    - In the `Region` field, specify the AWS region your S3 bucket resides in (e.g., `us-east-1`).
    - For `AWS Role ARN`, enter the Amazon Resource Name (ARN) of the IAM role created during the AWS setup process. This role provides Salesforce the necessary permissions to access your S3 bucket.
    - Lastly, input the `S3 Bucket ARN` which is the ARN for your S3 bucket obtained in the AWS setup steps.

3. **Save the Configuration**:
    - After entering all the required details, click `Save` to store the custom setting.


### Step 4: Assign Permission Sets for Amazon Files Functionality

Salesforce permission sets are designed to grant users access to various functionalities without changing their profiles. For our AWS S3 integration, two specific permission sets are provided:

### Amazon Files Edit Permission Set

- **Permissions Granted**:
  - This permission set allows users to view, upload, and delete files under any Salesforce records to which they have at least Read access.
- **How to Assign**:
  - Navigate to `Setup` in Salesforce.
  - Enter `Permission Sets` in the Quick Find box, then select `Permission Sets`.
  - Find and select the `Amazon Files Edit` permission set.
  - Click on `Manage Assignments` and then `Add Assignments`.
  - Select the users to whom you wish to grant these permissions and confirm the assignment.

### Amazon Files View Permission Set

- **Permissions Granted**:
  - Users with this permission set can view files under any Salesforce records to which they have at least Read access.
- **How to Assign**:
  - Follow the same steps as for the Amazon Files Edit permission set, but select the `Amazon Files View` permission set instead.

## Step 5: Adding the swan_AmazonFiles Component

The `swan_AmazonFiles` component is designed for easy integration into both Experience Cloud and Salesforce record pages.

### Adding to Salesforce Record Pages

1. **Navigate to the Desired Record Page**:
    - Choose a record page where you wish to add the `swan_AmazonFiles` component, for example, an Account record page.

2. **Edit the Record Page**:
    - Enter the page customization mode by clicking `Edit Page`.

3. **Locate and Add the Component**:
    - In the components panel, find `swan_AmazonFiles`.
    - Drag and drop the component into your desired section on the record page.

4. **Configure the Component**:
    - Set the `Height` property in the component's properties panel to define how much vertical space the component should occupy on the page.

### Adding to Experience Cloud Record Pages

1. **Select the Record Page for Modification**:
    - Open the Experience Builder and navigate to the page where you wish to incorporate the `swan_AmazonFiles` component.

2. **Insert the Component**:
    - Similar to the Salesforce Record Page process, locate the `swan_AmazonFiles` component and add it to the page by dragging and dropping.

3. **Component Configuration**:
    - Set the `Height` property to adjust the component's vertical size according to your layout needs.
    - For the `Record Id` property, ensure to set it as `{!recordId}` to dynamically link the component with the current record's ID.











