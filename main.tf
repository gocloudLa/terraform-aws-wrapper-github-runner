module "github_runner" {
  source = "git::https://github.com/github-aws-runners/terraform-aws-github-runner.git?ref=v7.11.0"

  for_each = local.github_runner_instances

  aws_region = try(each.value.aws_region, var.github_runner_defaults.aws_region, data.aws_region.current.name)
  vpc_id     = data.aws_vpc.this[each.key].id
  subnet_ids = tolist(data.aws_subnets.this[each.key].ids)

  prefix = try(each.value.prefix, var.github_runner_defaults.prefix, local.common_name)

  webhook_lambda_zip                = local.webhook_lambda_zip
  runners_lambda_zip                = local.runners_lambda_zip
  runner_binaries_syncer_lambda_zip = local.runner_binaries_syncer_lambda_zip

  github_app = try(each.value.github_app, var.github_runner_defaults.github_app, null)

  create_service_linked_role_spot         = try(each.value.create_service_linked_role_spot, var.github_runner_defaults.create_service_linked_role_spot, null)
  enable_ephemeral_runners                = try(each.value.enable_ephemeral_runners, var.github_runner_defaults.enable_ephemeral_runners, false)
  enable_job_queued_check                 = try(each.value.enable_job_queued_check, var.github_runner_defaults.enable_job_queued_check, null)
  idle_config                             = try(each.value.idle_config, var.github_runner_defaults.idle_config, [])
  runner_extra_labels                     = try(each.value.runner_extra_labels, var.github_runner_defaults.runner_extra_labels, [])
  instance_types                          = try(each.value.instance_types, var.github_runner_defaults.instance_types, ["t3.small", "t3.medium"])
  runners_maximum_count                   = try(each.value.runners_maximum_count, var.github_runner_defaults.runners_maximum_count, null)
  enable_organization_runners             = try(each.value.enable_organization_runners, var.github_runner_defaults.enable_organization_runners, false)
  scale_up_reserved_concurrent_executions = try(each.value.scale_up_reserved_concurrent_executions, var.github_runner_defaults.scale_up_reserved_concurrent_executions, 1)
  enable_ssm_on_runners                   = try(each.value.enable_ssm_on_runners, var.github_runner_defaults.enable_ssm_on_runners, true)
  delay_webhook_event                     = try(each.value.delay_webhook_event, var.github_runner_defaults.delay_webhook_event, 30)
  scale_down_schedule_expression          = try(each.value.scale_down_schedule_expression, var.github_runner_defaults.scale_down_schedule_expression, "cron(*/5 * * * ? *)")
  job_retry                               = try(each.value.job_retry, var.github_runner_defaults.job_retry, null)
  enable_userdata                         = try(each.value.enable_userdata, var.github_runner_defaults.enable_userdata, true)
  ami                                     = try(each.value.ami, var.github_runner_defaults.ami, null)

  tags = merge(local.common_tags, try(each.value.tags, var.github_runner_defaults.tags, {}))
}

/*----------------------------------------------------------------------*/
/* Shared Runner (cuenta central)                                       */
/*----------------------------------------------------------------------*/
resource "aws_iam_policy" "assume_external_roles" {
  for_each = {
    for key, params in local.github_runner_instances :
    key => params
    if try(params.assumable_roles_arn, var.github_runner_defaults.assumable_roles_arn, null) != null
  }

  name   = "${try(each.value.prefix, var.github_runner_defaults.prefix, local.common_name)}-${each.key}-assume-external"
  path   = "/"
  policy = data.aws_iam_policy_document.assume_external_roles[each.key].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "assume_external_roles" {
  for_each = aws_iam_policy.assume_external_roles

  role       = module.github_runner[each.key].runners.role_runner.name
  policy_arn = each.value.arn
}

/*----------------------------------------------------------------------*/
/* Assumed Role (cuentas externas)                                      */
/*----------------------------------------------------------------------*/
resource "aws_iam_role" "assumable" {
  for_each = {
    for key, params in var.github_runner_parameters :
    key => params
    if try(params.assumable_role_enable, var.github_runner_defaults.assumable_role_enable, false)
  }

  name                 = "${try(each.value.prefix, var.github_runner_defaults.prefix, local.common_name)}-${each.key}-assumable"
  path                 = "/"
  max_session_duration = try(each.value.assumable_role_max_session_duration, var.github_runner_defaults.assumable_role_max_session_duration, 3600)
  assume_role_policy   = data.aws_iam_policy_document.assumable_trust[each.key].json

  tags = local.common_tags
}

resource "aws_iam_policy" "assumable" {
  for_each = {
    for key, params in var.github_runner_parameters :
    key => params
    if try(params.assumable_role_enable, var.github_runner_defaults.assumable_role_enable, false)
    && try(params.assumable_role_policy_json, var.github_runner_defaults.assumable_role_policy_json, null) != null
  }

  name   = "${try(each.value.prefix, var.github_runner_defaults.prefix, local.common_name)}-${each.key}-assumable"
  path   = "/"
  policy = try(each.value.assumable_role_policy_json, var.github_runner_defaults.assumable_role_policy_json)

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "assumable" {
  for_each = aws_iam_policy.assumable

  role       = aws_iam_role.assumable[each.key].name
  policy_arn = each.value.arn
}
