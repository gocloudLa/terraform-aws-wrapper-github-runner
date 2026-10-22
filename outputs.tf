output "webhook_endpoint" {
  description = "API Gateway webhook endpoint per runner. Set this URL in the GitHub App webhook configuration."
  value = {
    for key, runner in module.github_runner :
    key => runner.webhook.endpoint
  }
}
