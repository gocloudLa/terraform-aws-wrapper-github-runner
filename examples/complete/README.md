# Complete Example 🚀

This example demonstrates how to configure self-hosted, auto-scaling GitHub Actions runners using the wrapper. It shows a fixed (always-on) runner and includes commented-out sections for an ephemeral runner and the cross-account Shared Runner / Assumed Role features.

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
The main purpose is to configure GitHub Runners through the `github_runner_parameters` map, each with its own GitHub App, labels, instance types and scaling behavior.

#### Key Features Demonstrated
- **Fixed Runner**: The `fixed` entry keeps 1 instance always running via `idle_config` with `enable_ephemeral_runners = false`.
- **Ephemeral Runner**: A commented-out `ephemeral` entry shows one instance per job with `enable_ephemeral_runners = true` and no idle config.
- **Shared Runner**: A commented-out `shared` entry grants the central runner `assumable_roles_arn` to assume roles in external accounts.

## 🚀 Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## 🔒 Security Notes

⚠️ **Production Considerations**: 
- This example may include configurations that are not suitable for production environments
- Review and customize security settings, access controls, and resource configurations
- Ensure compliance with your organization's security policies
- Consider implementing proper monitoring, logging, and backup strategies

## 📖 Documentation

For detailed module documentation and additional examples, see the main [README.md](../../README.md) file. 