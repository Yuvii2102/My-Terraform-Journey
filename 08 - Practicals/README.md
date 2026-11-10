# Terraform and HashiCorp Vault Integration on AWS

## 1. Project Overview

In this practical, I integrated Terraform with HashiCorp Vault to retrieve secrets and use the retrieved values while provisioning an AWS EC2 instance.

I used an Ubuntu EC2 instance to install Vault and Terraform. I used two terminal sessions connected to the same EC2 instance. One terminal ran the Vault development server, while the other was used for Vault CLI commands and Terraform operations.

### Tools and Technologies

- AWS EC2
- Ubuntu Linux
- HashiCorp Vault
- Terraform
- AWS CLI
- HCL

### Practical Workflow

1. Launch an EC2 instance.
2. Install HashiCorp Vault.
3. Start the Vault development server.
4. Enable KV v2 secrets engine.
5. Store a secret in Vault.
6. Enable AppRole authentication.
7. Create a Terraform policy.
8. Create an AppRole and generate credentials.
9. Install Terraform.
10. Configure AWS credentials.
11. Connect Terraform with Vault.
12. Retrieve secrets using Terraform.
13. Provision an AWS EC2 instance using the retrieved secret.
14. Verify the EC2 instance and its tags.
15. Destroy the EC2 instance.

---

## 2. Launch an EC2 Instance

First, I launched an Ubuntu EC2 instance in AWS.

I connected to the instance using MobaXterm or EC2 Instance Connect.

For this practical, I used the same EC2 instance to run Vault and Terraform.

**Configuration:**

- Operating System: Ubuntu
- AWS Region: `us-east-1`
- Vault Port: `8200`

Since Vault and Terraform run on the same EC2 instance, I used the following local address:

```text
http://127.0.0.1:8200
```

**Security Group:** Port 8200 does not need to be publicly accessible for this setup because Terraform connects through localhost.

**Source:** [AWS – Launch an EC2 Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/LaunchingAndUsingInstances.html)

---

## 3. Install HashiCorp Vault

Update the Ubuntu packages and install the required dependencies.

```bash
sudo apt update
sudo apt install wget gpg coreutils -y
```

Download and add the HashiCorp GPG key.

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Add the HashiCorp APT repository.

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Update the package list and install Vault.

```bash
sudo apt update
sudo apt install vault -y
```

Verify the installation.

```bash
vault version
```

**Source:** [HashiCorp – Install Vault](https://developer.hashicorp.com/vault/install)

---

## 4. Start the Vault Development Server

I used two terminal sessions connected to the same EC2 instance.

### Terminal 1 – Start Vault Server

Run:

```bash
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

Vault starts in development mode and displays a Root Token.

Keep Terminal 1 running throughout the practical.

**Important:** Copy the Root Token for local use. Never share it or upload it to GitHub.

### Terminal 2 – Connect to Vault

Open another terminal session to the same EC2 instance.

Set the Vault address.

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
```

Log in using the Root Token displayed in Terminal 1.

```bash
vault login
```

Check the Vault status.

```bash
vault status
```

Confirm that Vault is unsealed:

```text
Sealed: false
```

**Source:** [HashiCorp – Vault Development Server](https://developer.hashicorp.com/vault/docs/concepts/dev-server)

**Command reference:** [Vault CLI Commands](https://developer.hashicorp.com/vault/docs/commands)

---

## 5. Enable KV Version 2 Secrets Engine

Enable the KV v2 secrets engine at the `kv/` path.

```bash
vault secrets enable -path=kv kv-v2
```

Create a secret named `test_secret`.

```bash
vault kv put kv/test_secret username="admin" password="YOUR_LAB_PASSWORD"
```

Replace the password with a lab-only value.

Verify the secret.

```bash
vault kv get kv/test_secret
```

The secret contains:

| Key | Value |
|---|---|
| username | admin |
| password | Your lab password |

The KV v2 API path is:

```text
kv/data/test_secret
```

**Source:** [HashiCorp – KV Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/kv)

**Command reference:** [Vault KV CLI Commands](https://developer.hashicorp.com/vault/docs/commands/kv)

---

## 6. Enable AppRole Authentication

Enable AppRole authentication.

```bash
vault auth enable approle
```

AppRole allows applications such as Terraform to authenticate with Vault using a Role ID and Secret ID.

**Source:** [HashiCorp – AppRole Authentication](https://developer.hashicorp.com/vault/docs/auth/approle)

---

## 7. Create a Terraform Policy

Create the policy file.

```bash
vim terraform-policy.hcl
```

Add the following policy:

```hcl
path "kv/data/*" {
  capabilities = ["read"]
}
```

Save the file:

1. Press `Esc`.
2. Type `:wq`.
3. Press `Enter`.

Upload the policy to Vault.

```bash
vault policy write terraform terraform-policy.hcl
```

Verify the policy.

```bash
vault policy read terraform
```

The policy grants read access to secrets stored under the KV v2 data path.

**Sources:**

- [HashiCorp – Vault Policies](https://developer.hashicorp.com/vault/docs/concepts/policies)
- [HashiCorp – Vault Policy Commands](https://developer.hashicorp.com/vault/docs/commands/policy)

---

## 8. Create an AppRole

Create an AppRole named `terraform` and attach the Terraform policy.

```bash
vault write auth/approle/role/terraform token_policies="terraform" token_ttl=1h token_max_ttl=4h
```

Retrieve the Role ID.

```bash
vault read auth/approle/role/terraform/role-id
```

Generate the Secret ID.

```bash
vault write -f auth/approle/role/terraform/secret-id
```

Keep the Role ID and Secret ID private. These credentials are required for Terraform authentication.

**Source:** [HashiCorp – AppRole Authentication](https://developer.hashicorp.com/vault/docs/auth/approle)

---

## 9. Install Terraform

The HashiCorp APT repository was already configured during Vault installation.

Install Terraform.

```bash
sudo apt update
sudo apt install terraform -y
```

Verify the installation.

```bash
terraform version
```

My lab used Terraform v1.17.1.

**Source:** [HashiCorp – Install Terraform](https://developer.hashicorp.com/terraform/install)

---

## 10. Configure AWS CLI

Check the AWS CLI installation.

```bash
aws --version
```

Verify AWS authentication.

```bash
aws sts get-caller-identity
```

The command displays the AWS IAM identity associated with the configured credentials.

If AWS credentials are not configured, run:

```bash
aws configure
```

Enter the required AWS credentials and default region locally.

For this practical, I used:

```text
Region: us-east-1
```

Never add AWS access keys directly to Terraform configuration files.

**Sources:**

- [AWS – Installing or Updating the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS – Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [AWS – Get Caller Identity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)

---

## 11. Create the Terraform Project

Create a project directory.

```bash
mkdir -p ~/terraform-vault-integration
cd ~/terraform-vault-integration
```

Create the main Terraform configuration file.

```bash
vim main.tf
```

Add the following complete configuration.

### main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.72"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.13"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Vault Provider
provider "vault" {
  address          = "http://127.0.0.1:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

# Retrieve secret from Vault
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test_secret"
}

# Retrieve the latest Ubuntu 22.04 AMI from AWS SSM
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# Display retrieved username
output "vault_username" {
  value     = data.vault_kv_secret_v2.example.data["username"]
  sensitive = true
}

# Create EC2 instance
resource "aws_instance" "vault_demo" {
  ami           = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = "t2.micro"

  tags = {
    Name     = "Terraform-Vault-Demo"
    Username = data.vault_kv_secret_v2.example.data["username"]
  }
}
```

The configuration contains the AWS provider, Vault provider, Vault data source, Ubuntu AMI lookup, output and EC2 resource.

### Understanding the Configuration

**AWS Provider**

Configures Terraform to work with AWS in the `us-east-1` region.

**Vault Provider**

Connects Terraform to the Vault server running on the same EC2 instance.

**AppRole Authentication**

Uses the Role ID and Secret ID to authenticate Terraform with Vault.

**Vault Data Source**

Retrieves the `test_secret` secret from the KV v2 engine.

**AWS SSM Data Source**

Retrieves the current Ubuntu 22.04 AMI ID for the selected region and architecture.

**EC2 Resource**

Creates an EC2 instance and uses the username retrieved from Vault as an instance tag.

**Sources:**

- [Terraform – AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform – Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Vault Provider – KV v2 Data Source](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2)
- [AWS Provider – SSM Parameter Data Source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)
- [AWS Provider – EC2 Instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

---

## 12. Create variables.tf

Create another Terraform configuration file.

```bash
vim variables.tf
```

Add:

```hcl
variable "vault_role_id" {
  description = "Vault AppRole Role ID"
  type        = string
  sensitive   = true
}

variable "vault_secret_id" {
  description = "Vault AppRole Secret ID"
  type        = string
  sensitive   = true
}
```

These variables allow Terraform to receive the AppRole credentials without hardcoding them in `main.tf`.

Save the file using `Esc`, `:wq` and `Enter`.

**Sources:**

- [Terraform – Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform – Sensitive Data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)

---

## 13. Provide AppRole Credentials to Terraform

In Terminal 2, export the Role ID and Secret ID as environment variables.

Replace the placeholders with the credentials generated by Vault.

```bash
export TF_VAR_vault_role_id="YOUR_ROLE_ID"
export TF_VAR_vault_secret_id="YOUR_SECRET_ID"
```

Verify that both variables are set without displaying their values.

```bash
test -n "$TF_VAR_vault_role_id" && echo "Role ID is set"
test -n "$TF_VAR_vault_secret_id" && echo "Secret ID is set"
```

These environment variables remain available in the current shell session.

If a new terminal is opened, export them again.

**Sources:**

- [Terraform – Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables)
- [Terraform – Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

---

## 14. Initialize Terraform

Initialize the Terraform working directory.

```bash
terraform init
```

Terraform downloads the required AWS and Vault providers.

Expected output:

```text
Terraform has been successfully initialized!
```

Terraform also creates `.terraform.lock.hcl`, which records the selected provider versions.

**Source:** [Terraform – terraform init](https://developer.hashicorp.com/terraform/cli/commands/init)

---

## 15. Format and Validate Terraform

Format the configuration files.

```bash
terraform fmt
```

Validate the configuration.

```bash
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

**Sources:**

- [Terraform – terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [Terraform – terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)

---

## 16. Retrieve the Vault Secret Using Terraform

Run:

```bash
terraform plan
```

Terraform authenticates with Vault using AppRole and reads the secret from the KV v2 engine.

The successful data-source read appears as:

```text
data.vault_kv_secret_v2.example: Reading...
data.vault_kv_secret_v2.example: Read complete
```

The output is marked sensitive, so Terraform displays:

```text
Changes to Outputs:

  + vault_username = (sensitive value)
```

This confirms that Terraform can retrieve the secret stored in Vault.

**Sources:**

- [Terraform Vault Provider – KV v2 Data Source](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2)
- [Terraform – Plan Command](https://developer.hashicorp.com/terraform/cli/commands/plan)

---

## 17. Plan the EC2 Deployment

After configuring the EC2 resource, run:

```bash
terraform fmt
terraform validate
terraform plan
```

Terraform retrieves the Vault secret and the Ubuntu AMI ID before generating the execution plan.

Review the plan.

Expected resource summary:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This indicates that Terraform is ready to create one EC2 instance.

**Source:** [Terraform – Plan Command](https://developer.hashicorp.com/terraform/cli/commands/plan)

---

## 18. Apply the Terraform Configuration

Run:

```bash
terraform apply
```

Review the proposed changes.

Enter:

```text
yes
```

Terraform creates the EC2 instance.

Expected output:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

The output also displays:

```text
Outputs:

vault_username = <sensitive>
```

The instance is now created successfully.

**Source:** [Terraform – Apply Command](https://developer.hashicorp.com/terraform/cli/commands/apply)

---

## 19. Verify the EC2 Instance

Open the AWS Management Console.

Navigate to:

**EC2 → Instances**

Find the instance created by Terraform and open its Tags tab.

The expected tags are:

| Key | Value |
|---|---|
| Name | Terraform-Vault-Demo |
| Username | admin |

The `Username` value comes from the secret retrieved from Vault.

This confirms that Terraform successfully connected to Vault, retrieved the secret and used the retrieved value while creating an AWS resource.

**Source:** [AWS – View EC2 Instance Details](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)

---

## 20. Destroy the EC2 Instance

After verifying the instance, remove the Terraform-managed infrastructure to avoid unnecessary AWS charges.

Run:

```bash
terraform destroy
```

Review the destruction plan.

Enter:

```text
yes
```

Expected output:

```text
Destroy complete! Resources: 1 destroyed.
```

The EC2 instance created by Terraform is now removed.

**Source:** [Terraform – Destroy Command](https://developer.hashicorp.com/terraform/cli/commands/destroy)

---

## 21. GitHub Repository Structure

I used my existing repository:

[My-Terraform-Journey](https://github.com/Yuvii2102/My-Terraform-Journey)

I kept the practical files directly inside the `08 - Practicals` folder.

The final structure is:

```text
My-Terraform-Journey/
│
└── 08 - Practicals/
    ├── main.tf
    ├── variables.tf
    ├── .gitignore
    ├── .terraform.lock.hcl
    └── Terraform-Vault-Integration.md
```

### .gitignore

Create the `.gitignore` file:

```bash
vim .gitignore
```

Add:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
*.swp
*.backup
crash.log
```

This prevents Terraform state files, provider directories and local variable files from being added to Git.

The `.terraform.lock.hcl` file should be committed to GitHub.

Never upload:

- Terraform state files
- Vault Root Tokens
- AppRole Secret IDs
- AWS access keys
- Actual credential files

**Sources:**

- [GitHub – Ignoring Files](https://docs.github.com/en/get-started/git-basics/ignoring-files)
- [Terraform – Dependency Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Terraform – Sensitive Data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)

---

## 22. Key Learnings

Through this practical, I learned how to:

- Install and configure HashiCorp Vault on AWS EC2.
- Enable KV v2 secrets engine and store secrets.
- Configure AppRole authentication.
- Create policies and attach them to AppRoles.
- Configure Terraform AWS and Vault providers.
- Authenticate Terraform with Vault using AppRole.
- Retrieve secrets using Terraform data sources.
- Handle sensitive Terraform outputs.
- Use retrieved Vault values while provisioning AWS resources.
- Retrieve an Ubuntu AMI using AWS SSM.
- Create and destroy EC2 instances using Terraform.
- Protect sensitive files when pushing Terraform projects to GitHub.

## Conclusion

This practical helped me understand how HashiCorp Vault and Terraform work together.

I stored secrets in Vault, configured AppRole authentication, connected Terraform to Vault and retrieved the stored username. I then used that value while creating an AWS EC2 instance through Terraform.

It was a good hands-on experience in understanding secret management and infrastructure automation using AWS, Terraform and HashiCorp Vault.

## Security Notes

- Vault development mode is intended only for learning and testing.
- Keep Terminal 1 running while executing Vault and Terraform commands in Terminal 2.
- Restarting Vault development mode removes its in-memory secrets, policies and AppRole configuration.
- Never upload Root Tokens, Role IDs, Secret IDs or AWS credentials to GitHub.
- Terraform state can contain sensitive values even when outputs are marked sensitive. Keep state files private.
- EC2 tags are not a secure place to store confidential information. The username tag in this practical is only a demonstration.
- Rotate credentials that were exposed during the lab.
