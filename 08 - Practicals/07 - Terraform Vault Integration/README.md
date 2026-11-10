# Terraform and HashiCorp Vault Integration

## Overview

In this practical, I integrated Terraform with HashiCorp Vault to retrieve secrets and use them while provisioning AWS infrastructure.

## Tools and Technologies

- AWS EC2
- HashiCorp Vault
- Terraform
- AWS CLI
- Ubuntu Linux
- HCL

## Practical Steps

### 1. Install and Configure Vault

Installed HashiCorp Vault on an Ubuntu EC2 instance and started the development server.

### 2. Enable KV Version 2

Enabled the KV v2 secrets engine at the `kv/` path.

### 3. Store a Secret

Created a secret named `test_secret` containing username and password fields.

### 4. Configure AppRole Authentication

Enabled AppRole authentication and created a Terraform policy with read access to KV v2 secrets.

Created an AppRole named `terraform` and generated its Role ID and Secret ID.

### 5. Configure Terraform

Installed Terraform and configured the AWS and Vault providers.

### 6. Integrate Terraform with Vault

Configured the Vault provider to authenticate using AppRole.

Used the `vault_kv_secret_v2` data source to retrieve the stored secret.

### 7. Provision AWS EC2

Used the retrieved username as an EC2 instance tag and provisioned an EC2 instance using Terraform.

## Authentication Variables

Credentials are passed through Terraform environment variables.

Set these locally before running Terraform:

```bash
export TF_VAR_vault_role_id="YOUR_ROLE_ID"
export TF_VAR_vault_secret_id="YOUR_SECRET_ID"
```

Never commit actual credentials to GitHub.

## Terraform Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To clean up the resources:

```bash
terraform destroy
```

## Key Learnings

- HashiCorp Vault secret management
- KV Version 2 secrets engine
- AppRole authentication
- Terraform Vault provider integration
- Reading secrets using Terraform data sources
- AWS EC2 provisioning
- Passing sensitive values through Terraform variables

## Security Note

This practical uses Vault development mode for learning purposes.

Terraform state files may contain sensitive values. Never commit Terraform state files, credentials, or secret variable files to GitHub.
