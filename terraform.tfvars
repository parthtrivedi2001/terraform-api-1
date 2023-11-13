# API POST
apiname = "ssp-test-api"
stage_name = "Dev"
resource_name = "account"
resource_name1 = "projects"
region = "ap-south-1"
account_no = "060735869845"

# API Method 
method = "POST"
method1 = "GET"
method2 = "PUT"
method3 = "DELETE"

# Dynamo DB
dynamodb_table_name = "ssp-test-table"


# Lambda Function
lambda_function_name = "post_lambda_function"
lambda_function_name1 = "get_lambda_function"
lambda_function_name2 = "ssp-mhpawsfoundation-emailcheck"
lambda_function_name3 = "ssp-mhpawsfoundation-fetchemail"
lambda_function_name4 = "ssp-mhpawsfoundation-accountrequest"
lambda_function_name5 = "accountcreation-awsmhpfoundation-target"
lambda_function_name6 = "myfunction"
runtime = "python3.7"

# AWS WAF
webacl_name = "ssp-test-webacl"
ip_set_rule_name = "testipset"
ipsetname = "ipset"

# Amplify
app_name_amplify = "SSP-TEST-APP"
repository_url   = "https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/sample-react-code"
branch           = "main"

# Cognito
cognito_user_pool_name = "ssptestuserpool"
