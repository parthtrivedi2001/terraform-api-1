data "aws_iam_policy_document" "assume_role_get" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_get" {
  name               = "role_for_get_lambda_function"
  assume_role_policy = data.aws_iam_policy_document.assume_role_get.json
}

resource "aws_iam_policy" "policy_lambda_get" {
  name        = "policy_get_lambda"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_get" {
  name       = "lambda_execution_policy_get"
  roles      = [aws_iam_role.iam_for_lambda_get.name]
  policy_arn = aws_iam_policy.policy_lambda_get.arn
}

resource "aws_iam_policy_attachment" "dynamodb_policy_get" {
  name       = "policy_dynamodb_get"
  roles      = [aws_iam_role.iam_for_lambda_get.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}



# 2 Lambda Function

data "archive_file" "lambda1" {
  type        = "zip"
  source_file = "get_lambda_function.py"
  output_path = "lambda1.zip"
}


resource "aws_lambda_function" "test_lambda1" {
  filename      = "lambda1.zip"
  function_name = var.lambda_function_name1
  role          = aws_iam_role.iam_for_lambda_get.arn
  handler       = "get_lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda1.output_base64sha256
  runtime = var.runtime
}


# email check lambda

data "aws_iam_policy_document" "assume_role_emailcheck" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_emailcheck" {
  name               = "role_for_emailcheck_lambda_function"
  assume_role_policy = data.aws_iam_policy_document.assume_role_emailcheck.json
}

resource "aws_iam_policy" "policy_lambda_emailcheck" {
  name        = "policy_emailcheck_lambda"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_emailcheck" {
  name       = "lambda_execution_policy_emailcheck"
  roles      = [aws_iam_role.iam_for_lambda_emailcheck.name]
  policy_arn = aws_iam_policy.policy_lambda_emailcheck.arn
}


data "archive_file" "lambdaemailcheck" {
  type        = "zip"
  source_file = "emailcheck_lambda_function.py"
  output_path = "emailcheck.zip"
}

resource "aws_lambda_function" "lambda_email" {
  filename      = "emailcheck.zip"
  function_name = var.lambda_function_name2
  role          = aws_iam_role.iam_for_lambda_emailcheck.arn
  handler       = "emailcheck_lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambdaemailcheck.output_base64sha256
  runtime = var.runtime
}



# email fetch lambda

data "aws_iam_policy_document" "assume_role_emailfetch" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_emailfetch" {
  name               = "role_for_emailfetch_lambda_function"
  assume_role_policy = data.aws_iam_policy_document.assume_role_emailfetch.json
}

resource "aws_iam_policy" "policy_lambda_emailfetch" {
  name        = "policy_emailfetch_lambda"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_emailfetch" {
  name       = "lambda_execution_policy_emailfetch"
  roles      = [aws_iam_role.iam_for_lambda_emailfetch.name]
  policy_arn = aws_iam_policy.policy_lambda_emailfetch.arn
}

resource "aws_iam_policy_attachment" "dynamodb_policy_emailfetch" {
  name       = "policy_dynamodb_getemailfetch"
  roles      = [aws_iam_role.iam_for_lambda_emailfetch.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


data "archive_file" "lambdaemailfetch" {
  type        = "zip"
  source_file = "emailfetch_lambda_function.py"
  output_path = "emailfetch.zip"
}

resource "aws_lambda_function" "lambda_emailfetch" {
  filename      = "emailfetch.zip"
  function_name = var.lambda_function_name3
  role          = aws_iam_role.iam_for_lambda_emailfetch.arn
  handler       = "emailfetch_lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambdaemailfetch.output_base64sha256
  runtime = var.runtime
}



# ssp-mhpawsfoundation-accountrequest

data "aws_iam_policy_document" "assume_role_accountrequest" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_accountrequest" {
  name               = "role_for_accountrequest_lambda_function"
  assume_role_policy = data.aws_iam_policy_document.assume_role_accountrequest.json
}

resource "aws_iam_policy" "policy_lambda_accountrequest" {
  name        = "policy_accountrequest_lambda"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_accountrequest" {
  name       = "lambda_execution_policy_accountrequest"
  roles      = [aws_iam_role.iam_for_lambda_accountrequest.name]
  policy_arn = aws_iam_policy.policy_lambda_accountrequest.arn
}

data "archive_file" "accountrequest" {
  type        = "zip"
  source_file = "accountrequest_lambda_function.py"
  output_path = "accountrequest.zip"
}

resource "aws_lambda_function" "lambda_accountrequest" {
  filename      = "accountrequest.zip"
  function_name = var.lambda_function_name4
  role          = aws_iam_role.iam_for_lambda_emailfetch.arn
  handler       = "accountrequest_lambda_function.lambda_handler"
  source_code_hash = data.archive_file.accountrequest.output_base64sha256
  runtime = var.runtime
}

# ONE API AND 2 Method POST & GET


resource "aws_iam_role" "step_function_role" {
  name = "APIGatewayToStepFunctions"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "step_function_attachment_cl" {
  name       = "step-function-attachment_cloudlogs"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  roles      = [aws_iam_role.step_function_role.name]
}

resource "aws_iam_policy_attachment" "step_function_attachment_asf" {
  name       = "step-function-attachment_asf"
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  roles      = [aws_iam_role.step_function_role.name]
}

# API POST Method 

resource "aws_api_gateway_rest_api" "api" {
  name        = var.apiname
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = var.stage_name
  depends_on  = [ aws_api_gateway_integration.request_method_integration, aws_api_gateway_integration_response.response_method_integration,aws_api_gateway_integration.request_method_integration_get, aws_api_gateway_integration_response.response_method_integration_get ]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = var.resource_name
}

resource "aws_api_gateway_resource" "proxy1" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = var.resource_name1
}

resource "aws_api_gateway_resource" "proxy2" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.proxy1.id}"
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = var.method
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"
  type        = "AWS"
  uri         = "arn:aws:apigateway:${var.region}:states:action/StartExecution"
  integration_http_method = var.method
  credentials = aws_iam_role.step_function_role.arn
  request_templates = {
    "application/json" = <<EOF

#set($data = $util.escapeJavaScript($input.json('$'))) 
{ 
  "input": "$data", 
  "stateMachineArn": "${aws_sfn_state_machine.sfn_state_machine.arn}"
}

EOF
  }
}

resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method_response.response_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method.status_code}"

  # response_templates = {
  #   "application/json" = ""
  # }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
  # Add the response_templates section for mapping
  response_templates = {
    "application/json" = <<EOF
#set ($bodyObj = $util.parseJson($input.body))
#if ($bodyObj.status == "SUCCEEDED")
    $bodyObj.output
#elseif ($bodyObj.status == "FAILED")
    #set($context.responseOverride.status = 500)
    {
        "cause": "$bodyObj.cause",
        "error": "$bodyObj.error"
    }
#else
    #set($context.responseOverride.status = 500)
    $input.body
#end
EOF
  }
}




# GET Method

resource "aws_api_gateway_method" "request_method_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = var.method1
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.request_method_get.http_method}"
  type        = "AWS"
  uri         = "${aws_lambda_function.test_lambda1.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration_get.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method_response.response_method_get.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method_get.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
}

resource "aws_lambda_permission" "allow_api_gateway_get" {
  function_name = aws_lambda_function.test_lambda1.function_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "arn:aws:execute-api:${var.region}:${var.account_no}:${aws_api_gateway_rest_api.api.id}/*/${var.method1}${aws_api_gateway_resource.proxy.path}"
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy]
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name          = "sspauth"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  provider_arns = [var.user_pool_arn]
}

# aws step function

# Create IAM role for AWS Step Function
resource "aws_iam_role" "iam_for_sfn" {
  name = "stepFunctionSampleStepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


// Attach policy to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_cloudwatchlogs" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "state-machine"
  role_arn = "${aws_iam_role.iam_for_sfn.arn}"
  type     = "EXPRESS"
  publish  = true
  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "ssp-email-check",
  "States": {
    "ssp-email-check": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.lambda_email.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 3,
          "MaxAttempts": 3,
          "BackoffRate": 1
        }
      ],
      "Next": "Choice",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Error Notification"
        }
      ]
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.email_status",
          "StringMatches": "Valid",
          "Next": "EmailValid"
        },
        {
          "Variable": "$.email_status",
          "StringMatches": "Invalid",
          "Next": "ssp-fetch-email"
        }
      ]
    },
    "ssp-fetch-email": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.lambda_emailfetch.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "EmailStatus",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Error Notification"
        }
      ]
    },
    "EmailStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.email_status",
          "StringMatches": "Valid",
          "Next": "EmailFetch"
        }
      ],
      "Default": "Error Notification"
    },
    "Error Notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message.$": "$",
        "TopicArn": "arn:aws:sns:ap-south-1:648457118085:test"
      },
      "Next": "Fail"
    },
    "EmailFetch": {
      "Type": "Pass",
      "Next": "ssp-account-request-New"
    },
    "ssp-account-request-New": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.lambda_accountrequest.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Error Notification"
        }
      ],
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    },
    "EmailValid": {
      "Type": "Pass",
      "Next": "ssp-account-request-New"
    },
    "Fail": {
      "Type": "Fail"
    }
  }
}
EOF

logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.log_group_for_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
  name = "/aws/states/ssp-mhpawsfoundation-statemachinelog"
}







# my function lambda

data "aws_iam_policy_document" "assume_role_myfunction" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_myfunction" {
  name               = "role_for_myfunction"
  assume_role_policy = data.aws_iam_policy_document.assume_role_myfunction.json
}

resource "aws_iam_policy" "policy_lambda_myfunction" {
  name        = "policy_myfunction"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_myfunction" {
  name       = "lambda_execution_policy_myfunction"
  roles      = [aws_iam_role.iam_for_lambda_myfunction.name]
  policy_arn = aws_iam_policy.policy_lambda_myfunction.arn
}

data "archive_file" "lambdamyfunction" {
  type        = "zip"
  source_file = "myfunction.py"
  output_path = "myfunction.zip"
}

resource "aws_lambda_function" "lambda_myfunction" {
  filename      = "myfunction.zip"
  function_name = var.lambda_function_name6
  role          = aws_iam_role.iam_for_lambda_myfunction.arn
  handler       = "myfunction.lambda_handler"
  source_code_hash = data.archive_file.lambdamyfunction.output_base64sha256
  runtime = var.runtime
}



# GET & PUT Method for myfunction lambda

resource "aws_api_gateway_method" "request_method_get_myfunction" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy1.id}"
  http_method   = var.method1
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration_get_myfunction" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_method.request_method_get_myfunction.http_method}"
  type        = "AWS"
  uri         = "${aws_lambda_function.lambda_myfunction.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_get_myfunction" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration_get_myfunction.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_get_myfunction" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_method_response.response_method_get_myfunction.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method_get_myfunction.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
}

resource "aws_lambda_permission" "allow_api_gateway_get_myfunction" {
  function_name = aws_lambda_function.lambda_myfunction.function_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "arn:aws:execute-api:${var.region}:${var.account_no}:${aws_api_gateway_rest_api.api.id}/*/${var.method1}${aws_api_gateway_resource.proxy1.path}"
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy1]
}



# PUT

resource "aws_api_gateway_method" "request_method_get_myfunction_put" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy1.id}"
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration_get_myfunction_put" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_method.request_method_get_myfunction_put.http_method}"
  type        = "AWS"
  uri         = "${aws_lambda_function.lambda_myfunction.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_get_myfunction_put" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration_get_myfunction_put.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_get_myfunction_put" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy1.id}"
  http_method = "${aws_api_gateway_method_response.response_method_get_myfunction_put.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method_get_myfunction_put.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
}

resource "aws_lambda_permission" "allow_api_gateway_get_myfunction_put" {
  function_name = aws_lambda_function.lambda_myfunction.function_name
  statement_id  = "AllowExecutionFromApiGateways"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "arn:aws:execute-api:${var.region}:${var.account_no}:${aws_api_gateway_rest_api.api.id}/*/${var.method2}${aws_api_gateway_resource.proxy1.path}"
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy1]
}


# GET METHOD in ID resource 


resource "aws_api_gateway_method" "request_method_get_get_id" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy2.id}"
  http_method   = var.method1
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration_get_get_id" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_method.request_method_get_get_id.http_method}"
  type        = "AWS"
  uri         = "${aws_lambda_function.lambda_myfunction.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_get_get_id" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration_get_get_id.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_get_get_id" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_method_response.response_method_get_get_id.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method_get_get_id.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
}

resource "aws_lambda_permission" "allow_api_gateway_get_get_id" {
  function_name = aws_lambda_function.lambda_myfunction.function_name
  statement_id  = "AllowExecutionFromApiGatewayt"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "arn:aws:execute-api:${var.region}:${var.account_no}:${aws_api_gateway_rest_api.api.id}/*/${var.method1}${aws_api_gateway_resource.proxy2.path}"
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy2]
}


# DELETE METHOD in ID resource 


resource "aws_api_gateway_method" "request_method_get_delete" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy2.id}"
  http_method   = var.method3
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "request_method_integration_get_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_method.request_method_get_delete.http_method}"
  type        = "AWS"
  uri         = "${aws_lambda_function.lambda_myfunction.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_get_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration_get_delete.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-headers" = true
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_get_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy2.id}"
  http_method = "${aws_api_gateway_method_response.response_method_get_delete.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method_get_delete.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-headers" = "'Access-Control-Allow-Origin, Authorization , Content-Type'"
  }
}

resource "aws_lambda_permission" "allow_api_gateway_get_delete" {
  function_name = aws_lambda_function.lambda_myfunction.function_name
  statement_id  = "AllowExecutionFromApiGatewayts"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "arn:aws:execute-api:${var.region}:${var.account_no}:${aws_api_gateway_rest_api.api.id}/*/${var.method3}${aws_api_gateway_resource.proxy2.path}"
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy2]
}