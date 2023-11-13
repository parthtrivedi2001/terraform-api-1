# Dev account configuration account b 406277425859

# Event Bus
resource "aws_cloudwatch_event_bus" "event_bus_global" {
  name = "accountcreation-awsmhpfoundation-eventfromct"
}
 
# Event Bridge Event Bus Policy
resource "aws_cloudwatch_event_bus_policy" "event_bus_policy" {
  event_bus_name = aws_cloudwatch_event_bus.event_bus_global.name
 
  policy = jsonencode({
   "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowControlTowerToPutEvents",
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::488189875832:root"
    },
    "Action": "events:PutEvents",
    "Resource": "arn:aws:events:ap-south-1:060735869845:event-bus/accountcreation-awsmhpfoundation-eventfromct"
  }],
  })
}

# role for event bus target
data "aws_iam_policy_document" "assume_role_event" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_event" {
  name               = "event_target_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_event.json
}

resource "aws_iam_policy" "policy_lambda_access_event" {
  name        = "account-access-policy_event"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "events:PutEvents"
            ],
            "Resource": [
                "arn:aws:events:ap-south-1:184379421094:event-bus/accountcreation-awsmhpfoundation-eventfromct"
            ]
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_get_event_r" {
  name       = "lambda_execution_policy_get_event"
  roles      = [aws_iam_role.iam_for_lambda_event.name]
  policy_arn = aws_iam_policy.policy_lambda_access_event.arn
}

# Event Bridge Event Rule
resource "aws_cloudwatch_event_rule" "global_to_account_b_rule" {
  name = "accountcreation-awsmhpfoundation-for-lambda"
  event_pattern = jsonencode({
    source      = ["aws.controltower"],
    detail-type = ["AWS Service Event via CloudTrail"],
    detail = {
      eventName = ["UpdateManagedAccount", "CreateManagedAccount"]
    }
  })
  event_bus_name = aws_cloudwatch_event_bus.event_bus_global.name
}


resource "aws_cloudwatch_event_target" "event_target" {
  event_bus_name = aws_cloudwatch_event_bus.event_bus_global.name
  rule      = aws_cloudwatch_event_rule.global_to_account_b_rule.name
  arn       = aws_lambda_function.lambda_accountcreation.arn
  # role_arn = aws_iam_role.iam_for_lambda_event.arn
}



# Lambda Function for this Event Bridge

data "aws_iam_policy_document" "assume_role_accountcreation" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_accountcreation" {
  name               = "accountcreation-awsmhpfoundation-target-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_accountcreation.json
}

resource "aws_iam_policy" "policy_lambda_accountcreation" {
  name        = "AWSLambdaBasic_policy"
  path        = "/"
  description = "My AWSLambdaBasic policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-south-1:406277425859:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-south-1:406277425859:log-group:/aws/lambda/accountcreation-awsmhpfoundation-target:*"
            ]
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_accountcreation" {
  name       = "lambda_execution_policy_accountcreation"
  roles      = [aws_iam_role.iam_for_lambda_accountcreation.name]
  policy_arn = aws_iam_policy.policy_lambda_accountcreation.arn
}

resource "aws_iam_policy_attachment" "dynamodb_policy_accountcreation" {
  name       = "policy_dynamodb_accountcreation"
  roles      = [aws_iam_role.iam_for_lambda_accountcreation.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "archive_file" "accountcreation" {
  type        = "zip"
  source_file = "accountcreation_lambda_function.py"
  output_path = "accountcreation.zip"
}

resource "aws_lambda_function" "lambda_accountcreation" {
  filename      = "accountcreation.zip"
  function_name = var.lambda_function_name5
  role          = aws_iam_role.iam_for_lambda_accountcreation.arn
  handler       = "accountcreation_lambda_function.lambda_handler"
  source_code_hash = data.archive_file.accountcreation.output_base64sha256
  runtime = var.runtime
}

resource "aws_lambda_permission" "allow_event" {
  function_name = aws_lambda_function.lambda_accountcreation.function_name
  statement_id  = "AllowExecutionFromEvents"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    =  "${aws_cloudwatch_event_rule.global_to_account_b_rule.arn}"
}