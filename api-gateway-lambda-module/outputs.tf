output "apiarn" {
  value = aws_api_gateway_rest_api.api.arn
}

output "api_endpoint" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
