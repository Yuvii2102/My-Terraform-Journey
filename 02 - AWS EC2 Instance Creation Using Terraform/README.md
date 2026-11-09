# AWS EC2 Instance Creation Using Terraform

## Introduction

In this practical, I installed Terraform on my Ubuntu EC2 instance and used it to create an AWS EC2 instance.

Instead of creating the instance manually through the AWS Console, I used Terraform to automate the process.

I also learned how to configure the AWS provider, write Terraform code, initialize the project, preview changes, create infrastructure and destroy resources.

## Tools Used

- AWS EC2
- Ubuntu
- Terraform
- AWS CLI
- Git and GitHub

## 1. Update Ubuntu Packages

First, I updated the package list and installed the available updates.

```bash
sudo apt update
sudo apt upgrade -y
```

## 2. Install AWS CLI

I installed the required packages:

```bash
sudo apt install curl unzip -y
```

Downloaded AWS CLI:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

Extracted the downloaded file:

```bash
unzip awscliv2.zip
```

Installed AWS CLI:

```bash
sudo ./aws/install
```

Verified the installation:

```bash
aws --version
```

## 3. Install Terraform

First, I installed the required dependencies.

```bash
sudo apt-get install -y gnupg software-properties-common
```

Added the HashiCorp GPG key:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

Added the HashiCorp repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Updated the package list:

```bash
sudo apt update
```

Installed Terraform:

```bash
sudo apt install terraform -y
```

Verified the installation:

```bash
terraform --version
```

## 4. Configure AWS Authentication

Since I was using an AWS EC2 instance as my Control Node, I used an IAM Role to provide AWS permissions.

I checked whether AWS authentication was working:

```bash
aws sts get-caller-identity
```

The command returned my AWS account and identity details.

This confirmed that AWS CLI could authenticate with my AWS account.

**Note:** An IAM Role is attached to the EC2 instance, so I did not need to store AWS access keys manually.

## 5. Create a Terraform Project

Created a separate directory for the practical.

```bash
mkdir ~/terraform-practice
cd ~/terraform-practice
```

Verified the directory:

```bash
pwd
```

Created the main Terraform file:

```bash
vim main.tf
```

Terraform configuration files use the `.tf` extension.

## 6. Configure the AWS Provider

Inside `main.tf`, I added the AWS provider configuration.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider block tells Terraform to communicate with AWS.

I selected `us-east-1` as the AWS region.

## 7. Find the Ubuntu AMI ID

Before creating an EC2 instance, I needed an AMI ID.

I found it manually through the AWS Console.

Steps followed:

1. Opened AWS Console.
2. Navigated to EC2.
3. Selected Launch Instance.
4. Selected Ubuntu Server 24.04 LTS.
5. Copied the AMI ID from the image details.
6. Made sure the selected region was `us-east-1`.

AMI ID used:

```text
ami-0d97d7f07b25dd693
```

An AMI provides the operating system image required to launch an EC2 instance.

## 8. Create an EC2 Resource

I added the EC2 resource block to `main.tf`.

Final configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
}
```

### Understanding the resource block

- `resource` defines the infrastructure we want to manage.
- `aws_instance` specifies the AWS EC2 resource type.
- `my_server` is the local name given to the resource.
- `ami` specifies the operating system image.
- `instance_type` specifies the EC2 instance type.

I used `t2.micro` for this practical.

## 9. Initialize Terraform

After writing the configuration, I initialized the Terraform project.

```bash
terraform init
```

Terraform downloaded the required AWS provider plugin and prepared the working directory.

Output:

```text
Terraform has been successfully initialized!
```

It also created the following files and directories:

- `.terraform/`
- `.terraform.lock.hcl`

## 10. Preview Infrastructure Changes

Before creating the EC2 instance, I checked the execution plan.

```bash
terraform plan
```

Terraform displayed the changes it was going to perform.

Output:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This means Terraform planned to create one new EC2 instance without modifying or deleting any existing resources.

The plan command does not create the infrastructure.

## 11. Create the EC2 Instance

After checking the execution plan, I applied the configuration.

```bash
terraform apply
```

Terraform displayed the plan again and asked for confirmation.

I entered:

```text
yes
```

Terraform successfully created the EC2 instance.

Output:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

The EC2 instance was successfully created in AWS.

## 12. Verify Terraform State

After creating the instance, I checked the resources managed by Terraform.

```bash
terraform state list
```

Output:

```text
aws_instance.my_server
```

Terraform also created a state file named `terraform.tfstate`.

The state file keeps track of the infrastructure managed by Terraform.

I also checked the project files:

```bash
ls -a
```

The directory contained:

```text
.terraform/
.terraform.lock.hcl
main.tf
terraform.tfstate
```

## 13. Destroy the EC2 Instance

After completing the practical, I deleted the EC2 instance using Terraform.

```bash
terraform destroy
```

Terraform displayed the resources that would be deleted and asked for confirmation.

I entered:

```text
yes
```

Output:

```text
Destroy complete! Resources: 1 destroyed.
```

The EC2 instance was successfully deleted.

## Important Terraform Commands

| Command | Purpose |
|---|---|
| `terraform init` | Initializes the Terraform project |
| `terraform plan` | Previews infrastructure changes |
| `terraform apply` | Creates or updates infrastructure |
| `terraform state list` | Lists Terraform-managed resources |
| `terraform destroy` | Deletes managed infrastructure |

## What I Learned

Through this practical, I learned:

- How to install AWS CLI and Terraform on Ubuntu.
- How to configure AWS authentication using an IAM Role.
- How to configure the AWS provider.
- How to find an AMI ID through AWS Console.
- How to write a Terraform configuration using HCL.
- How to create an EC2 instance using Terraform.
- How to use Terraform lifecycle commands.
- How Terraform manages infrastructure using a state file.
- How to destroy infrastructure using Terraform.

## Conclusion

This was my first hands-on Terraform practical.

I learned how to create an AWS EC2 instance using Infrastructure as Code instead of creating it manually through the AWS Console.

I also understood the basic Terraform workflow from initialization to resource creation and destruction.

This practical gave me a good starting point for learning more about Terraform and infrastructure automation.

## References

The following official documentation helped me understand and install the tools used in this practical.

### 1. AWS CLI

- [AWS CLI Official Download and Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS CLI Linux Installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### 2. Terraform

- [Terraform Official Download Page](https://developer.hashicorp.com/terraform/install)
- [Terraform Installation on Ubuntu](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### 3. AWS Authentication and IAM

- [AWS IAM Roles for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### 4. AWS EC2 and AMI

- [Amazon EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [Finding an AMI in AWS Console](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)
