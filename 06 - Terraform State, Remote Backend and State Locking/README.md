# Day 6 – Terraform State, Remote Backend and State Locking

## Introduction

Today, I learned about Terraform State, Remote Backend and State Locking.

The Terraform state file is one of the most important parts of Terraform because it keeps track of the infrastructure created and managed by Terraform.

I also learned why storing state files locally can create problems when multiple developers work on the same project and how we can solve these problems using AWS S3 as a remote backend.

Finally, I learned about state locking and how it helps prevent multiple users from modifying the same Terraform state at the same time.

## 1. What is a Terraform State File?

A Terraform state file stores information about the infrastructure managed by Terraform.

The default state file name is:

```text
terraform.tfstate
```

Whenever we create infrastructure using Terraform, it records the resource information in this file.

For example, when I create an EC2 instance using Terraform, the state file stores information such as:

- EC2 instance ID
- AMI ID
- Instance type
- Public IP address
- Private IP address
- Resource configuration

I can think of the Terraform state file as Terraform's memory because it helps Terraform remember the resources it has already created.

### Example

Suppose I create an EC2 instance using this configuration:

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "My-Server"
  }
}
```

When I execute:

```bash
terraform apply
```

Terraform creates the EC2 instance and records its information in `terraform.tfstate`.

### Why is the State File Important?

Suppose I created an EC2 instance and later wanted to add a new tag.

I update my configuration:

```hcl
tags = {
  Name        = "My-Server"
  Environment = "Production"
}
```

When I execute:

```bash
terraform plan
```

Terraform checks the state file and compares the existing infrastructure with the updated configuration.

It understands that the EC2 instance already exists and only the tag needs to be updated.

Instead of creating another EC2 instance, Terraform updates the existing one.

The same concept applies when I execute `terraform destroy`. Terraform uses the state file to identify the resources it manages.

### Advantages of Terraform State

- **Resource Tracking:** Keeps track of infrastructure created using Terraform.
- **Infrastructure Updates:** Helps Terraform identify changes to existing resources.
- **Resource Deletion:** Helps Terraform identify which resources it manages when destroying infrastructure.
- **Resource Information:** Stores details such as instance IDs and IP addresses.

### Commands to View Terraform State

To check the files in the project directory:

```bash
ls -la
```

To display the state information in a readable format:

```bash
terraform show
```

To list the resources managed by Terraform:

```bash
terraform state list
```

## 2. Problems with Local Terraform State

By default, Terraform stores its state file locally in the project directory.

This works well for individual practice, but it can create problems when multiple DevOps engineers work on the same project.

### Problem 1 – Sensitive Information Exposure

Terraform state files can contain sensitive information such as:

- Passwords
- API tokens
- Database credentials
- Infrastructure configuration
- Private IP addresses and other resource details

If someone gets access to the state file, they may be able to read sensitive information stored in it.

This is why state files must be protected carefully.

### Problem 2 – Problems with GitHub and Version Control

In real companies, multiple DevOps engineers work together and store their Terraform code in shared repositories such as GitHub or Bitbucket.

Consider this example:

1. Engineer A creates a Terraform project and pushes it to GitHub.
2. Engineer B clones the repository.
3. Engineer B modifies the EC2 configuration.
4. Engineer B executes `terraform apply`.
5. The local state file gets updated.

Now, Engineer B must also manage the updated state file.

If Engineer B pushes only the Terraform code and forgets to push the updated state file, the code and state can become inconsistent.

Also, if the state file is uploaded to GitHub, anyone with access to it may be able to inspect sensitive infrastructure information.

### Problem 3 – Managing State in a Team

Imagine five DevOps engineers working on the same Terraform project.

Each engineer clones the repository and works on a local copy.

If they maintain separate local state files, each person may have a different view of the infrastructure.

This can create confusion and infrastructure management problems.

**Main problems:**

- State files may expose sensitive information.
- Engineers must manage and synchronize state files manually.
- Different engineers may have inconsistent state information.
- Uploading state files to GitHub creates security risks.

## 3. What is Terraform Remote Backend?

A Terraform backend determines where Terraform stores its state file.

By default, Terraform uses a local backend, which stores the state file in the project directory.

With a remote backend, Terraform stores the state file in an external storage service instead of storing it locally.

Some examples are:

- AWS S3
- Terraform Cloud
- Azure Storage

In this practical, I will use AWS S3 as the remote backend.

### Why Do We Need a Remote Backend?

Remote backend helps solve the problems of local state management.

Instead of maintaining separate local state files, multiple engineers can work with the same remote state.

The state file is stored separately from the GitHub repository, and access can be controlled using AWS IAM permissions and bucket policies.

### How Does Remote Backend Work?

The workflow looks like this:

1. DevOps engineers clone the Terraform project from GitHub.
2. They make changes to the Terraform configuration.
3. They execute Terraform commands.
4. Terraform reads the remote state from the S3 bucket.
5. After successful infrastructure changes, Terraform updates the remote state in S3.
6. Engineers push their Terraform code changes to GitHub.

This way, the Terraform configuration is stored in GitHub while the state file is stored separately in S3.

### Configure AWS S3 as a Remote Backend

We can configure the S3 backend inside a file named `backend.tf`.

Example:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

Explanation:

| Attribute | Purpose |
|---|---|
| `backend "s3"` | Specifies AWS S3 as the backend |
| `bucket` | Name of the S3 bucket |
| `key` | Path and name of the state file inside the bucket |
| `region` | AWS region where the bucket exists |

**Important:** The S3 bucket must already exist before Terraform initializes this backend.

### Initialize the Remote Backend

After configuring the backend, execute:

```bash
terraform init
```

Terraform reads the backend configuration and connects to the S3 bucket.

When migrating an existing local state file to a remote backend, Terraform can ask whether I want to copy the existing state to the new backend. I should preserve the existing state during migration.

## 4. What is Terraform State Locking?

Terraform State Locking is a mechanism that prevents multiple users from modifying the same Terraform state simultaneously.

In simple words, only one person should be allowed to modify the same state at a time.

### Why is State Locking Important?

Imagine five DevOps engineers working on the same Terraform project.

- Engineer A wants to make an S3 bucket public.
- Engineer B wants to make the same S3 bucket private.
- Both engineers execute `terraform apply` at almost the same time.

This can create conflicting changes.

To prevent this, Terraform uses state locking.

### How Does State Locking Work?

1. Engineer A executes `terraform apply`.
2. Terraform checks whether the state is already locked.
3. If the state is available, Engineer A acquires the lock.
4. Engineer B tries to execute Terraform but cannot acquire the lock.
5. Engineer A completes the operation.
6. Terraform releases the lock.
7. Engineer B can now acquire the lock and execute the operation.

This ensures that multiple engineers do not modify the same state simultaneously.

## 5. State Locking Using DynamoDB

In the video, Amazon DynamoDB is used for Terraform state locking.

DynamoDB is an AWS managed NoSQL database service.

It stores the lock information so Terraform can check whether another operation is already using the state.

### DynamoDB Configuration

The following configuration creates a DynamoDB table for Terraform locking.

```hcl
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

Explanation:

| Attribute | Purpose |
|---|---|
| `name` | Name of the DynamoDB table |
| `billing_mode` | Uses pay-per-request billing |
| `hash_key` | Defines the partition key |
| `LockID` | Identifies the lock |
| `type = "S"` | Specifies a string attribute |

### Configure DynamoDB in the S3 Backend

The video demonstrates adding the DynamoDB table name to the S3 backend configuration.

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
```

Now Terraform uses:

- S3 for remote state storage.
- DynamoDB for state locking.

**Note:** This is the approach demonstrated in the video. Current Terraform versions also support native S3 state locking using `use_lockfile = true`. DynamoDB-based S3 locking is deprecated, so I will learn and use the current approach in my practical.

## 6. Important Terraform Commands

| Command | Purpose |
|---|---|
| `terraform init` | Initializes Terraform and configures the backend |
| `terraform plan` | Shows the infrastructure changes |
| `terraform apply` | Applies the infrastructure changes |
| `terraform show` | Displays the current state information |
| `terraform state list` | Lists resources managed by Terraform |
| `terraform destroy` | Destroys the resources managed by Terraform |

## 7. Interview Questions and Answers

### Q1. What is a Terraform State File?

A Terraform state file stores information about the infrastructure managed by Terraform. It helps Terraform track existing resources and identify the changes required during plan, apply and destroy operations.

### Q2. Why is Terraform State important?

It helps Terraform understand which resources already exist and compare the current infrastructure with the desired configuration.

### Q3. What is a Remote Backend?

A remote backend stores the Terraform state file in an external storage service instead of storing it locally. AWS S3 is one example.

### Q4. Why should we avoid pushing Terraform State files to GitHub?

State files may contain sensitive information. Uploading them to GitHub can expose infrastructure details and secrets to people who have repository access.

### Q5. How would you manage Terraform State in a team?

I would store Terraform configuration files in a shared GitHub repository and configure AWS S3 as the remote backend. I would also restrict access to the S3 bucket using IAM permissions and configure state locking to prevent concurrent modifications.

### Q6. What is Terraform State Locking?

State locking prevents multiple Terraform operations from modifying the same state simultaneously.

### Q7. Which AWS service is used for state locking in the video?

Amazon DynamoDB.

### Q8. What happens if another engineer tries to execute Terraform while the state is locked?

Terraform cannot acquire the lock and normally stops with a locking error instead of proceeding with the conflicting operation.

---

## Conclusion

Today, I learned how Terraform manages infrastructure using state files and why state files are important.

I also understood the problems of storing state files locally and pushing them to GitHub when multiple engineers work on the same project.

To solve these problems, I learned about Terraform Remote Backend using AWS S3 and State Locking using DynamoDB.

These concepts helped me understand how Terraform state can be managed more securely and consistently in a team environment.
