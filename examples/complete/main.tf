module "wrapper_gitlab_runner" {
  source = "../../"

  metadata = local.metadata

  github_runner_parameters = {
    "fixed" = {
      create_service_linked_role_spot = true
      aws_region                      = local.metadata.aws_region

      github_app = {
        key_base64     = "var.key_base64"
        id             = "var.id"
        webhook_secret = "var.webhook_secret"
      }

      enable_organization_runners             = false
      runner_extra_labels                     = ["fixed"]
      scale_up_reserved_concurrent_executions = -1
      instance_types                          = ["t3.small", "t3.medium"]
      delay_webhook_event                     = 0
      runners_maximum_count                   = 1
      scale_down_schedule_expression          = "cron(* * * * ? *)"

      enable_ephemeral_runners = false

      idle_config = [{
        cron      = "* * * * ? *"
        timeZone  = "America/Argentina/Buenos_Aires"
        idleCount = 1
      }]

      job_retry = {
        enable = false
      }
    }
    "ephemeral" = {
      create_service_linked_role_spot = true
      aws_region                      = local.metadata.aws_region

      github_app = {
        key_base64     = "var.key_base64"
        id             = "var.id"
        webhook_secret = "var.webhook_secret"
      }

      enable_organization_runners             = false
      runner_extra_labels                     = ["ephemeral"]
      scale_up_reserved_concurrent_executions = -1
      instance_types                          = ["t3.small", "t3.medium"]
      delay_webhook_event                     = 0
      runners_maximum_count                   = 5
      scale_down_schedule_expression          = "cron(* * * * ? *)"

      enable_ephemeral_runners = true

      job_retry = {
        enable = false
      }
    }

    # SHARED RUNNER CONFIGURATION

    # "shared" = {
    #   create_service_linked_role_spot = true
    #   aws_region                      = local.metadata.aws_region

    #   github_app = {
    #     key_base64     = "var.key_base64"
    #     id             = "var.id"
    #     webhook_secret = "var.webhook_secret"
    #   }

    #   enable_ephemeral_runners                = false
    #   runner_extra_labels                     = ["fixed"]
    #   scale_up_reserved_concurrent_executions = -1
    #   delay_webhook_event                     = 0
    #   instance_types                          = ["t3.small", "t3.medium"]
    #   runners_maximum_count                   = 5
    #   scale_down_schedule_expression          = "cron(* * * * ? *)"

    #   idle_config = [{
    #     cron      = "* * * * ? *"
    #     timeZone  = "America/Argentina/Buenos_Aires"
    #     idleCount = 1
    #   }]

    #   job_retry = {
    #     enable = false
    #   }

    #   assumable_roles_arn = [
    #     "arn:aws:iam::111111111111:role/dmc-dev-github-runner-assumable",
    #     "arn:aws:iam::222222222222:role/dmc-stg-github-runner-assumable",
    #   ] # Allow Runner to Asume external roles
    #   # assumable_roles_arn = ["*"] # Allow Runner to Asume external roles
    # }

    # ASSUMED ROLE CONFIGURATION
    # "from-central" = {
    #   # CONFIG FOR JUST CREATING THE ROLE AND GIVING ACCESS TO AN EXTERN RUNNER ( shared )
    #   assumable_role_enable = true

    #   # Shared Runner Instance Role ARN
    #   assumable_role_trusted_role_arn = "arn:aws:iam::111111111111:role/dmc-lab/dmc-lab-runner-xxxx"
    #   # Insecure Option, allow an external account to assume this role
    #   # assumable_role_trusted_role_arn = "arn:aws:iam::760660567625:root"

    #   # Permisos que podra ejercer el runner al asumir este rol (listar RDS y S3).
    #   assumable_role_policy_json = data.aws_iam_policy_document.assumed_permissions.json
    # }
  }
}
