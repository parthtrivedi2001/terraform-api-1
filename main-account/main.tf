# Main account configuration account a 184379421094

# Event bridge rule

# role for event bus target main account

data "aws_iam_policy_document" "assume_role_main" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_main" {
  name               = "event_target_main_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_main.json
}

resource "aws_iam_policy" "policy_lambda_access_main" {
  name        = "Amazon_EventBridge_Invoke_Event_Bus_Main"
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
                "arn:aws:events:eu-west-1:020526017978:event-bus/accountcreation-awsmhpfoundation-eventfromct"
            ]
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy_get_event" {
  name       = "lambda_execution_policy_get_event"
  roles      = [aws_iam_role.iam_for_lambda_main.name]
  policy_arn = aws_iam_policy.policy_lambda_access_main.arn
}

# Event Bridge Event Rule
resource "aws_cloudwatch_event_rule" "global_to_account_b_rule" {
  name = "aft-awsmhpfoundation-accountcreation-rule"
  event_pattern = jsonencode({
    source = ["aws.controltower"],
    detail-type = ["AWS Service Event via CloudTrail"],
    detail = {
      eventName = ["UpdateManagedAccount", "CreateManagedAccount"]
    }
  })
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.global_to_account_b_rule.name
  arn       = var.event_bus_arn_devaccount_b
  role_arn = aws_iam_role.iam_for_lambda_main.arn
  dead_letter_config {
    arn = aws_sqs_queue.terraform_queue_redrive_policy.arn
  }
}

# SQS

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "EventBridgeDLQ"
}

resource "aws_sqs_queue_policy" "terraform_queue_policy_dead" {
  queue_url = aws_sqs_queue.terraform_queue_deadletter.url
  policy    = jsonencode({
    "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::184379421094:root"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:eu-west-1:184379421094:EventBridgeDLQ"
    }
  ]
  })
}

resource "aws_sqs_queue" "terraform_queue_redrive_policy" {
  name = "EventBridgeQueue"
  delay_seconds             = 90
  max_message_size          = 262144
  message_retention_seconds = 355600
  visibility_timeout_seconds = 30
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_policy" "terraform_queue_policy" {
  queue_url = aws_sqs_queue.terraform_queue_redrive_policy.url
  policy    = jsonencode({
    "Version": "2012-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
      {
        "Sid": "__owner_statement",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::184379421094:root"
        },
        "Action": "SQS:*",
        "Resource": aws_sqs_queue.terraform_queue_redrive_policy.arn
      },
      {
        "Sid": "AWSEvents_aft-account-creation-event-rule_dlq_Idab052118-89c5-4250-94f6-78d5612772b4",
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sqs:SendMessage",
        "Resource": aws_sqs_queue.terraform_queue_redrive_policy.arn,
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "arn:aws:events:eu-west-1:184379421094:rule/aft-account-creation-event-rule"
          }
        }
      }
    ]
  })
}




