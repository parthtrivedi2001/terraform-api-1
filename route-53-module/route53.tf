resource "aws_route53_zone" "dev" {
  name = "teamdsa.dev"

  tags = {
    Environment = "test"
  }
}

