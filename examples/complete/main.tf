module "wrapper_gitlab_runner" {
  source = "../../"

  metadata = local.metadata

  github_runner_parameters = {
    "fixed" = {
      create_service_linked_role_spot = true
      aws_region                      = local.metadata.aws_region

      github_app = {
        key_base64     = ""
        id             = ""
        webhook_secret = ""
      }

      enable_organization_runners             = false
      runner_extra_labels                     = ["fixed", "example"]
      scale_up_reserved_concurrent_executions = -1
      instance_types                          = ["t3.small", "t3.medium"]
      delay_webhook_event                     = 0
      runners_maximum_count                   = 20
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
        key_base64     = ""
        id             = ""
        webhook_secret = ""
      }

      enable_organization_runners             = false
      runner_extra_labels                     = ["ephemeral", "example"]
      scale_up_reserved_concurrent_executions = -1
      instance_types                          = ["t3.small", "t3.medium"]
      delay_webhook_event                     = 0
      runners_maximum_count                   = 20
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
    #     key_base64     = "<BASE64_PEM>"
    #     id             = "5242194"
    #     webhook_secret = "a3f91c7d2e8b4a6f0123456789abcdef12345678"
    #   }

    #   enable_ephemeral_runners = false
    #   runner_extra_labels      = ["shared", "example"]
    #   instance_types           = ["t3.small", "t3.medium"]
    #   runners_maximum_count    = 20

    #   assumable_roles_arn = [
    #     "arn:aws:iam::111111111111:role/dmc-dev-github-runner-assumable",
    #     "arn:aws:iam::222222222222:role/dmc-stg-github-runner-assumable",
    #   ]
    #   # assumable_roles_arn = ["*"]
    # }

    # ASSUMED ROLE CONFIGURATION
    # "from-central" = {
    #   CONFIG FOR JUST CREATING THE ROLE AND GIVING ACCESS TO AN EXTERN RUNNER ( shared )
    #   assumable_role_enable = true

    #   Shared Runner Instance Role ARN
    #   assumable_role_trusted_role_arn = "arn:aws:iam::999999999999:role/dmc-sha-github-runner"
    #   # Insecure Option, allow an external account to assume this role
    #   # assumable_role_trusted_role_arn = "arn:aws:iam::999999999999:root"

    #   # assumable_role_policy_json = data.aws_iam_policy_document.this.json
    # }
  }
}
