# Output the Amplify app endpoint
output "amplify_app_endpoint" {
  value = "https://master.${aws_amplify_app.my_amplify_app.default_domain}"
}