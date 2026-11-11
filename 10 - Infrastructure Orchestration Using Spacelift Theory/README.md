# Infrastructure Orchestration Using Spacelift

## 1. Introduction

In DevOps, infrastructure provisioning and configuration management are two important tasks.

We use different tools for these tasks:

- **Terraform:** Used to create and manage infrastructure.
- **Ansible:** Used to configure servers and install software.

Both tools work well for their respective tasks. But managing them separately can become difficult when working with large infrastructure.

For example, Terraform may create EC2 instances, but Ansible should execute only after those instances are ready.

This is where Infrastructure Orchestration becomes useful.

## 2. What Is Infrastructure Orchestration?

Infrastructure Orchestration means coordinating different tools and automating their execution in the correct order.

For example:

1. Terraform creates EC2 instances.
2. Terraform provides the IP addresses of those instances.
3. Ansible uses those IP addresses to connect to the instances.
4. Ansible installs and configures the required software.

An orchestrator manages this complete workflow and reduces manual work.

## 3. What Is Spacelift?

Spacelift is an Infrastructure Orchestration platform that helps us manage and automate infrastructure workflows.

It supports tools such as Terraform, Ansible, OpenTofu, Terragrunt, CloudFormation and Pulumi.

Instead of manually coordinating different tools, we can use Spacelift to manage their execution.

**In simple words:** Terraform and Ansible perform the actual work, while Spacelift coordinates them.

**Reference:** [Spacelift Official Documentation](https://docs.spacelift.io/)

## 4. Why Do We Need Spacelift?

Imagine a company needs to create multiple EC2 instances and install software on all of them.

Without an orchestrator, a DevOps engineer may need to:

- Execute Terraform to create EC2 instances.
- Collect the public IP addresses.
- Update the Ansible inventory file.
- Execute Ansible playbooks manually.
- Make sure everything runs in the correct order.

With Spacelift, we can automate this workflow.

Some important benefits are:

- Automates the execution order.
- Connects different infrastructure tools.
- Reduces manual work.
- Provides access control.
- Helps enforce infrastructure policies.
- Supports cloud integrations.

## 5. Important Components of Spacelift

There are five main concepts I learned.

### 5.1 Stacks

A Stack is the main building block of Spacelift.

It connects a GitHub repository containing infrastructure code with a tool such as Terraform or Ansible.

For example, in our project, we use two stacks:

- Terraform Stack – Creates EC2 instances.
- Ansible Stack – Installs software on those instances.

### 5.2 Spaces

Spaces help organize stacks and other Spacelift resources.

For example, an organization can create separate spaces for:

- Development
- Testing
- Production

Each space can contain resources related to that environment.

### 5.3 Contexts

Contexts allow us to share variables, environment variables and files across different stacks.

For example, Terraform needs a public SSH key to create EC2 instances, while Ansible needs the private SSH key to connect to those instances.

We can share the required files through a Spacelift Context.

### 5.4 Cloud Integration

Cloud Integration connects Spacelift with cloud providers such as AWS, Azure and GCP.

For example, we can connect Spacelift to AWS using an IAM role.

This allows Spacelift to access and manage the required AWS resources.

### 5.5 Policies

Policies help organizations enforce rules and restrictions during infrastructure deployments.

For example, a company may not allow EC2 instances to be created with unrestricted inbound traffic.

Policies help enforce such requirements.

**Reference:** [Spacelift Concepts](https://docs.spacelift.io/)

## 6. Other Important Concepts

### 6.1 Stack Dependencies

Stack Dependencies define the execution order between different stacks.

For example:

- Terraform Stack must execute first.
- Ansible Stack must execute after Terraform completes successfully.

This is important because Ansible needs the IP addresses of the EC2 instances created by Terraform.

### 6.2 Hooks

Hooks allow us to execute commands at specific stages of a stack run.

There are two commonly used hooks:

- **Before Hook:** Executes commands before the main stack operation.
- **After Hook:** Executes commands after the main stack operation.

For example, we can use a Before Hook to create an Ansible inventory file using the EC2 IP addresses received from Terraform.

### 6.3 Terraform Outputs

Terraform Outputs allow us to display or share information generated during infrastructure creation.

For example, Terraform can provide the public IP addresses of created EC2 instances.

Ansible can then use these IP addresses.

### 6.4 Ansible Inventory

Ansible Inventory is a file that contains the IP addresses or hostnames of the machines Ansible needs to manage.

For example:

```ini
[all]
13.200.10.11
13.200.10.12
13.200.10.13
```

These are example IP addresses.

Ansible reads the inventory file to identify which machines it should connect to.

### 6.5 RBAC (Role-Based Access Control)

RBAC controls what different users can access and manage.

For example:

- Admin – Can manage infrastructure and users.
- Developer – Can perform permitted deployments.
- Viewer – Can view infrastructure information.

This helps organizations control access based on user roles.

**Reference:** [Spacelift Documentation](https://docs.spacelift.io/)

## 7. How Terraform and Ansible Work Together

Let's understand this with a simple example.

Imagine we need three EC2 instances and want to install the `htop` package on all of them.

The workflow is:

1. Terraform creates three EC2 instances.
2. Terraform generates their public IP addresses.
3. Spacelift shares those outputs with the Ansible Stack.
4. Ansible uses the IP addresses to create or update its inventory.
5. Ansible connects to the EC2 instances using SSH.
6. Ansible installs the `htop` package on all three instances.

This complete process is managed through Spacelift.

## 8. Project Architecture

The following diagram shows how the tools work together.

```text
             GitHub Repository
                     |
          +----------+----------+
          |                     |
          v                     v
     Terraform Code        Ansible Code
          |                     |
          v                     |
    Terraform Stack              |
          |                     |
          v                     |
      AWS Cloud                 |
          |                     |
          v                     |
    Create EC2 Instances        |
          |                     |
          v                     |
    Generate Public IPs         |
          |                     |
          +----------+----------+
                     |
                     v
              Ansible Stack
                     |
                     v
              Inventory File
                     |
                     v
             Ansible Playbook
                     |
                     v
              Install Software
                     |
                     v
              EC2 Instances
```

## 9. Key Learnings

Through this topic, I learned:

- What Infrastructure Orchestration means.
- Why Terraform and Ansible are used together.
- What Spacelift is and why it is useful.
- The difference between Stacks and Spaces.
- How Contexts help share files and variables.
- How Cloud Integration connects Spacelift with AWS.
- How Stack Dependencies control execution order.
- How Hooks automate commands.
- How Terraform Outputs are shared with Ansible.
- What Ansible Inventory is.
- How RBAC and Policies help manage access and security.

## Conclusion

This topic helped me understand how different infrastructure automation tools can work together.

Terraform is used to provision infrastructure, while Ansible is used to configure it. Spacelift helps coordinate both tools and automates their execution.

It also helps organizations manage access, enforce policies and organize infrastructure workflows.

This gives us a better understanding of how infrastructure automation works in real-world DevOps environments.

## References

- [Spacelift Official Documentation](https://docs.spacelift.io/)
- [Spacelift Official Website](https://spacelift.io/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
