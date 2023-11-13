import boto3
import datetime

def get_latest_commit_id(repo_name, branch_name):
    codecommit = boto3.client('codecommit')
    response = codecommit.get_branch(repositoryName=repo_name, branchName=branch_name)
    return response['branch']['commitId']

def lambda_handler(event, context):
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    # Replace 'YOUR_REPO_NAME' with the name of your CodeCommit repository
    repo_name = 'aft-account-request'
    region = event.get('region') 
    AccountEmail = event.get('AccountEmail')
    AccountName  = event.get('AccountName')
    ManagedOrganizationalUnit = event.get('ManagedOrganizationalUnit')
    SSOUserEmail     = event.get('SSOUserEmail')
    SSOUserFirstName = event.get('SSOUserFirstName')
    SSOUserLastName  = event.get('SSOUserLastName')
    ProjectId = event.get('ProjectId')
    
    dynamic_module_name = f"sandbox_{timestamp}"
    # Replace 'FILE_CONTENT' with the content of the file you want to push
    file_content_template = '''
module "{module_name}" {

  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "{AccountEmail}"
    AccountName  = "{AccountName}"
    ManagedOrganizationalUnit = "{ManagedOrganizationalUnit}"
    SSOUserEmail     = "{SSOUserEmail}"
    SSOUserFirstName = "{SSOUserFirstName}"
    SSOUserLastName  = "{SSOUserLastName}"
  }

  account_tags = {
    "Owner"       = "demo"
    "ProjectName" = "sspdemo"
  }

  change_management_parameters = {
    change_requested_by = "net.patel.hardik@mhp.com"
    change_reason       = "adding custom parameter"
  }

  custom_fields = {
    securityResponsible = "hardik.patel@caxsol.com"
  }

  account_customizations_name = "sandbox"
}
'''
    
    file_content = file_content_template.replace("{AccountEmail}", AccountEmail)
    file_content = file_content.replace("{AccountName}", AccountName)
    file_content = file_content.replace("{ManagedOrganizationalUnit}", ManagedOrganizationalUnit)
    file_content = file_content.replace("{SSOUserEmail}", SSOUserEmail)
    file_content = file_content.replace("{SSOUserFirstName}", SSOUserFirstName)
    file_content = file_content.replace("{SSOUserLastName}", SSOUserLastName)
    file_content = file_content.replace("{module_name}", dynamic_module_name)

    
    # Replace 'FILE_NAME' with the desired file name
    # timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    file_name = f"sandbox_{timestamp}.tf"
    # file_name = 'main1.tf'
    
    # Replace 'BRANCH_NAME' with the target branch you want to push to
    branch_name = 'main'
    
    # Specify the folder path within the repository
    folder_path = 'terraform/'

    # Append the folder path to the file path
    file_path_with_folder = folder_path + file_name

    codecommit = boto3.client('codecommit')
    
    #Preventive error handling
    
    check_for_errors = error_handler(AccountEmail, AccountName, ManagedOrganizationalUnit)
    

    if check_for_errors == 'Ok':
      insert_to_db(AccountEmail, AccountName, ManagedOrganizationalUnit, SSOUserEmail, SSOUserFirstName, SSOUserLastName, ProjectId)
      # insert_to_db(AccountEmail, AccountName, ManagedOrganizationalUnit, SSOUserEmail, SSOUserFirstName, SSOUserLastName)
      try:
          parent_commit_id = get_latest_commit_id(repo_name, branch_name)
          response = codecommit.put_file(
              repositoryName=repo_name,
              branchName=branch_name,
              fileContent=file_content,
              fileMode='NORMAL',
              filePath=file_path_with_folder,
              parentCommitId=parent_commit_id,
              commitMessage=f'Adding new file: {file_name}',
          )
          print(f'File "{file_name}" pushed successfully!')
          return response
      except Exception as e:
          print(f'Error pushing file: {str(e)}')
          raise e


def insert_to_db(AccountEmail, AccountName, ManagedOrganizationalUnit, SSOUserEmail, SSOUserFirstName, SSOUserLastName, ProjectId):
  dynamodb_client = boto3.client('dynamodb')
  
  try:
    
    response = dynamodb_client.put_item(
    Item={
          'AccountEmail': {
              'S': AccountEmail
          },
          'AccountName': {
              'S': AccountName,
          },
          'ManagedOrganizationalUnit': {
              'S': ManagedOrganizationalUnit
          },
          'SSOUserEmail': {
              'S': SSOUserEmail
          },
          'SSOUserFirstName': {
              'S': SSOUserFirstName
          },
          'SSOUserLastName': {
              'S': SSOUserLastName
          },
          'ProjectId': {
              'S':ProjectId
          },
          'AccountStatus': {
            'S':'PENDING'
          }
      },
    ReturnConsumedCapacity='TOTAL',
    TableName='ssp-table')
  except Exception as e:
    print(f'Error updating dynamodb: {str(e)}')
    raise e
    
  print(response)
    
def error_handler(AccountEmail, AccountName, ManagedOrganizationalUnit ):
    # Create a session using the child account's IAM role
    session = boto3.Session()
    
    # Assume the role of the main account
    sts_client = session.client('sts')
    assumed_role = sts_client.assume_role(
        RoleArn='arn:aws:iam::184379421094:role/CrossAccountAccessRole',
        RoleSessionName='AssumedRoleSession'
    )
    
    # Create a new session using the assumed role credentials
    assumed_session = boto3.Session(
        aws_access_key_id=assumed_role['Credentials']['AccessKeyId'],
        aws_secret_access_key=assumed_role['Credentials']['SecretAccessKey'],
        aws_session_token=assumed_role['Credentials']['SessionToken']
    )
    
    ########### DELETE ALL FAILED PRODUCTS IN SERVICE CATALOG
    service_client = assumed_session.client('servicecatalog')
    
    provisioned_products = service_client.scan_provisioned_products(
      AccessLevelFilter={
        'Key': 'Account',
        'Value': 'self'
      })
      
    for provisioned_product in provisioned_products['ProvisionedProducts']:
      if provisioned_product['Status']=='ERROR':
        service_client.terminate_provisioned_product(
          ProvisionedProductId=provisioned_product['Id'],
          TerminateToken=provisioned_product['Name'],
          IgnoreErrors=True)
    
    print(provisioned_products)
    
    ##################
    
    # List all accounts in the organization
    org_client = assumed_session.client('organizations')
    
    
    accounts_list = org_client.list_accounts()
    
    
    message_sns = "The account creation process failed with the following errors: "
    
    account_name_duplicate = 0
    account_email_duplicate = 0
    
    # Process the response
    for account in accounts_list['Accounts']:
      if account['Email']==AccountEmail:
        account_email_duplicate = 1
        message_sns = message_sns +" Duplicate email error: an account already exists with the selected email."
      if account['Name']==AccountName:
        account_name_duplicate = 1
        message_sns = message_sns+ " Duplicate name error: an account already exists with the selected name."
    
    
    ou_list = org_client.list_organizational_units_for_parent(
      ParentId = 'r-8p2d')
      
    existent_ou = 1
    
    for ou in ou_list['OrganizationalUnits']:
      if ManagedOrganizationalUnit == ou['Name']:
        existent_ou = 0

    if existent_ou==1:
      message_sns = message_sns + " Selected organizational unit doesn't exist. Please select an already existent one."
      
    if account_email_duplicate==1 or account_name_duplicate==1 or existent_ou==1:
      send_error_to_sns(message_sns)
      return "Error"
    
    return "Ok"
      
def send_error_to_sns(Message):
  
  client = boto3.client('sns')
  
  try:
    publish_to_sns = client.publish(
    TopicArn='arn:aws:sns:eu-west-1:020526017978:aft-error-test',
    Message=Message,
    Subject='Failed to start account creation proccess'
  )
  except Exception as e:
    print(str(e))
    raise e
    
    
        
        