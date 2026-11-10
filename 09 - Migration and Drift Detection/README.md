# Terraform Interview Scenarios – Migration and Drift Detection

## 1. Introduction

In this practical, I learned about two important real-world scenarios in Terraform.

These scenarios are commonly discussed in DevOps interviews because they help us understand how Terraform works with existing infrastructure and how we can identify unexpected changes.

The two scenarios are:

1. Terraform Migration – Importing existing AWS resources into Terraform.
2. Drift Detection – Identifying changes made manually outside Terraform.

---

# Scenario 1: Terraform Migration

## 2. Understanding the Scenario

Imagine an organization already has AWS infrastructure created using AWS CloudFormation or manually through the AWS Console.

Now the organization decides to manage all its infrastructure using Terraform.

The challenge is that these resources already exist in AWS, but Terraform does not know about them.

Terraform uses its state file to keep track of the infrastructure it manages.

If a resource is not present in the Terraform state file, Terraform may try to create it again.

To avoid this, we can import the existing infrastructure into Terraform.

## 3. What Is Terraform Import?

Terraform Import allows us to bring an existing infrastructure resource under Terraform management by adding its details to the Terraform state.

It helps us manage existing resources without creating them again.

Terraform provides two useful features for this:

- `terraform plan -generate-config-out` – Generates Terraform configuration for an existing resource.
- `terraform import` – Imports an existing resource into the Terraform state.

**Sources:**
- [Terraform – Import Existing Resources](https://developer.hashicorp.com/terraform/language/import)
- [Terraform – Import Command](https://developer.hashicorp.com/terraform/cli/commands/import)

## 4. Practical: Import an Existing EC2 Instance

For this practical, I used an existing EC2 instance in AWS.

### Step 1: Create a Project Directory

Create a folder for the practical.

```bash
mkdir -p day-eight/scenario-one
cd day-eight/scenario-one
```

### Step 2: Create main.tf

```bash
vim main.tf
```

Add the AWS provider configuration and an import block.

```hcl
provider "aws" {
  region = "us-east-1"
}

import {
  to = aws_instance.example
  id = "i-xxxxxxxxxxxxxxxxx"
}
```

Replace the instance ID with your actual EC2 instance ID.

Here:

- `to` specifies the Terraform resource address.
- `id` specifies the existing AWS EC2 instance ID.

### Step 3: Initialize Terraform

```bash
terraform init
```

Terraform initializes the working directory and downloads the required AWS provider.

### Step 4: Generate the Terraform Configuration

Run:

```bash
terraform plan -generate-config-out=generated_resource.tf
```

Terraform reads the existing EC2 instance configuration from AWS and generates a Terraform resource configuration in `generated_resource.tf`.

The generated configuration may contain many arguments because Terraform retrieves both required and optional resource attributes.

Review the generated file before using it.

### Step 5: Add the Generated Configuration

Open the generated file:

```bash
vim generated_resource.tf
```

Copy the generated `aws_instance` resource block into `main.tf`.

The resource address must match the address used in the import block:

```hcl
resource "aws_instance" "example" {
  # Generated EC2 configuration
}
```

Remove the temporary `generated_resource.tf` file after copying the resource configuration.

Also remove the import block from `main.tf` because the next step uses the CLI import command.

### Step 6: Import the Existing EC2 Instance

Run:

```bash
terraform import aws_instance.example i-xxxxxxxxxxxxxxxxx
```

Replace the instance ID with your actual EC2 instance ID.

Terraform associates the existing EC2 instance with the resource address `aws_instance.example` and records its information in the state file.

### Step 7: Verify the Import

Run:

```bash
terraform plan
```

If the configuration matches the existing infrastructure, Terraform should show:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms that the existing EC2 instance is now managed by Terraform without creating another instance.

**Sources:**
- [Terraform – Generate Configuration](https://developer.hashicorp.com/terraform/language/import/generating-configuration)
- [Terraform – Import Command](https://developer.hashicorp.com/terraform/cli/commands/import)
- [Terraform – State](https://developer.hashicorp.com/terraform/language/state)

---

# Scenario 2: Drift Detection

## 5. Understanding the Scenario

Imagine a team manages hundreds of AWS resources using Terraform.

Initially, everything works correctly.

One day, a team member logs in to the AWS Console and manually changes the lifecycle configuration of an S3 bucket to fix an issue.

The change is made directly in AWS without updating the Terraform configuration.

Now there is a difference between the actual infrastructure and the configuration maintained in Terraform.

This situation is called **Configuration Drift**.

## 6. What Is Drift Detection?

Drift detection is the process of identifying differences between the actual infrastructure and the desired configuration defined in Terraform.

For example:

- Terraform configuration specifies one S3 lifecycle rule.
- Someone manually changes that rule in AWS.
- The actual AWS configuration is now different from the Terraform configuration.

Terraform can detect this difference when it refreshes its view of the infrastructure.

**Source:** [Terraform – Refreshing State](https://developer.hashicorp.com/terraform/tutorials/state/refresh)

## 7. Method 1: Using Terraform Refresh

Terraform can refresh its state information by checking the actual infrastructure.

The older command is:

```bash
terraform refresh
```

It updates the Terraform state file using the current information from the cloud provider.

However, `terraform refresh` is deprecated. The recommended approach is to use:

```bash
terraform plan -refresh-only
```

This checks for differences between the actual infrastructure and the Terraform state without proposing changes to the infrastructure.

If you want to update the state file to reflect the detected changes, review and apply a refresh-only plan:

```bash
terraform apply -refresh-only
```

We can also automate periodic checks through a scheduled CI/CD pipeline or another scheduled job.

For example, a scheduled job could run every hour and notify the team when drift is detected.

**Sources:**
- [Terraform – Refresh Command](https://developer.hashicorp.com/terraform/cli/commands/refresh)
- [Terraform – Refresh-Only Mode](https://developer.hashicorp.com/terraform/tutorials/state/refresh)
- [Terraform – Plan Command](https://developer.hashicorp.com/terraform/cli/commands/plan)

## 8. Method 2: Using AWS Audit Logs and Lambda

Another approach is to monitor manual changes using AWS auditing and event services.

For this approach, we can use:

- AWS CloudTrail – Records API activity and identifies who performed an action.
- Amazon EventBridge – Routes matching events to targets.
- AWS Lambda – Runs custom logic when an event is received.
- Amazon SNS – Sends notifications to the team.

### How It Works

1. A team member manually modifies an AWS resource.
2. AWS CloudTrail records the API activity.
3. Amazon EventBridge receives and matches the relevant event.
4. A Lambda function checks whether the affected resource is managed by Terraform.
5. The function checks the identity that performed the action.
6. If the change was made by an unexpected user instead of the approved Terraform deployment identity, it can trigger an alert.
7. Amazon SNS can send a notification to the DevOps team.

### Architecture Flow

```text
Manual Change in AWS
         |
         v
    AWS CloudTrail
         |
         v
   Amazon EventBridge
         |
         v
     AWS Lambda
         |
         v
 Check Resource and IAM Identity
         |
         v
  Amazon SNS Notification
         |
         v
      DevOps Team
```

This approach helps teams identify unexpected manual changes and understand who made them.

**Sources:**
- [AWS – CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
- [AWS – EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)
- [AWS – Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [AWS – SNS](https://docs.aws.amazon.com/sns/latest/dg/welcome.html)

## 9. Method 3: Restrict Manual Changes Using IAM Policies

Another way to reduce configuration drift is to control who can modify AWS resources.

For example:

- Allow infrastructure changes through an approved Terraform IAM role.
- Restrict direct modification permissions for regular users.
- Require approval before allowing manual infrastructure changes.
- Monitor privileged access and review changes regularly.

This reduces the chances of unexpected changes outside Terraform.

**Source:** [AWS – IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)

---

## 10. Difference Between Terraform Migration and Drift Detection

| Terraform Migration | Drift Detection |
|---|---|
| Brings existing resources under Terraform management. | Identifies unexpected infrastructure changes. |
| Uses import blocks or `terraform import`. | Uses refresh-only plans and monitoring. |
| Helps move existing infrastructure into Terraform. | Helps keep actual infrastructure aligned with Terraform configuration. |
| Requires resource IDs and matching configuration. | Requires comparing actual infrastructure with the expected configuration. |

## 11. Key Learnings

Through these scenarios, I learned how to:

- Import existing AWS resources into Terraform.
- Understand the importance of the Terraform state file.
- Generate Terraform configuration for existing resources.
- Use `terraform import` to manage existing infrastructure.
- Understand configuration drift.
- Detect changes made outside Terraform.
- Use refresh-only plans to check infrastructure changes.
- Understand how CloudTrail and EventBridge help monitor AWS activity.
- Use Lambda and SNS for automated notifications.
- Control manual infrastructure changes using IAM policies.

## Conclusion

These two scenarios helped me understand how Terraform is used in real-world DevOps environments.

In the first scenario, I learned how to bring existing AWS infrastructure under Terraform management without creating the resources again.

In the second scenario, I learned how to identify manual changes made outside Terraform and how AWS services can help monitor and notify teams about those changes.

These are important concepts to understand when working with Terraform in an organization.

## References

### Terraform Documentation
- [Terraform Import](https://developer.hashicorp.com/terraform/language/import)
- [Terraform Generate Configuration](https://developer.hashicorp.com/terraform/language/import/generating-configuration)
- [Terraform Import Command](https://developer.hashicorp.com/terraform/cli/commands/import)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
- [Terraform Refresh](https://developer.hashicorp.com/terraform/tutorials/state/refresh)

### AWS Documentation
- [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
- [Amazon EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [Amazon SNS](https://docs.aws.amazon.com/sns/latest/dg/welcome.html)
- [AWS IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
