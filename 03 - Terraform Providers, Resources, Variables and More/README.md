# Day 03 - Terraform Providers, Resources, Variables and More

## Introduction

On Day 03 of my Terraform learning journey, I continued learning about Terraform and explored some important concepts that help me write better and more reusable infrastructure configurations.

I learned about Terraform providers, resources, input variables, output variables, project file structure, conditional expressions, built-in functions, formatting and debugging.

In this documentation, I have explained each concept with examples to understand how Terraform works.

## 1. Terraform Providers

### What is a Provider?

A provider is a plugin that allows Terraform to communicate with a particular platform or service.

For example, if I want to create an EC2 instance in AWS, Terraform needs the AWS provider to communicate with AWS and manage the EC2 instance.

Some examples of providers are:

- AWS
- Azure
- Google Cloud
- Kubernetes
- Docker

### Provider Categories

Terraform providers are generally divided into three categories:

| Category | Description |
|---|---|
| Official | Maintained by HashiCorp |
| Partner | Maintained by technology companies that partner with HashiCorp |
| Community | Developed and maintained by the open-source community |

### Where can I find Providers?

I can find different Terraform providers in the Terraform Registry.

Reference: https://registry.terraform.io/

For example, if I want to create an EC2 instance, I can follow these steps:

1. Open the Terraform Registry.
2. Search for the AWS provider.
3. Open the AWS provider documentation.
4. Search for `aws_instance`.
5. Check the example configuration and required arguments.

### Example: AWS Provider

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Here:

- `provider` defines the provider configuration.
- `aws` specifies the AWS provider.
- `region` specifies the AWS region where I want to create resources.

### Multi-Region Configuration

Terraform allows me to work with multiple AWS regions using provider aliases.

For example, I can configure two AWS providers for different regions.

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "us-west-2"
  alias  = "west"
}
```

Now I can use these providers in different resources.

```hcl
resource "aws_instance" "east_server" {
  provider      = aws.east
  ami           = "ami-example"
  instance_type = "t2.micro"
}

resource "aws_instance" "west_server" {
  provider      = aws.west
  ami           = "ami-example"
  instance_type = "t2.micro"
}
```

Here:

- `alias = "east"` identifies the first provider configuration.
- `alias = "west"` identifies the second provider configuration.
- `provider = aws.east` tells Terraform to use the East region configuration.
- `provider = aws.west` tells Terraform to use the West region configuration.

**Note:** The AMI ID must be valid in the region where I want to create the EC2 instance.

### Multi-Cloud Configuration

Terraform also supports multiple cloud providers in the same project.

For example, I can configure both AWS and Azure providers.

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}
```

AWS and Azure have different resource types and configurations.

For example:

- AWS EC2 uses `aws_instance`.
- Azure Linux Virtual Machine uses `azurerm_linux_virtual_machine`.

I need to refer to the respective provider documentation to understand their configurations.

**What I learned:** Providers act as a connection between Terraform and the platforms where I want to manage infrastructure. I don't need to memorise every provider configuration because I can refer to the official documentation whenever required.

## 2. Terraform Resources

### What is a Resource?

A resource represents an infrastructure component that I want Terraform to create and manage.

For example:

- EC2 Instance
- S3 Bucket
- VPC
- Security Group
- EBS Volume
- Load Balancer

If I want to create an EC2 instance using Terraform, I need to define an `aws_instance` resource.

### Resource Syntax

```hcl
resource "RESOURCE_TYPE" "RESOURCE_NAME" {
  argument1 = "value1"
  argument2 = "value2"
}
```

Here:

- `resource` tells Terraform that I am defining an infrastructure resource.
- `RESOURCE_TYPE` specifies the type of resource I want to create.
- `RESOURCE_NAME` is the name I give to that resource inside my Terraform configuration.
- Arguments define the configuration of the resource.

### Example: Creating an EC2 Instance

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"

  tags = {
    Name = "My-Terraform-Server"
  }
}
```

Explanation:

| Argument | Description |
|---|---|
| `aws_instance` | Specifies that I want to create an AWS EC2 instance |
| `my_server` | Local name given to the resource |
| `ami` | Specifies the Amazon Machine Image |
| `instance_type` | Specifies the EC2 instance type |
| `tags` | Adds identifying information to the instance |

### Difference Between Provider and Resource

| Provider | Resource |
|---|---|
| Connects Terraform to a platform | Defines the infrastructure to manage |
| Example: AWS | Example: EC2 instance |
| Configures the platform connection | Configures the actual infrastructure component |

### How I Find Resource Documentation

I can use the Terraform Registry to understand resource configurations.

For example, to create an EC2 instance:

1. Open the AWS provider documentation.
2. Search for `aws_instance`.
3. Open the EC2 instance resource documentation.
4. Check the example configuration.
5. Read the argument reference to understand the available arguments.
6. Use the required arguments in my Terraform configuration.

Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

**What I learned:** I don't need to memorise every resource or its arguments. I need to understand the resource I want to create and know how to refer to its official documentation.

## 3. Terraform Variables

### What are Variables?

Variables allow me to pass values into my Terraform configuration instead of directly hardcoding them inside resources.

For example, when creating an EC2 instance, I need to specify an AMI ID and instance type.

Without variables, I would write the values directly inside the resource. If I want to change them, I need to edit the configuration.

Variables make this process easier and allow me to reuse the same configuration with different values.

### Input Variables

Input variables allow me to provide values to my Terraform configuration.

I can define input variables using the `variable` block.

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0d97d7f07b25dd693"
}
```

Explanation:

| Argument | Description |
|---|---|
| `variable` | Defines an input variable |
| `instance_type` | Name of the variable |
| `description` | Explains the purpose of the variable |
| `type` | Specifies the data type |
| `default` | Defines the default value |

Here, `string` means the variable stores text.

### Using Variables Inside Resources

After defining variables, I can access them using `var`.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "My-Terraform-Server"
  }
}
```

Here:

- `var.ami_id` retrieves the value of the `ami_id` variable.
- `var.instance_type` retrieves the value of the `instance_type` variable.

If I don't provide another value, Terraform uses the default values defined in the variable blocks.

### Why are Input Variables Useful?

Suppose I want to create EC2 instances for different environments.

| Environment | Instance Type |
|---|---|
| Development | `t2.micro` |
| Testing | `t3.micro` |
| Production | `t3.small` |

Instead of manually changing my resource configuration every time, I can provide different variable values.

This makes my Terraform configuration reusable and easier to maintain.

## 4. Terraform Output Variables

### What are Output Variables?

Output variables allow me to display useful information about the infrastructure created by Terraform.

For example, after creating an EC2 instance, I may want to know:

- EC2 Instance ID
- Public IP Address
- Private IP Address
- Public DNS Name

Instead of manually checking the AWS Console, I can use output variables to display this information.

### Creating an output.tf File

I can define output variables using the `output` block.

Example:

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

Explanation:

| Argument | Description |
|---|---|
| `output` | Defines an output value |
| `public_ip` | Name of the output |
| `description` | Explains what information it displays |
| `value` | Specifies the information Terraform should display |

### Understanding Resource Attributes

Consider this expression:

```hcl
aws_instance.my_server.public_ip
```

- `aws_instance` is the resource type.
- `my_server` is the resource name.
- `public_ip` is the attribute I want to retrieve.

This tells Terraform to retrieve the public IP address of my EC2 instance.

### How to View Outputs

After successfully creating the EC2 instance, I can use:

```bash
terraform output
```

To display only the public IP:

```bash
terraform output public_ip
```

Terraform displays the output values defined in my configuration.

### Difference Between Input and Output Variables

| Input Variables | Output Variables |
|---|---|
| Pass values into Terraform | Display values from Terraform |
| Defined using `variable` | Defined using `output` |
| Example: AMI ID | Example: EC2 public IP |
| Accessed using `var.variable_name` | Defined using resource attributes or expressions |

**What I learned:** Input variables provide information to Terraform, while output variables help me retrieve useful information from the infrastructure.

## 5. Terraform Project File Structure

When working with Terraform, I don't have to write everything inside one `main.tf` file.

I can divide the configuration into multiple files to keep the project clean and organised.

### Recommended File Structure

```text
terraform-practice/
│
├── main.tf
├── provider.tf
├── variables.tf
├── output.tf
└── terraform.tfvars
```

### 1. main.tf

This file contains the main infrastructure resources I want to create.

Example:

```hcl
resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

### 2. provider.tf

This file contains the provider configuration.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### 3. variables.tf

This file defines the input variables used in my project.

Example:

```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

### 4. output.tf

This file defines the output values I want Terraform to display.

Example:

```hcl
output "public_ip" {
  value = aws_instance.my_server.public_ip
}
```

### 5. terraform.tfvars

This file stores the actual values for my input variables.

Example:

```hcl
ami_id        = "ami-0d97d7f07b25dd693"
instance_type = "t2.micro"
```

### How These Files Work Together

1. `terraform.tfvars` provides the actual variable values.
2. `variables.tf` defines the input variables.
3. `main.tf` uses those variables to define the infrastructure.
4. `provider.tf` configures the cloud provider connection.
5. Terraform creates the infrastructure.
6. `output.tf` displays useful information about the created resources.

### Does Terraform Automatically Read These Files?

Yes. Terraform automatically loads all `.tf` files in the same working directory and treats them as one configuration.

I don't need to execute each file separately.

I can simply run:

```bash
terraform init
terraform plan
terraform apply
```

### Using Different Variable Files

Terraform automatically loads a file named `terraform.tfvars`.

If I use another filename, such as `dev.tfvars`, I need to specify it while running Terraform.

```bash
terraform apply -var-file="dev.tfvars"
```

This helps me use the same Terraform configuration for different environments such as development, testing and production.

**What I learned:** Separating Terraform files makes my project easier to understand, maintain and reuse.

## 6. Terraform Conditional Expressions

### What are Conditional Expressions?

Conditional expressions allow Terraform to select a value based on whether a condition is true or false.

In simple words, if a condition is true, Terraform uses one value. If it is false, Terraform uses another value.

Terraform uses the ternary operator for conditional expressions.

### Syntax

```hcl
condition ? true_value : false_value
```

### Example: Choosing an EC2 Instance Type

Suppose I want to create EC2 instances for two environments:

- Development
- Production

I want development to use `t2.micro` and production to use `t3.small`.

I can achieve this using a conditional expression.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

locals {
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
}

resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = local.instance_type
}
```

### Understanding the Conditional Expression

Consider this line:

```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

| Part | Description |
|---|---|
| `var.environment == "prod"` | Checks whether the environment is production |
| `?` | If the condition is true |
| `"t3.small"` | Value selected when true |
| `:` | Otherwise |
| `"t2.micro"` | Value selected when false |

### Scenario 1: Development

If the environment is `dev`, the condition becomes false.

Terraform selects:

```hcl
instance_type = "t2.micro"
```

### Scenario 2: Production

If the environment is `prod`, the condition becomes true.

Terraform selects:

```hcl
instance_type = "t3.small"
```

### What are Locals?

The example also uses a `locals` block.

Locals allow me to define values or expressions that I can reuse inside my Terraform configuration.

Example:

```hcl
locals {
  instance_type = "t2.micro"
}
```

I can access a local value using:

```hcl
local.instance_type
```

### Difference Between Variables and Locals

| Variables | Locals |
|---|---|
| Used to receive input values | Used to define reusable values or expressions |
| Accessed using `var` | Accessed using `local` |
| Can have default values | Defined inside a `locals` block |

### Why are Conditional Expressions Useful?

- They help me select different configurations for different environments.
- They allow me to use different EC2 instance types based on conditions.
- They help enable or disable certain configurations.
- They reduce the need to manually change values.

**What I learned:** Conditional expressions help me write flexible Terraform configurations by selecting values based on conditions.

## 7. Terraform Built-in Functions and Maps

### What are Terraform Built-in Functions?

Terraform provides built-in functions that help me work with and manipulate values inside my configuration.

For example, if I have a list of names and want to find how many elements are present, I can use the `length()` function.

### The length() Function

The `length()` function returns the number of elements in a list or the number of characters in a string.

**Example 1: Using a List**

```hcl
variable "instance_names" {
  default = ["server1", "server2", "server3"]
}

output "total_instances" {
  value = length(var.instance_names)
}
```

Output:

```text
total_instances = 3
```

The list contains three elements:

- server1
- server2
- server3

The `length()` function counts these elements and returns `3`.

**Example 2: Using a String**

```hcl
output "name_length" {
  value = length("Terraform")
}
```

Output:

```text
name_length = 9
```

The word `Terraform` contains nine characters.

### What are Maps?

A map stores information in key-value pairs.

For example, I can store different EC2 instance types for different environments.

```hcl
variable "instance_types" {
  default = {
    dev  = "t2.micro"
    test = "t3.micro"
    prod = "t3.small"
  }
}
```

Here:

| Key | Value |
|---|---|
| dev | t2.micro |
| test | t3.micro |
| prod | t3.small |

### Accessing Map Values

I can access a particular value using its key.

```hcl
output "production_instance" {
  value = var.instance_types["prod"]
}
```

Output:

```text
production_instance = "t3.small"
```

Here, I used the `prod` key to retrieve its corresponding value.

**What I learned:** Functions help me work with values, while maps help me organise related information using key-value pairs.

## 8. Terraform Formatting

### What is Terraform Formatting?

When writing Terraform code, I should maintain consistent formatting so that my configuration is easy to read and understand.

Terraform provides a command called `terraform fmt`.

This command automatically formats Terraform configuration files.

### Example: Before Formatting

```hcl
resource "aws_instance" "my_server" {
ami="ami-123456"
instance_type="t2.micro"
tags={
Name="MyServer"
}
}
```

### Run the Formatting Command

```bash
terraform fmt
```

### After Formatting

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "MyServer"
  }
}
```

Terraform automatically fixes indentation and spacing.

### Useful Formatting Commands

| Command | Purpose |
|---|---|
| `terraform fmt` | Formats Terraform files in the current directory |
| `terraform fmt -recursive` | Formats files in the current directory and its subdirectories |
| `terraform fmt -check` | Checks whether files are already formatted |

**What I learned:** Terraform formatting helps me maintain clean and readable configuration files.

## 9. Terraform Debugging

### What is Debugging?

Debugging means finding and fixing errors in my Terraform configuration.

For example, suppose I accidentally write an invalid argument inside an EC2 resource.

```hcl
resource "aws_instance" "my_server" {
  ami            = "ami-123456"
  instance_type  = "t2.micro"
  wrong_argument = "hello"
}
```

Terraform may report an error because `wrong_argument` is not a valid argument for the EC2 resource.

I need to read the error message, identify the problem and correct the configuration.

### Useful Commands for Identifying Problems

| Command | Purpose |
|---|---|
| `terraform validate` | Checks whether the configuration is valid |
| `terraform plan` | Shows the changes Terraform intends to make |
| `terraform fmt` | Formats the configuration |
| `terraform providers` | Shows the providers required by the configuration |

### Terraform Debug Logs

Terraform also supports detailed logging to help investigate problems.

I can enable debugging logs using the `TF_LOG` environment variable.

```bash
export TF_LOG=DEBUG
```

Now I can run:

```bash
terraform plan
```

Terraform will produce detailed debugging information.

To disable logging:

```bash
unset TF_LOG
```

**Note:** Debug logs may contain sensitive information. I should be careful before sharing them publicly.

**What I learned:** Debugging helps me identify configuration problems, while Terraform commands such as `validate` and `plan` help me check my configuration before creating infrastructure.

## 10. Important Terraform Commands - Day 2

| Command | Purpose |
|---|---|
| `terraform init` | Initializes the Terraform working directory |
| `terraform validate` | Validates the configuration |
| `terraform fmt` | Formats Terraform files |
| `terraform fmt -check` | Checks formatting |
| `terraform plan` | Previews infrastructure changes |
| `terraform apply` | Applies the configuration |
| `terraform output` | Displays output values |
| `terraform providers` | Displays required providers |
| `terraform destroy` | Destroys managed infrastructure |

## 11. What I Learned on Day 2

Today, I learned several important Terraform concepts.

1. How Terraform providers connect to different cloud platforms.
2. How to configure multiple AWS regions using provider aliases.
3. How Terraform supports multiple cloud providers.
4. How to define infrastructure using Terraform resources.
5. How to use input variables instead of hardcoding values.
6. How to display resource information using output variables.
7. How to organise Terraform projects using separate files.
8. How to use `terraform.tfvars` to store variable values.
9. How to select values using conditional expressions.
10. How to use the `length()` function and maps.
11. How to format Terraform configurations.
12. How to identify and investigate Terraform errors.

## Conclusion

Day 2 helped me understand how to write more organised and reusable Terraform configurations.

I learned that Terraform is not just about creating infrastructure. It also provides features such as providers, variables, outputs, conditional expressions and built-in functions that make infrastructure management easier.

I also understood the importance of referring to official documentation instead of trying to memorise every resource and argument.

I will apply these concepts in my upcoming Terraform practicals and continue improving my Infrastructure as Code skills.

## References

- [Terraform Official Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform Output Values](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Terraform Local Values](https://developer.hashicorp.com/terraform/language/values/locals)
- [Terraform Conditional Expressions](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [Terraform Built-in Functions](https://developer.hashicorp.com/terraform/language/functions)
- [Terraform Formatting](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [Terraform Debugging](https://developer.hashicorp.com/terraform/internals/debugging)
