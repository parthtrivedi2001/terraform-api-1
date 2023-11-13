resource "aws_cognito_user_pool" "pool" {
  name = var.cognito_user_pool_name
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length = 8
    require_numbers = true
    require_lowercase = true
    require_uppercase = true
    require_symbols = true
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "example-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email"]

  callback_urls     = ["https://caxsol.com/"]
  logout_urls = ["http://localhost:3000"]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "examples" {
  domain = "testrrdsfsdr"
  user_pool_id = aws_cognito_user_pool.pool.id
}


output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}
