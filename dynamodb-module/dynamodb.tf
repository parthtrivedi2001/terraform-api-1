# Create Dynamodb Table

resource "aws_dynamodb_table" "my_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20

  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_iam_policy" "dynamodb_full_access" {
  name        = "DynamoDBFullAccessPolicy"
  description = "IAM policy providing full access to the MyTable DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "dynamodb:*",
        Effect = "Allow",
        Resource = aws_dynamodb_table.my_table.arn
      },
    ],
  })
}

resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = jsonencode({
    "id": {"S": "1"},
    "AccountEmail": {"S": "example@gmail.com"},
    "AccountId": {"N": "123456789"},
    "AccountName": {"S": "test"},
    "AccountStatus": {"S": "test"},
    "ManagedOrganizationalUnit": {"S": "test"},
    "ProjectId": {"N": "1"},
    "SSOUserEmail": {"S": "test@gmail.com"},
    "SSOUserFirstName": {"S": "test"},
    "SSOUserLastName": {"S": "demo"}
  })
}