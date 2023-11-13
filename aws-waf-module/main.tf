/* resource "aws_wafv2_web_acl" "wafacl" {
  name        = var.webacl_name
  description = "Custom WAFWebACL"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFWebACL-metric"
    sampled_requests_enabled   = true
  }
} */


resource "aws_wafv2_web_acl" "wafacl" {
  name        = var.webacl_name
  description = "Prevent brute forcing password setting or changing"
  scope       = "REGIONAL"       # if using this, no need to set provider

  default_action {
    allow {}    # pass traffic until the rules trigger a block
  }

  rule {
    name     = "RateBasedRule"
    priority = 1

    action {
      block {}
    }
    
    statement {
      rate_based_statement {
        limit              = 100     # Adjust the rate limit as needed
        aggregate_key_type = "IP"
      }
      /* rule_action {
        block {}
      } */
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webacl"
    sampled_requests_enabled   = false
  }

  tags = {
    managedby = "terraform"
  }
}


resource "aws_wafv2_web_acl_association" "attach" {
  resource_arn = "${var.apiarn}/stages/${var.stage_name}"
  web_acl_arn  = aws_wafv2_web_acl.wafacl.arn
}

resource "aws_wafv2_web_acl_association" "attachr" {
  resource_arn = var.user_pool_arn
  web_acl_arn  = aws_wafv2_web_acl.wafacl.arn
}