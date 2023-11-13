# Create an AWS Amplify app
resource "aws_amplify_app" "my_amplify_app" {
  name                    = var.app_name_amplify
  repository              = var.repository_url
  enable_auto_branch_creation   = true
  enable_branch_auto_deletion   = true
  auto_branch_creation_patterns = ["${var.branch}"]
  auto_branch_creation_config {
    enable_auto_build           = true
    enable_pull_request_preview = false
    enable_performance_mode     = false
    framework                   = "React"
  }

  iam_service_role_arn     = aws_iam_role.amplify_build_role.arn
  build_spec = <<-EOT
    version: 1.0
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT 

  environment_variables = {
    USER_POOL_ID    = "${var.user_pool_arn}"
    CLIENT_ID       = "${var.client_id}"
    API_INVOKE_URL   = "${var.api_endpoint}"
  }

}

# Create an Amplify branch for automatic deployments
resource "aws_amplify_branch" "master" {
  app_id      = aws_amplify_app.my_amplify_app.id
  branch_name = "${var.branch}"
  framework = "React"
  stage     = "PRODUCTION"
}


resource "null_resource" "trigger_amplify_build" {
  triggers = {
    amplify_app_id = aws_amplify_app.my_amplify_app.id
  }
  provisioner "local-exec" {
    command = "aws amplify start-job --app-id ${self.triggers.amplify_app_id} --job-type RELEASE --branch-name ${var.branch}"
  }
  depends_on = [
    aws_amplify_app.my_amplify_app,
    aws_amplify_branch.master,
  ]
}


# Attach necessary permissions to the IAM role for Amplify builds
resource "aws_iam_policy_attachment" "amplify_build_policy_attachment" {
  name       = "amplify-build-policy-attachment"
  policy_arn = aws_iam_policy.policy.arn
  roles      = [aws_iam_role.amplify_build_role.name]
}

# Create an IAM role for Amplify builds
resource "aws_iam_role" "amplify_build_role" {
  name = "amplify-build-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })
}

# Policy

resource "aws_iam_policy" "policy" {
  name        = "amplify_policy"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PushLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Sid": "DescribeLogGroups",
            "Effect": "Allow",
            "Action": "logs:DescribeLogGroups",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        }
    ]
  })
}


# resource "aws_amplify_domain_association" "example" {
#   app_id      = aws_amplify_app.my_amplify_app.id
#   domain_name = "teamdsa.dev"

#   sub_domain {
#     branch_name = aws_amplify_branch.master.branch_name
#     prefix      = ""
#   }
#   sub_domain {
#     branch_name = aws_amplify_branch.master.branch_name
#     prefix      = "www"
#   }
# }


# resource "aws_route53_record" "www" {
#   zone_id = var.host_id
#   name    = "www.teamdsa.dev"
#   type    = "CNAME"
#   ttl     = 60
#   records = [aws_amplify_app.my_amplify_app.default_domain]
# }



