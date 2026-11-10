# Day 3 - Terraform Modules

## 1. Introduction

In this session, I learned about one of the most important concepts in Terraform called **Modules**.

Terraform modules help us organise infrastructure code into smaller parts and reuse the same code in different projects.

Instead of writing the same Terraform configuration again and again, we can create a module once and use it whenever required.

For example, if multiple teams need to create EC2 instances, we can create one reusable EC2 module and allow all the teams to use it.

## 2. What is a Terraform Module?

A Terraform module is a collection of Terraform configuration files that work together to create and manage infrastructure.

In simple words:

**A module is a reusable block of Terraform code that we can use in different projects without writing the same configuration again.**

For example, imagine we want to create EC2 instances for multiple projects.

Instead of writing the EC2 resource configuration separately for every project, we can create an EC2 module and reuse it.

This saves time and makes our Terraform code easier to manage.

## 3. Why Do We Need Terraform Modules?

Let's understand this with a real-world example.

Imagine a company has a large application containing thousands of lines of code. Everything is written in one single application.

This creates several problems:

1. **Difficult to understand:** New developers take more time to understand the complete application.
2. **Difficult to maintain:** A small change can affect other parts of the application.
3. **Lack of ownership:** It becomes difficult to identify who is responsible for each part of the code.
4. **Difficult testing:** Testing the entire application for every small change takes more time.

To solve these problems, developers use an architecture called **Microservices**.

Instead of keeping everything in one application, they divide it into smaller services.

Terraform has a similar concept called **Modules**.

### Example in Terraform

Imagine a company uses AWS and has multiple infrastructure requirements.

A DevOps engineer may need to manage:

- EC2 instances
- VPC
- S3 buckets
- Load Balancers
- EKS clusters
- Lambda functions

If all these resources are written inside one large Terraform project, maintaining the project becomes difficult.

Instead, we can divide the infrastructure into separate modules.

For example:

- EC2 Module
- VPC Module
- S3 Module
- EKS Module

Each module manages a particular part of the infrastructure.

This makes the project easier to understand, maintain and reuse.

## 4. Advantages of Terraform Modules

Terraform modules provide several advantages.

| Advantage | Explanation |
|---|---|
| Modularity | Divides large Terraform configurations into smaller parts. |
| Reusability | Allows us to reuse the same code in multiple projects. |
| Easy Maintenance | We can update a module without changing the same code in multiple projects. |
| Simplified Collaboration | Different team members can work on different modules. |
| Versioning | We can maintain and use different versions of modules. |
| Abstraction | Users can use a module without understanding every internal detail. |
| Testing | Individual modules can be tested separately. |
| Documentation | Each module can have its own documentation. |
| Scalability | We can extend infrastructure by adding more modules. |

### Example of Reusability

Imagine two development teams need EC2 instances.

**Without Modules:**

- Team XYZ writes the EC2 configuration.
- Team ABC writes the same EC2 configuration again.

The same code is maintained in two different places.

**With Modules:**

- We create one reusable EC2 module.
- Team XYZ uses that module.
- Team ABC also uses the same module.

Both teams can pass different values while using the same module.

This is called **Code Reusability**.

## 5. What is a Root Module?

The root module is the main Terraform configuration from which we execute Terraform commands.

For example:

```text
terraform-project/
│
├── main.tf
├── variables.tf
└── outputs.tf
```

When we run Terraform commands from this directory, this configuration is treated as the root module.

## 6. What is a Child Module?

A child module is a module that is called by another module.

For example, we can create an EC2 module inside a separate folder and call it from our root module.

```text
terraform-project/
│
├── main.tf
│
└── modules/
    │
    └── ec2-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Here:

- The main project is the **Root Module**.
- The `ec2-instance` folder contains the **Child Module**.

The root module calls the child module and passes the required values.

## 7. How Do We Call a Module?

In Terraform, we use the `module` block to call another module.

Example:

```hcl
module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_value           = "YOUR_AMI_ID"
  instance_type_value = "t2.micro"
  subnet_id_value     = "YOUR_SUBNET_ID"
}
```

Let's understand the configuration.

| Attribute | Explanation |
|---|---|
| `module` | Tells Terraform that we are calling a module. |
| `ec2_instance` | Name given to the module block. |
| `source` | Specifies the location of the module. |
| `ami_value` | Passes the AMI ID to the module. |
| `instance_type_value` | Passes the EC2 instance type. |
| `subnet_id_value` | Passes the subnet ID. |

The source:

```hcl
source = "./modules/ec2-instance"
```

tells Terraform to find the module inside the local `modules/ec2-instance` directory.

The child module must define the input variables that receive these values.

## 8. How Do Modules Work?

The execution process is simple:

1. The root module calls the child module.
2. The root module passes the required input values.
3. The child module receives those values through its variables.
4. The child module uses those values to define AWS resources.
5. Terraform communicates with AWS and creates the infrastructure.

### Execution Commands

```bash
terraform init
terraform plan
terraform apply
```

- `terraform init` initializes the project and prepares the required modules and providers.
- `terraform plan` displays the infrastructure changes.
- `terraform apply` applies the configuration and creates the infrastructure.

## 9. Can We Store Modules in GitHub?

Yes. We can store Terraform modules in a separate GitHub repository and reuse them in different projects.

For example:

```text
terraform-modules/
│
├── ec2-instance/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── s3/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Here, I have organised different reusable modules inside one repository.

Other Terraform projects can use these modules by providing their GitHub repository location in the `source` argument.

Example:

```hcl
module "ec2_instance" {
  source = "git::https://github.com/USERNAME/terraform-modules.git//ec2-instance?ref=v1.0.0"
}
```

Here:

- `git::` specifies that the module comes from a Git repository.
- The URL specifies the repository location.
- `//ec2-instance` specifies the module directory.
- `?ref=v1.0.0` specifies the Git version or reference to use.

The repository must be accessible to the person executing the Terraform project.

## 10. What is Terraform Registry?

Terraform Registry is a platform where we can find and use publicly available Terraform providers and modules.

Website: https://registry.terraform.io/

For example, if we need an EC2 module, we can search for existing AWS EC2 modules in Terraform Registry.

Instead of writing the complete configuration ourselves, we can use an existing module.

Before using a public module, we should check:

- Who maintains the module?
- Is it actively maintained?
- Which provider versions does it support?
- What resources does it create?
- Is it suitable for our requirements?

Companies can also create their own modules and store them in private GitHub repositories.

This gives them more control over their infrastructure code.

## 11. Public Modules vs Private Modules

| Public Modules | Private Modules |
|---|---|
| Available publicly | Accessible only to authorised users |
| Can be discovered through Terraform Registry or public repositories | Usually stored in private repositories or registries |
| Maintained by external developers or organisations | Maintained by the organisation's own team |
| Must be checked before using | Can follow the organisation's requirements and standards |

In organisations, teams may prefer maintaining their own private modules because they have better control over the code and its maintenance.

## 12. Important Interview Questions

**1. What is a Terraform module?**

A Terraform module is a collection of Terraform configuration files used to create reusable and organised infrastructure code.

**2. Why do we use Terraform modules?**

We use modules to improve code reusability, modularity, maintainability and collaboration.

**3. What is a root module?**

The root module is the main Terraform configuration from which we execute Terraform commands.

**4. What is a child module?**

A child module is a module that is called by another module.

**5. What is the source argument?**

The `source` argument specifies where Terraform should find the module.

**6. Can we reuse a module in multiple projects?**

Yes. We can reuse modules from local directories, Git repositories and Terraform Registry.

**7. What is Terraform Registry?**

Terraform Registry is a platform where developers can discover and use Terraform providers and modules.

**8. Does every module need a terraform.tfvars file?**

No. A reusable module generally defines input variables, and the root module passes values to those variables.

## 13. What I Learned

In this session, I learned about Terraform modules and why they are important when managing large infrastructure projects.

I understood how modules help us divide large configurations into smaller parts and reuse the same code across multiple projects.

I also learned about root modules, child modules, the `module` block, the `source` argument, GitHub-based modules and Terraform Registry.

The main takeaway is:

**Write the infrastructure code once and reuse it whenever required.**
