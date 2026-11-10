# Day 5 – Creating and Deploying Reusable EC2 Modules Using Terraform

## Introduction

Today, I learned how to create and use Terraform Modules to organize and reuse infrastructure code.

First, I created an EC2 instance using a normal Terraform configuration. After successfully deploying the instance, I converted the configuration into a reusable EC2 module.

I also learned how to connect a root module with a child module, pass input variables, return outputs and migrate an existing resource into a module without recreating it.

## Objective

- Understand Terraform Modules.
- Create an EC2 instance using Terraform.
- Organize Terraform configuration into separate files.
- Create a reusable EC2 child module.
- Connect the root module with the child module.
- Pass variables and retrieve outputs.
- Migrate an existing resource into a module.
- Verify the deployment without creating duplicate resources.

## Tools and Technologies Used

- AWS EC2
- Ubuntu Linux
- Terraform
- AWS Provider
- Vim Editor
- Git and GitHub

---

## Step 1 – Create the Project Directory

**Where to execute:** Ubuntu EC2 Control Node terminal using AWS EC2 Instance Connect.

I created a separate directory for the Terraform Modules practical.

```bash
mkdir terraform-day3-module
cd terraform-day3-module
pwd
```

This directory became my working directory for the entire practical.

## Step 2 – Create the Terraform Configuration Files

**Where to execute:** Ubuntu EC2 terminal, inside `terraform-day3-module`.

I created five Terraform configuration files.

```bash
touch provider.tf main.tf variables.tf terraform.tfvars outputs.tf
ls
```

Purpose of each file:

| File | Purpose |
|---|---|
| `provider.tf` | Configures the AWS provider |
| `main.tf` | Defines the EC2 resource |
| `variables.tf` | Declares input variables |
| `terraform.tfvars` | Stores variable values |
| `outputs.tf` | Displays EC2 details |

## Step 3 – Configure the AWS Provider

**Where to edit:** `provider.tf` using Vim on the Ubuntu EC2 terminal.

```bash
vim provider.tf
```

I added the following configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This configuration tells Terraform to use AWS as the cloud provider and deploy resources in the `us-east-1` region.

## Step 4 – Configure Input Variables

**Where to edit:** `variables.tf` using Vim on the Ubuntu EC2 terminal.

```bash
vim variables.tf
```

I declared two input variables.

```hcl
variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

These variables allow me to provide the AMI ID and EC2 instance type separately instead of hardcoding them inside the resource.

## Step 5 – Provide Variable Values

**Where to edit:** `terraform.tfvars` using Vim on the Ubuntu EC2 terminal.

```bash
vim terraform.tfvars
```

I provided the following values:

```hcl
ami_id        = "ami-0d97d7f07b25dd693"
instance_type = "t2.micro"
```

Terraform automatically loads values from `terraform.tfvars`.

## Step 6 – Create the EC2 Resource

**Where to edit:** `main.tf` using Vim on the Ubuntu EC2 terminal.

```bash
vim main.tf
```

I added the EC2 resource configuration.

```hcl
resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Module-Server"
  }
}
```

Explanation:

- `aws_instance` defines an EC2 instance.
- `my_server` is the Terraform resource name.
- `var.ami_id` gets the AMI ID from the input variable.
- `var.instance_type` gets the instance type from the input variable.
- `tags` assigns a name to the EC2 instance.

## Step 7 – Configure Outputs

**Where to edit:** `outputs.tf` using Vim on the Ubuntu EC2 terminal.

```bash
vim outputs.tf
```

I added three outputs.

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
```

These outputs display the EC2 instance ID, public IP and private IP after deployment.

## Step 8 – Format and Initialize Terraform

**Where to execute:** Ubuntu EC2 terminal, inside the project directory.

First, I formatted the configuration files.

```bash
terraform fmt
```

Then I initialized Terraform.

```bash
terraform init
```

Terraform downloaded and installed the AWS provider.

Provider version installed: `hashicorp/aws v6.72.0`.

Finally, I validated the configuration.

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

## Step 9 – Review the Execution Plan

**Where to execute:** Ubuntu EC2 terminal.

```bash
terraform plan
```

Terraform displayed the resources it planned to create.

The plan showed:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This confirmed that Terraform was ready to create one EC2 instance.

## Step 10 – Deploy the EC2 Instance

**Where to execute:** Ubuntu EC2 terminal.

```bash
terraform apply
```

Terraform displayed the execution plan and asked for confirmation.

I entered:

```text
yes
```

The EC2 instance was successfully created.

**Deployment result:**

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### EC2 Instance Details

| Property | Value |
|---|---|
| Instance ID | `i-06075ca7fba46d2e2` |
| Instance Type | `t2.micro` |
| Private IP | `172.31.27.1` |
| Public IP | `54.164.55.106` |
| Region | `us-east-1` |

## Step 11 – Verify the Terraform Outputs and State

**Where to execute:** Ubuntu EC2 terminal.

I checked the output values.

```bash
terraform output
```

Then I checked the resources managed by Terraform.

```bash
terraform state list
```

At this stage, the resource was:

```text
aws_instance.my_server
```

This completed the first part of the practical. I had successfully created an EC2 instance using normal Terraform configuration.

---

# Part 2 – Convert the EC2 Configuration into a Reusable Module

## Step 12 – Create the Module Directory

**Where to execute:** Ubuntu EC2 terminal, inside the existing project directory.

I created a separate directory for the EC2 module.

```bash
mkdir -p modules/ec2-instance
```

I checked the directory structure.

```bash
tree
```

The `modules/ec2-instance` directory will contain the reusable EC2 configuration.

## Step 13 – Create Child Module Files

**Where to execute:** Ubuntu EC2 terminal.

I created three files inside the child module directory.

```bash
touch modules/ec2-instance/main.tf
touch modules/ec2-instance/variables.tf
touch modules/ec2-instance/outputs.tf
```

Purpose of these files:

| File | Purpose |
|---|---|
| `main.tf` | Defines the EC2 resource |
| `variables.tf` | Declares variables received by the module |
| `outputs.tf` | Returns EC2 details from the module |

## Step 14 – Configure the Child Module Resource

**Where to edit:** `modules/ec2-instance/main.tf` using Vim on the Ubuntu EC2 terminal.

```bash
vim modules/ec2-instance/main.tf
```

I added the EC2 resource.

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

The resource uses variables instead of hardcoded values. This allows the same module to be reused with different configurations.

## Step 15 – Configure Child Module Variables

**Where to edit:** `modules/ec2-instance/variables.tf` using Vim.

```bash
vim modules/ec2-instance/variables.tf
```

I declared three variables.

```hcl
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}
```

These variables allow the root module to pass values to the child module.

## Step 16 – Configure Child Module Outputs

**Where to edit:** `modules/ec2-instance/outputs.tf` using Vim.

```bash
vim modules/ec2-instance/outputs.tf
```

I added the following outputs.

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}
```

These outputs return the EC2 details created inside the child module.

## Step 17 – Connect the Root Module with the Child Module

**Where to edit:** Root-level `main.tf` using Vim.

```bash
vim main.tf
```

I replaced the original EC2 resource configuration with a module block.

```hcl
module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = "Terraform-Module-Server"
}
```

Explanation:

- `module "ec2_instance"` calls the child module.
- `source` specifies the location of the child module.
- `ami_id` passes the AMI ID.
- `instance_type` passes the EC2 instance type.
- `instance_name` passes the EC2 instance name.

The root module is responsible for calling the child module and providing its input values.

## Step 18 – Update Root Module Outputs

**Where to edit:** Root-level `outputs.tf` using Vim.

```bash
vim outputs.tf
```

I replaced the previous outputs with:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance.private_ip
}
```

Previously, the root outputs directly referenced the EC2 resource.

Now they reference the outputs returned by the child module.

For example:

```hcl
module.ec2_instance.instance_id
```

This allows the root module to access information from the child module.

## Step 19 – Migrate the Existing Terraform Resource

**Where to edit:** Root-level `main.tf` using Vim.

```bash
vim main.tf
```

Since I had already created an EC2 instance using the original root configuration, I needed to preserve the existing resource instead of creating another instance.

I added a Terraform `moved` block above the module block.

```hcl
moved {
  from = aws_instance.my_server
  to   = module.ec2_instance.aws_instance.this
}
```

My complete root-level `main.tf` became:

```hcl
moved {
  from = aws_instance.my_server
  to   = module.ec2_instance.aws_instance.this
}

module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = "Terraform-Module-Server"
}
```

The `moved` block tells Terraform that the existing resource has moved from the root configuration into the child module.

This allows Terraform to track the same EC2 instance under its new resource address without recreating it.

## Step 20 – Format, Initialize and Validate the Module

**Where to execute:** Ubuntu EC2 terminal, inside the project directory.

First, I formatted all Terraform files, including the child module files.

```bash
terraform fmt -recursive
```

Then I initialized the module configuration.

```bash
terraform init
```

Terraform detected the local EC2 module and initialized it successfully.

Finally, I validated the configuration.

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

## Step 21 – Review the Module Execution Plan

**Where to execute:** Ubuntu EC2 terminal.

```bash
terraform plan
```

Terraform identified the resource migration.

```text
aws_instance.my_server has moved to
module.ec2_instance.aws_instance.this
```

The plan showed:

```text
Plan: 0 to add, 0 to change, 0 to destroy.
```

This confirmed that Terraform recognized the existing EC2 instance under the new module address.

No duplicate EC2 instance would be created.

## Step 22 – Apply the Module Configuration

**Where to execute:** Ubuntu EC2 terminal.

```bash
terraform apply
```

I entered `yes` when Terraform asked for confirmation.

The migration completed successfully.

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

The existing EC2 instance was preserved.

## Step 23 – Verify the Module Resource and Outputs

**Where to execute:** Ubuntu EC2 terminal.

I checked the Terraform state.

```bash
terraform state list
```

Output:

```text
module.ec2_instance.aws_instance.this
```

This confirmed that Terraform was now managing the EC2 instance through the child module.

I also checked the outputs.

```bash
terraform output
```

Output:

```text
instance_id = "i-06075ca7fba46d2e2"
private_ip  = "172.31.27.1"
public_ip   = "54.164.55.106"
```

The instance ID and IP addresses remained unchanged after the migration.

## Step 24 – Verify the Final Project Structure

**Where to execute:** Ubuntu EC2 terminal.

```bash
tree -a -I '.terraform'
```

The final project structure was:

```text
terraform-day3-module/
│
├── .terraform.lock.hcl
├── .gitignore
├── provider.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
│
└── modules/
    └── ec2-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Step 25 – Create a .gitignore File

**Where to edit:** Root project directory on the Ubuntu EC2 terminal.

```bash
vim .gitignore
```

I added:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
crash.log
```

This prevents local Terraform files and potentially sensitive variable values from being uploaded to GitHub.

I kept `.terraform.lock.hcl` because it records the selected provider versions.

---

# Part 3 – Push the Practical to GitHub

## Step 26 – Copy the Practical Files into the GitHub Repository

**Where to execute:** Ubuntu EC2 terminal.

I navigated to my GitHub repository.

```bash
cd ~/My-Terraform-Journey
```

Then I entered the Day 5 practical folder.

```bash
cd "05 - Terraform Modules Practicals"
```

I copied the root Terraform files.

```bash
cp ~/terraform-day3-module/provider.tf .
cp ~/terraform-day3-module/main.tf .
cp ~/terraform-day3-module/variables.tf .
cp ~/terraform-day3-module/outputs.tf .
cp ~/terraform-day3-module/.gitignore .
cp ~/terraform-day3-module/.terraform.lock.hcl .
```

Then I copied the child module directory.

```bash
cp -r ~/terraform-day3-module/modules .
```

I verified the copied files.

```bash
ls -la
tree
```

I intentionally did not copy:

- `.terraform/`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `terraform.tfvars`

## Step 27 – Commit and Push the Files to GitHub

**Where to execute:** Ubuntu EC2 terminal, inside the Day 5 practical folder in my GitHub repository.

First, I checked the Git status.

```bash
git status
```

Then I staged the files.

```bash
git add .
```

I committed the changes.

```bash
git commit -m "Added Terraform EC2 module practical"
```

Finally, I pushed the files to GitHub.

```bash
git push origin main
```

**GitHub Repository:**

[My-Terraform-Journey](https://github.com/Yuvii2102/My-Terraform-Journey)

**Day 5 Practical Folder:**

[05 - Terraform Modules Practicals](https://github.com/Yuvii2102/My-Terraform-Journey/tree/main/05%20-%20Terraform%20Modules%20Practicals)

---

# Where to Execute the Commands

| Content | Where to Use It |
|---|---|
| `mkdir`, `cd`, `touch`, `tree`, `ls` | Ubuntu EC2 terminal |
| `vim provider.tf`, `vim main.tf` and other file editing commands | Ubuntu EC2 terminal using Vim |
| `terraform fmt`, `terraform init`, `terraform validate` | Ubuntu EC2 terminal inside the Terraform project directory |
| `terraform plan`, `terraform apply`, `terraform output` | Ubuntu EC2 terminal inside the Terraform project directory |
| `terraform state list` | Ubuntu EC2 terminal inside the Terraform project directory |
| `git add`, `git commit`, `git push` | Ubuntu EC2 terminal inside the GitHub repository |
| Verify EC2 instance | AWS Console → EC2 → Instances |
| Verify GitHub files | GitHub → My-Terraform-Journey → 05 - Terraform Modules Practicals |

**Important:** Always run Terraform commands from the correct Terraform project directory. Run Git commands from the corresponding GitHub repository directory.

---

# Key Learnings

1. Learned how Terraform Modules help organize and reuse infrastructure code.
2. Created an EC2 instance using Terraform variables and outputs.
3. Understood the difference between root modules and child modules.
4. Created a reusable EC2 module with separate resource, variable and output files.
5. Learned how to pass input variables from the root module to the child module.
6. Learned how to retrieve child module outputs from the root module.
7. Used a Terraform `moved` block to migrate an existing resource into a module without recreating it.
8. Verified the resource migration using Terraform state commands.
9. Learned how to organize and push Terraform module projects to GitHub.

## Conclusion

Today, I learned how to create reusable Terraform modules by converting a normal EC2 configuration into a separate child module.

I also understood how root modules communicate with child modules using input variables and outputs.

One important thing I learned was how to migrate an existing resource into a module using a `moved` block without destroying or recreating the EC2 instance.

This practical helped me understand how Terraform Modules make infrastructure code more organized, reusable and easier to maintain.
