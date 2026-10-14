data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*----------------------------------------------------------------------*/
/* NetWorking | datasources                                             */
/*----------------------------------------------------------------------*/
data "aws_vpc" "this" {
  for_each = local.github_runner_instances

  filter {
    name = "tag:Name"
    values = [
      try(each.value.vpc_name, local.default_vpc_name)
    ]
  }
}

data "aws_subnets" "this" {
  for_each = local.github_runner_instances

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this[each.key].id]
  }

  tags = {
    Name = try(each.value.subnet_name, local.default_subnet_name)
  }
}

/*----------------------------------------------------------------------*/
/* Shared Runner                                                        */
/*----------------------------------------------------------------------*/
data "aws_iam_policy_document" "assume_external_roles" {
  for_each = {
    for key, params in local.github_runner_instances :
    key => params
    if try(params.assumable_roles_arn, var.github_runner_defaults.assumable_roles_arn, null) != null
  }

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = try(each.value.assumable_roles_arn, var.github_runner_defaults.assumable_roles_arn)
  }
}

/*----------------------------------------------------------------------*/
/* Assumed Role                                                         */
/*----------------------------------------------------------------------*/
data "aws_iam_policy_document" "assumable_trust" {
  for_each = {
    for key, params in var.github_runner_parameters :
    key => params
    if try(params.assumable_role_enable, var.github_runner_defaults.assumable_role_enable, false)
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [try(each.value.assumable_role_trusted_role_arn, var.github_runner_defaults.assumable_role_trusted_role_arn)]
    }
  }
}
