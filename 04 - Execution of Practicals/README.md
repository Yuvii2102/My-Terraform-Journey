
# Day 04 - Terraform Variables, Locals, Functions and Outputs

## 1. Introduction

In this practical, I worked with Terraform to create and manage an AWS EC2 instance using a more flexible configuration.

Instead of writing all the values directly inside one Terraform file, I divided the configuration into multiple files.

I practised input variables, different variable types, local values, conditional expressions, built-in functions and output variables.

I also learned how Terraform communicates with AWS using the AWS provider and how IAM permissions are required to manage EC2 resources.

### Topics Covered

- AWS Provider Configuration
- Input Variables
- String, List and Map
- terraform.tfvars
- Conditional Expressions
- Local Values
- Built-in Functions
- Output Variables
- Terraform File Structure
- Terraform Formatting and Validation
- Terraform State Management
- AWS IAM Permissions

## 2. Requirements

Before starting the practical, I used the following:

| Component | Details |
|---|---|
| Cloud Provider | AWS |
| Operating System | Ubuntu |
| Terraform | Installed |
| AWS CLI | Installed |
| Git | Installed |
| AWS Region | us-east-1 |
| AMI | Ubuntu |
| Instance Type | t2.micro |

I used my existing Ubuntu EC2 instance as the Terraform Control Node.

## 3. Verify the Environment

**Where to execute:** Ubuntu EC2 Control Node terminal.

I checked whether the required tools were installed.

```bash
aws --version
terraform --version
git --version
```

I also verified my AWS identity:

```bash
aws sts get-caller-identity --no-cli-pager
```

This command displays the AWS account and IAM identity currently configured in AWS CLI.

## 4. Configure AWS IAM Permissions

Terraform needs AWS permissions to create, read, update and delete EC2 resources.

I created a dedicated IAM user named `Terraform` and configured its access credentials.

### Step 1: Create an IAM User

**Where to configure:** AWS Console → IAM → Users → Create user.

I created a user named:

```text
Terraform
```

### Step 2: Create an Access Key

I opened the IAM user and navigated to:

Security credentials → Access keys → Create access key.

I created an access key for CLI access and securely saved the Access Key ID and Secret Access Key.

### Step 3: Configure AWS CLI

**Where to execute:** Ubuntu terminal.

```bash
aws configure
```

I entered my credentials and region:

```text
AWS Access Key ID: YOUR_ACCESS_KEY_ID
AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
Default region name: us-east-1
Default output format: json
```

I verified the configuration:

```bash
aws sts get-caller-identity --no-cli-pager
```

**Security:** I never upload AWS access keys or secret keys to GitHub.

### Method 1: Create a Custom IAM Policy Using JSON

**Where to configure:** AWS Console → IAM → Policies → Create policy → JSON.

I used the following policy to grant the EC2 permissions encountered during this practical.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateTags",
        "ec2:DescribeTags",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeVolumes",
        "ec2:DescribeInstanceCreditSpecifications"
      ],
      "Resource": "*"
    }
  ]
}
```

I saved the policy with the name:

```text
Terraform-EC2-Practical
```

Then I attached it to my IAM user:

1. Open IAM → Users.
2. Select the `Terraform` user.
3. Open Permissions.
4. Click Add permissions.
5. Select Attach policies directly.
6. Search for `Terraform-EC2-Practical`.
7. Select the policy and add permissions.

**Note:** This is the custom policy used for the permissions encountered in this exercise. Depending on the EC2 configuration, additional permissions may be required. For production, permissions should be restricted further.

### Method 2: Attach AmazonEC2FullAccess

This is the alternative method I used when I encountered repeated IAM permission errors.

**Where to configure:** AWS Console → IAM → Users → Terraform → Permissions.

Steps:

1. Click Add permissions.
2. Select Attach policies directly.
3. Search for `AmazonEC2FullAccess`.
4. Select the policy.
5. Click Add permissions.

This attaches the AWS-managed EC2 full-access policy to the IAM user.

**Important:** This policy grants broad EC2 permissions. I used it temporarily for this learning practical. For production environments, I prefer a properly scoped custom policy or IAM role.

I used this method to avoid repeatedly adding individual missing EC2 permissions during the exercise.

## 5. Create the Terraform Project

**Where to execute:** Ubuntu terminal.

I created a new directory:

```bash
mkdir terraform-day3
cd terraform-day3
```

I created the required files:

```bash
touch provider.tf main.tf variables.tf output.tf terraform.tfvars
```

I checked the files:

```bash
ls -la
```

My project structure:

```text
terraform-day3/
│
├── provider.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
└── output.tf
```

## 6. Configure the AWS Provider

**File:** `provider.tf`

I opened the file:

```bash
vim provider.tf
```

I added:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

I saved the file using:

```text
Esc
:wq
Enter
```

The AWS provider allows Terraform to communicate with AWS APIs.

I specified `us-east-1` as my deployment region.

## 7. Create Input Variables

**File:** `variables.tf`

I opened the file:

```bash
vim variables.tf
```

I added:

```hcl
variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0d97d7f07b25dd693"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "server_names" {
  description = "List of server names"
  type        = list(string)
  default     = ["server1", "server2", "server3"]
}

variable "instance_types" {
  description = "Instance types for different environments"
  type        = map(string)

  default = {
    dev  = "t2.micro"
    test = "t3.micro"
    prod = "t3.small"
  }
}
```

### Explanation

I created five input variables.

| Variable | Type | Purpose |
|---|---|---|
| ami_id | string | Stores the Ubuntu AMI ID |
| instance_type | string | Stores an EC2 instance type |
| environment | string | Defines the deployment environment |
| server_names | list(string) | Stores multiple server names |
| instance_types | map(string) | Stores instance types for different environments |

A list stores multiple values in order.

A map stores values using key-value pairs.

## 8. Configure terraform.tfvars

**File:** `terraform.tfvars`

I opened the file:

```bash
vim terraform.tfvars
```

I added:

```hcl
ami_id        = "ami-0d97d7f07b25dd693"
instance_type = "t2.micro"
environment   = "dev"
```

This file contains the actual values assigned to my input variables.

Terraform automatically loads `terraform.tfvars` when running commands in the same directory.

## 9. Configure Local Values and EC2 Resource

**File:** `main.tf`

I opened the file:

```bash
vim main.tf
```

I added:

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
}

resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = local.instance_type

  tags = {
    Name        = "My-Terraform-Server"
    Environment = var.environment
  }
}
```

### Explanation

I used a local value to store the calculated EC2 instance type.

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
}
```

This is a conditional expression.

Its syntax is:

```hcl
condition ? true_value : false_value
```

In my configuration:

- If the environment is `prod`, the instance type is `t3.small`.
- Otherwise, the instance type is `t2.micro`.

I accessed the local value using:

```hcl
local.instance_type
```

I also created an EC2 resource named:

```hcl
aws_instance.my_server
```

The resource uses the AMI ID from the input variable and the instance type from the local value.

I added Name and Environment tags to identify the instance.

## 10. Configure Output Variables

**File:** `output.tf`

I opened the file:

```bash
vim output.tf
```

I added:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_server.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.my_server.private_ip
}

output "total_servers" {
  description = "Total number of servers"
  value       = length(var.server_names)
}

output "development_instance_type" {
  value = var.instance_types["dev"]
}

output "production_instance_type" {
  value = var.instance_types["prod"]
}
```

### Explanation

I configured output variables to display important information after Terraform manages the EC2 instance.

I also used the built-in `length()` function:

```hcl
length(var.server_names)
```

Since my list contains three server names, the output is:

```text
total_servers = 3
```

I accessed map values using:

```hcl
var.instance_types["dev"]
```

and:

```hcl
var.instance_types["prod"]
```

These return the instance types associated with the respective keys.

## 11. Format and Validate the Configuration

**Where to execute:** Ubuntu terminal, inside `terraform-day3`.

First, I formatted the Terraform files:

```bash
terraform fmt
```

I checked the formatting:

```bash
terraform fmt -check
```

I initialized Terraform:

```bash
terraform init
```

This downloaded the required AWS provider plugin and created the `.terraform` directory and `.terraform.lock.hcl` file.

I validated the configuration:

```bash
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

## 12. Preview Infrastructure Changes

I ran:

```bash
terraform plan
```

Terraform analysed my configuration and displayed the infrastructure changes it planned to make.

For the initial creation, the expected summary was:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This meant Terraform planned to create one EC2 instance.

## 13. Create the EC2 Instance

I executed:

```bash
terraform apply
```

Terraform displayed the planned changes and asked for confirmation.

I entered:

```text
yes
```

After successful creation, Terraform displayed the outputs.

The expected initial creation summary was:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

I checked the outputs using:

```bash
terraform output
```

I could also display individual outputs:

```bash
terraform output instance_id
terraform output public_ip
terraform output private_ip
```

I verified the EC2 instance in AWS Console → EC2 → Instances.

The instance name was:

```text
My-Terraform-Server
```

## 14. Understand Terraform State

I checked the Terraform state:

```bash
terraform state list
```

The output showed:

```text
aws_instance.my_server
```

I inspected the resource:

```bash
terraform state show aws_instance.my_server
```

Terraform state keeps track of the infrastructure managed by the configuration.

I learned that the state file is important and should not be uploaded to a public GitHub repository.

## 15. Troubleshooting and Fixes

During this practical, I encountered IAM permission errors while Terraform was refreshing the EC2 instance.

### Issue 1: DescribeInstanceAttribute

Terraform reported that the IAM user did not have:

```text
ec2:DescribeInstanceAttribute
```

I added this permission to my custom IAM policy.

### Issue 2: DescribeVolumes

Terraform reported that the IAM user did not have:

```text
ec2:DescribeVolumes
```

I added the missing permission.

### Issue 3: DescribeInstanceCreditSpecifications

Terraform reported that the IAM user did not have:

```text
ec2:DescribeInstanceCreditSpecifications
```

I added this permission as well.

After facing repeated permission errors, I attached the AWS-managed `AmazonEC2FullAccess` policy to my dedicated Terraform IAM user for this temporary practical.

### Issue 4: Tainted Resource

During the initial apply, Terraform created the EC2 instance but encountered an error while reading some of its details because of insufficient IAM permissions.

The resource was marked as tainted.

I checked the state:

```bash
terraform state list
```

Then I ran:

```bash
terraform plan
```

The plan showed:

```text
Plan: 1 to add, 0 to change, 1 to destroy.
```

This meant Terraform wanted to replace the tainted instance.

I checked AWS Console and confirmed that the existing Terraform EC2 instance was running and healthy.

Instead of unnecessarily replacing it, I removed the tainted status:

```bash
terraform untaint aws_instance.my_server
```

Expected output:

```text
Resource instance aws_instance.my_server has been successfully untainted.
```

I generated another plan:

```bash
terraform plan
```

This time, Terraform refreshed the existing instance and showed that only the output values needed to be saved.

I applied the changes:

```bash
terraform apply
```

I entered `yes` when prompted.

The final result was:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

This confirmed that the existing EC2 instance was retained and Terraform successfully saved the output values.

## 16. Final Outputs

These were the values from my practical:

| Output | Result |
|---|---|
| Development instance type | t2.micro |
| Production instance type | t3.small |
| Total servers | 3 |
| EC2 instance ID | i-08dec5939e34b75dc |
| Private IP | 172.31.21.32 |
| Public IP | 54.242.4.159 |

The instance ID and IP addresses are specific to my original execution. AWS may generate different values when I repeat the practical.

### Final Apply Result

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

## 17. Clean Up AWS Resources

After completing the practical, I can remove the EC2 instance if it is no longer required.

First, I check the resources managed by Terraform:

```bash
terraform state list
```

I preview the destruction:

```bash
terraform plan -destroy
```

After confirming that the plan contains only the intended Terraform practical resources, I execute:

```bash
terraform destroy
```

I enter:

```text
yes
```

The expected result is:

```text
Destroy complete! Resources: 1 destroyed.
```

I verify in AWS Console that the Terraform practical EC2 instance has been terminated.

**Important:** I must not destroy my Terraform Control Node or Ansible Control Node. Only the EC2 instance managed by this practical should be deleted.

After the practical, I also review the IAM user and remove unnecessary permissions or access keys. If I used `AmazonEC2FullAccess`, I detach it when it is no longer needed.

## 18. GitHub Repository and Security

I stored my Terraform configuration files in my GitHub repository.

The project files are:

```text
04 - Execution of Practicals/
│
├── provider.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
├── output.tf
├── .gitignore
└── .terraform.lock.hcl
```

### .gitignore

I used the following entries to avoid committing Terraform state and local working files:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
```

I committed `.terraform.lock.hcl` because it records the selected provider version and checksums.

I did not upload Terraform state files, AWS credentials or secret keys.

My `terraform.tfvars` file contains only non-secret configuration values.

## 19. Commands Reference

| Command | Purpose |
|---|---|
| `aws --version` | Check AWS CLI |
| `terraform --version` | Check Terraform |
| `aws configure` | Configure AWS CLI credentials |
| `aws sts get-caller-identity` | Verify AWS identity |
| `mkdir terraform-day3` | Create project directory |
| `cd terraform-day3` | Enter project directory |
| `touch provider.tf main.tf variables.tf output.tf terraform.tfvars` | Create Terraform files |
| `vim filename.tf` | Edit a Terraform file |
| `terraform fmt` | Format Terraform files |
| `terraform fmt -check` | Check formatting |
| `terraform init` | Initialize Terraform |
| `terraform validate` | Validate configuration |
| `terraform plan` | Preview infrastructure changes |
| `terraform apply` | Apply configuration |
| `terraform output` | Display outputs |
| `terraform state list` | List managed resources |
| `terraform state show` | Inspect a resource |
| `terraform untaint` | Remove tainted status |
| `terraform plan -destroy` | Preview resource destruction |
| `terraform destroy` | Destroy managed resources |

## 20. What I Learned

In this practical, I learned how to organise Terraform configurations into separate files and make infrastructure configurations more flexible using variables and local values.

I practised string, list and map variables, conditional expressions, built-in functions and output variables.

I also understood how Terraform uses state to track AWS resources and why correct IAM permissions are important for creating and refreshing infrastructure.

The most useful part of this practical was troubleshooting IAM permission errors and recovering an existing EC2 resource without unnecessarily destroying and recreating it.

**Status: Completed**

## Where to Execute the Commands

| Content | Where to Use It |
|---|---|
| `aws configure`, `terraform init`, `terraform plan`, `terraform apply` and other terminal commands | Ubuntu EC2 terminal |
| `provider.tf`, `main.tf`, `variables.tf`, `output.tf`, `terraform.tfvars` | Create and edit using `vim` inside the Terraform project directory |
| IAM JSON policy | AWS Console → IAM → Policies → Create policy → JSON editor |
| `AmazonEC2FullAccess` | AWS Console → IAM → Users → Select Terraform user → Permissions → Add permissions → Attach policies directly |
| Verify EC2 instance | AWS Console → EC2 → Instances |
| GitHub documentation | GitHub → My-Terraform-Journey → `04 - Execution of Practicals` |

**Important:** Always execute Terraform commands from inside the Terraform project directory.
