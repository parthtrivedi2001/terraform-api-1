module "cognito-module" {
  source               = "./cognito-module"
  cognito_user_pool_name  = var.cognito_user_pool_name
}

/* module "amplify-module" {
  # host_id = module.route-53-module.host_id
  source               = "./amplify-module"
  api_endpoint         = module.api-lambda-module.api_endpoint
  user_pool_arn        = module.cognito-module.user_pool_arn
  client_id            = module.cognito-module.client_id
  branch               = var.branch
  app_name_amplify     = var.app_name_amplify
  repository_url       = var.repository_url
  account_no           = var.account_no
} */

module "api-lambda-module" {
  source           = "./api-gateway-lambda-module"
  apiname = var.apiname
  stage_name = var.stage_name
  resource_name = var.resource_name
  resource_name1 = var.resource_name1
  method = var.method
  method1 = var.method1
  method2 = var.method2
  method3 = var.method3
  region = var.region
  account_no = var.account_no
  user_pool_arn = module.cognito-module.user_pool_arn
  lambda_function_name = var.lambda_function_name
  lambda_function_name1 = var.lambda_function_name1
  lambda_function_name2 = var.lambda_function_name2
  lambda_function_name3 = var.lambda_function_name3
  lambda_function_name4 = var.lambda_function_name4
  lambda_function_name5 = var.lambda_function_name5
  lambda_function_name6 = var.lambda_function_name6
  event_bus_arn_devaccount_b = module.dev-account.event_bus_arn_devaccount_b
  runtime = var.runtime
}


module "dev-account" {
  source           = "./dev-account"
  lambda_function_name5 = var.lambda_function_name5
  runtime = var.runtime
}

# module "main-account" {
#   source           = "./main-account"
#   event_bus_arn_devaccount_b = module.dev-account.event_bus_arn_devaccount_b
#   providers = {
#     aws = aws.mainaccount
#   }
# }


/* module "dynamodb-module" {
  source           = "./dynamodb-module"
  dynamodb_table_name = var.dynamodb_table_name
} */

/* module "aws-waf-module" {
  user_pool_arn        = module.cognito-module.user_pool_arn
  apiarn               = module.api-lambda-module.apiarn
  source               = "./aws-waf-module"
  webacl_name   = var.webacl_name
  ip_set_rule_name  = var.ip_set_rule_name
  ipsetname = var.ipsetname
  stage_name = var.stage_name
} */


# module "codecommit-module" {
#   source               = "./codecommit-module"
# }
