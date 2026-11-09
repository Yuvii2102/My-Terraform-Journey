
# AWS EC2 Instance Creation Using Terraform

## Introduction

In this practical, I installed Terraform on my Ubuntu EC2 instance and used it to create an AWS EC2 instance.

I learned how to configure the AWS provider, write Terraform code, initialize the project, create infrastructure and destroy resources.

## Tools Used

- AWS EC2
- Ubuntu
- Terraform
- AWS CLI

## 1. Terraform Configuration

Created a file named `main.tf`.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
}
```

## 2. Initialize Terraform

```bash
terraform init
```

This initialized the project and downloaded the AWS provider.

## 3. Preview Infrastructure Changes

```bash
terraform plan
```

Terraform showed that one EC2 instance would be created.

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

## 4. Create EC2 Instance

```bash
terraform apply
```

I entered `yes` to confirm the operation.

Output:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## 5. Verify Terraform State

```bash
terraform state list
```

Output:

```text
aws_instance.my_server
```

Terraform also created a state file named `terraform.tfstate` to track the infrastructure.

## 6. Destroy EC2 Instance

After completing the practical, I deleted the EC2 instance using:

```bash
terraform destroy
```

Output:

```text
Destroy complete! Resources: 1 destroyed.
```

## What I Learned

- Installing Terraform on Ubuntu.
- Configuring AWS authentication.
- Understanding Terraform providers and resources.
- Finding AMI IDs through AWS Console.
- Initializing Terraform using `terraform init`.
- Previewing changes using `terraform plan`.
- Creating EC2 instances using `terraform apply`.
- Understanding Terraform state.
- Destroying infrastructure using `terraform destroy`.

## Conclusion

Through this practical, I learned how to create and manage AWS infrastructure using Terraform instead of creating resources manually through the AWS Console.
