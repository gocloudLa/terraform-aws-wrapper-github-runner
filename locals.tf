locals {
  lambda_dir = "${path.module}/modules/lambda"

  webhook_lambda_zip                = "${local.lambda_dir}/webhook.zip"
  runners_lambda_zip                = "${local.lambda_dir}/runners.zip"
  runner_binaries_syncer_lambda_zip = "${local.lambda_dir}/runner-binaries-syncer.zip"

  github_runner_instances = {
    for key, params in var.github_runner_parameters :
    key => params
    if !try(params.assumable_role_enable, var.github_runner_defaults.assumable_role_enable, false)
  }
}
