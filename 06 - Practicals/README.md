# Day 6 – Terraform State, S3 Remote Backend and State Locking

## Objective

In this practical, I learned how Terraform manages infrastructure using state files and how to configure an Amazon S3 bucket as a remote backend.

I also configured S3 versioning, encryption, public access protection and native state locking.

## 1. Project Setup

First, I created a separate directory for this practical.

```bash
mkdir terraform-day4-state
cd terraform-day4-state
```

## 2. Terraform Configuration

I created three Terraform files using Vim.

### provider.tf

This file contains the AWS provider configuration.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### variables.tf

I defined the AMI ID and EC2 instance type as input variables.

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
```

### main.tf

I created an EC2 instance using the AWS provider.

```hcl
resource "aws_instance" "state_demo" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-State-Demo"
  }
}
```

## 3. Initialize and Validate Terraform

I initialized Terraform and installed the required AWS provider.

```bash
terraform init
```

I formatted and validated the configuration.

```bash
terraform fmt
terraform validate
```

## 4. Create EC2 Using Local State

Before configuring the remote backend, I created an EC2 instance using Terraform's default local state.

```bash
terraform plan
terraform apply
```

I entered `yes` when Terraform requested confirmation.

The EC2 instance was created successfully.

**Instance details:**

- Instance ID: `i-0844772963ad47ca2`
- Instance Type: `t2.micro`
- Region: `us-east-1`
- Name: `Terraform-State-Demo`

## 5. Inspect Local Terraform State

Terraform created a local state file named `terraform.tfstate`.

I used the following commands to inspect the state.

```bash
ls -la
```

To list the resources tracked by Terraform:

```bash
terraform state list
```

To view the details of the EC2 instance:

```bash
terraform state show aws_instance.state_demo
```

The state file contained information about the EC2 instance, including its instance ID, IP addresses, AMI, instance type and other configuration details.

## 6. Create an S3 Bucket

Next, I created an S3 bucket to store the Terraform state remotely.

First, I checked whether the bucket name was available.

```bash
aws s3api head-bucket \
  --bucket yuvraj-terraform-remote-state-2026
```

Then I created the bucket in the `us-east-1` region.

```bash
aws s3api create-bucket \
  --bucket yuvraj-terraform-remote-state-2026 \
  --region us-east-1
```

I also granted my IAM user the required S3 permissions using the `AmazonS3FullAccess` policy.

## 7. Enable S3 Bucket Versioning

I enabled versioning to maintain previous versions of the Terraform state file.

```bash
aws s3api put-bucket-versioning \
  --bucket yuvraj-terraform-remote-state-2026 \
  --versioning-configuration Status=Enabled
```

To verify:

```bash
aws s3api get-bucket-versioning \
  --bucket yuvraj-terraform-remote-state-2026
```

The output showed:

```json
{
  "Status": "Enabled"
}
```

## 8. Enable Server-Side Encryption

I configured AES-256 server-side encryption to protect objects stored in the bucket.

```bash
aws s3api put-bucket-encryption \
  --bucket yuvraj-terraform-remote-state-2026 \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'
```

To verify:

```bash
aws s3api get-bucket-encryption \
  --bucket yuvraj-terraform-remote-state-2026
```

The output confirmed that AES256 encryption was enabled.

## 9. Block Public Access

I blocked all public access to the S3 bucket.

```bash
aws s3api put-public-access-block \
  --bucket yuvraj-terraform-remote-state-2026 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

To verify:

```bash
aws s3api get-public-access-block \
  --bucket yuvraj-terraform-remote-state-2026
```

All four public access settings returned `true`.

## 10. Configure S3 Remote Backend

After securing the bucket, I updated `provider.tf` with the S3 backend configuration.

```hcl
terraform {
  backend "s3" {
    bucket       = "yuvraj-terraform-remote-state-2026"
    key          = "terraform/day4/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Understanding the backend configuration

- `bucket`: Name of the S3 bucket.
- `key`: Location where the state file is stored.
- `region`: AWS region of the bucket.
- `encrypt`: Enables encryption for the remote state object.
- `use_lockfile`: Enables native S3 state locking.

## 11. Migrate Local State to S3

After configuring the backend, I migrated the existing local state file into S3.

```bash
terraform init -migrate-state
```

Terraform detected the existing local state and asked whether I wanted to copy it to the new S3 backend.

I entered:

```text
yes
```

Terraform successfully migrated the state and initialized the S3 backend.

The existing EC2 resource was preserved during migration.

## 12. Verify Remote State

I checked whether the state file was available in the S3 bucket.

```bash
aws s3 ls s3://yuvraj-terraform-remote-state-2026/ --recursive
```

The output showed:

```text
terraform/day4/terraform.tfstate
```

I also checked whether Terraform could still track the EC2 instance.

```bash
terraform state list
```

Output:

```text
aws_instance.state_demo
```

This confirmed that the resource information was available through the remote backend.

## 13. Verify State Locking Configuration

I configured native S3 state locking using:

```hcl
use_lockfile = true
```

I verified the configuration using:

```bash
grep -n "use_lockfile" provider.tf
```

Terraform automatically manages the lock file during operations that require state locking.

The lock file is temporary and is normally removed after the operation completes.

## 14. Final Verification

Finally, I ran:

```bash
terraform plan
```

Output:

```text
No changes. Your infrastructure matches the configuration.
```

This confirmed that Terraform successfully accessed the remote state and that the existing infrastructure matched my configuration.

## Final Project Structure

```text
terraform-day4-state/
│
├── main.tf
├── provider.tf
├── variables.tf
└── .terraform.lock.hcl
```

## What I Learned

1. How Terraform manages infrastructure using state files.
2. How to inspect local Terraform state.
3. How to create and configure an S3 bucket using AWS CLI.
4. How to enable S3 versioning and server-side encryption.
5. How to block public access to an S3 bucket.
6. How to configure an S3 remote backend.
7. How to migrate local Terraform state into S3.
8. How native S3 state locking works using `use_lockfile`.
9. How to verify remote state and resource tracking.

## Conclusion

In this practical, I successfully created an EC2 instance using Terraform local state and migrated the state file into an Amazon S3 remote backend.

I also configured bucket versioning, encryption, public access protection and native S3 state locking.

This practical helped me understand how Terraform state can be managed remotely instead of storing it only on a local machine.
