# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform GitHub Runner Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-github-runner/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-github-runner.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-github-runner.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-github-runner/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for GitHub Runner simplifies the configuration of self-hosted, auto-scaling GitHub Actions runners in the AWS cloud.

### ✨ Features

- 🏃‍♀️ [Shared Runner](#shared-runner) - Central GitHub Runner that can assume roles in external accounts

- 🔑 [Assumed Role](#assumed-role) - Generates IAM roles for external GitHub Runner access

- 📦 [Vendored Lambdas](#vendored-lambdas) - Lambda release artifacts bundled with the wrapper




## 🚀 Quick Start
```hcl
github_runner_parameters = {
    "fixed" = {
      aws_region = "us-east-1"

      github_app = {
        id             = "123456"
        key_base64     = var.github_app_key_base64
        webhook_secret = var.github_app_webhook_secret
      }

      runner_extra_labels   = ["fixed"]
      instance_types        = ["t3.small", "t3.medium"]
      runners_maximum_count = 20

      # Keep 1 instance always running
      enable_ephemeral_runners = false
      idle_config = [{
        cron      = "* * * * ? *"
        timeZone  = "America/Argentina/Buenos_Aires"
        idleCount = 1
      }]

      # Network Settings
      # vpc_name    = "dmc-prd"           # Default: "${local.common_name}"
      # subnet_name = "dmc-prd-private*"  # Default: "${local.common_name}-private*"
    }
  }
```


## 🔧 Additional Features Usage

### Shared Runner
Configure a central GitHub Runner that can assume roles in other AWS accounts. A policy with `sts:AssumeRole` towards the ARNs listed in `assumable_roles_arn` is attached to the runner instance role, so jobs running on the central account can deploy to external accounts.


<details><summary>Configuration Code</summary>

```hcl
github_runner_parameters = {
    "shared" = {
      aws_region = "us-east-1"

      github_app = {
        id             = "123456"
        key_base64     = var.github_app_key_base64
        webhook_secret = var.github_app_webhook_secret
      }

      enable_ephemeral_runners = false
      runner_extra_labels      = ["shared"]
      instance_types           = ["t3.small", "t3.medium"]
      runners_maximum_count    = 20

      # Roles the central runner is allowed to assume in external accounts
      assumable_roles_arn = [
        "arn:aws:iam::111111111111:role/dmc-dev-github-runner-assumable",
        "arn:aws:iam::222222222222:role/dmc-stg-github-runner-assumable"
      ]
      # assumable_roles_arn = ["*"] # Allow runner to assume any role (insecure)
    }
  }
```


</details>


### Assumed Role
It does not provision infrastructure to run the GitHub Runner. It only creates, in an external account, the IAM role that the central runner can assume. Set `assumable_role_enable = true` and this entry will skip the runner stack and create just the role, trusting `assumable_role_trusted_role_arn`.


<details><summary>Configuration Code</summary>

```hcl
github_runner_parameters = {
    "from-central" = {
      # When enabled, this entry does NOT create a runner (only the role)
      assumable_role_enable = true

      # ARN of the central runner instance role (account A)
      assumable_role_trusted_role_arn = "arn:aws:iam::999999999999:role/dmc-sha-github-runner"
      # Insecure option, trust an entire external account
      # assumable_role_trusted_role_arn = "arn:aws:iam::999999999999:root"

      # Optional session duration (seconds)
      # assumable_role_max_session_duration = 3600

      # Optional permissions policy for the assumable role
      # assumable_role_policy_json = data.aws_iam_policy_document.this.json
    }
  }
```


</details>


### Vendored Lambdas
The Lambda `.zip` artifacts of the upstream module (`v7.11.0`) are vendored under `modules/lambda/` and referenced via `path.module`. Consumers do not need to build the lambdas locally nor download anything at plan time, keeping runs reproducible and offline-friendly.





## 📑 Inputs
| Name                                    | Description                                                                        | Type           | Default                           | Required |
| --------------------------------------- | ---------------------------------------------------------------------------------- | -------------- | --------------------------------- | -------- |
| aws_region                              | AWS region where the runner is deployed                                            | `string`       | current provider region           | no       |
| prefix                                  | Prefix used for naming the runner resources                                        | `string`       | `"${local.common_name}"`          | no       |
| vpc_name                                | `tag:Name` used to look up the VPC                                                 | `string`       | `"${local.common_name}"`          | no       |
| subnet_name                             | `tag:Name` used to look up the subnets                                             | `string`       | `"${local.common_name}-private*"` | no       |
| github_app                              | GitHub App parameters (`id`, `key_base64`, `webhook_secret`)                       | `object`       | `null`                            | yes      |
| create_service_linked_role_spot         | Let the module create the spot service-linked role                                 | `bool`         | `null`                            | no       |
| enable_ephemeral_runners                | Create one instance per job and destroy it on completion                           | `bool`         | `false`                           | no       |
| enable_job_queued_check                 | Only start a runner when the job is queued                                         | `bool`         | `null`                            | no       |
| idle_config                             | Schedule to keep a number of idle (always-on) runners                              | `list(object)` | `[]`                              | no       |
| runner_extra_labels                     | Additional labels assigned to the runners                                          | `list(string)` | `[]`                              | no       |
| instance_types                          | EC2 instance types used for the runners                                            | `list(string)` | `["t3.small", "t3.medium"]`       | no       |
| runners_maximum_count                   | Maximum number of runner instances                                                 | `number`       | `null`                            | no       |
| enable_organization_runners             | Register runners at the organization level instead of repo level                   | `bool`         | `false`                           | no       |
| scale_up_reserved_concurrent_executions | Reserved concurrency for the scale-up lambda (`-1` to disable the limit)           | `number`       | `1`                               | no       |
| enable_ssm_on_runners                   | Enable SSM access on the runner instances                                          | `bool`         | `true`                            | no       |
| delay_webhook_event                     | Delay (in seconds) applied to webhook events                                       | `number`       | `30`                              | no       |
| scale_down_schedule_expression          | Cron expression that triggers the scale-down lambda                                | `string`       | `"cron(*/5 * * * ? *)"`           | no       |
| job_retry                               | Job retry configuration (`{ enable = bool }`)                                      | `object`       | `null`                            | no       |
| enable_userdata                         | Enable user data on the runner instances                                           | `bool`         | `true`                            | no       |
| ami                                     | AMI filter/owners for a pre-built runner image                                     | `object`       | `null`                            | no       |
| tags                                    | Map of tags merged with `common_tags`                                              | `map(string)`  | `{}`                              | no       |
| assumable_roles_arn                     | List of external role ARNs the central runner may assume (Shared Runner)           | `list(string)` | `null`                            | no       |
| assumable_role_enable                   | Only create the assumable role in this account, skipping the runner (Assumed Role) | `bool`         | `false`                           | no       |
| assumable_role_trusted_role_arn         | ARN trusted to assume the role created in this account                             | `string`       | `null`                            | no       |
| assumable_role_max_session_duration     | Max session duration (seconds) for the assumable role                              | `number`       | `3600`                            | no       |
| assumable_role_policy_json              | Optional permissions policy (JSON) attached to the assumable role                  | `string`       | `null`                            | no       |







## ⚠️ Important Notes
- **GitHub App required**: each runner entry needs a `github_app` block with `id`, `key_base64` (base64-encoded `.pem`) and `webhook_secret`. The same `webhook_secret` must be configured in the GitHub App webhook settings.
- **Networking by tag**: `vpc_name` and `subnet_name` are resolved by `tag:Name`. By default they fall back to `local.common_name` / `"${local.common_name}-private*"`.
- **Upstream version**: the module is pinned to `v7.11.0`. To upgrade, replace both the `?ref=` of the source and the vendored zips under `modules/lambda/`.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 