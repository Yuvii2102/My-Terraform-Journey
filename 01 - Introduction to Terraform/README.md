# Introduction to Terraform

## 1. What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp.

It helps us create, manage and delete cloud resources using code instead of doing everything manually through the cloud console.

For example, we can use Terraform to create EC2 instances, S3 buckets, VPCs and other AWS resources.

## 2. What is Infrastructure as Code (IaC)?

Infrastructure as Code means managing infrastructure using code.

Instead of creating resources manually through the AWS Console, we write configuration files and use tools like Terraform to automate the process.

**Benefits of IaC:**
- Saves time and reduces manual work.
- Reduces human errors.
- Makes infrastructure easy to manage.
- Allows us to reuse configurations.

## 3. Why Terraform?

Different cloud providers have their own IaC tools.

- AWS – CloudFormation
- Azure – Azure Resource Manager (ARM)
- OpenStack – Heat Templates

Learning a different tool for every cloud provider can be difficult.

Terraform solves this problem by providing a common way to manage infrastructure across multiple cloud providers like AWS, Azure and GCP.

That's why Terraform is an important skill for DevOps and Cloud Engineers.

## 4. What is HCL?

HCL stands for HashiCorp Configuration Language.

It is the language used to write Terraform configuration files.

Terraform files use the `.tf` extension.

Example:

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

This configuration describes an AWS EC2 instance.

## 5. What is a Terraform Provider?

A provider is a plugin that allows Terraform to communicate with cloud platforms and other services.

Examples:
- AWS Provider
- Azure Provider
- Google Cloud Provider

Example of AWS provider configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform to use AWS in the `us-east-1` region.

## 6. What is a Resource?

A resource is an infrastructure component that we want Terraform to create or manage.

Examples:
- EC2 instance
- S3 bucket
- VPC
- Security group

Example:

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

Here:
- `aws_instance` is the resource type.
- `my_server` is the resource name.

## 7. Terraform Lifecycle

Terraform follows four main commands when managing infrastructure.

| Command | Purpose |
|---|---|
| `terraform init` | Initializes the Terraform project and downloads required providers. |
| `terraform plan` | Shows what changes Terraform will make. |
| `terraform apply` | Creates or updates the infrastructure. |
| `terraform destroy` | Destroys the infrastructure managed by Terraform. |

**Basic workflow:**

```text
terraform init
      |
terraform plan
      |
terraform apply
      |
terraform destroy
```

## 8. What is Terraform State File?

Terraform creates a file called `terraform.tfstate` to keep track of the infrastructure it manages.

It stores information about the resources created through Terraform.

**Important points:**
- Terraform automatically creates and updates the state file.
- It helps Terraform track existing resources.
- It may contain sensitive information.
- Never upload the state file to a public GitHub repository.

We will learn more about Terraform State in upcoming practicals.

## 9. AWS Authentication

Terraform needs permission to access AWS before creating resources.

We can configure AWS CLI using:

```bash
aws configure
```

It asks for:

- AWS Access Key ID
- AWS Secret Access Key
- Default region
- Output format

To verify AWS authentication:

```bash
aws sts get-caller-identity
```

Terraform can use the AWS credentials configured on the machine.

For real projects, it is better to use IAM roles or other secure authentication methods instead of root-user access keys.

## 10. Tools Used

- Terraform
- AWS
- AWS CLI
- Visual Studio Code
- HashiCorp Terraform Extension

## Conclusion

In this lesson, I learned the basics of Terraform and Infrastructure as Code.

I understood how Terraform helps automate cloud infrastructure, what providers and resources are, how HCL works and the basic Terraform lifecycle.

These concepts will help me understand and perform Terraform practicals in the upcoming lessons.
