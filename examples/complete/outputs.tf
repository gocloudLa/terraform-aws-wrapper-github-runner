output "webhook_endpoint" {
  description = "Webhook URL per runner. Paste this into the GitHub App webhook configuration."
  value       = module.wrapper_gitlab_runner.webhook_endpoint
}
