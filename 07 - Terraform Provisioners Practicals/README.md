# Day 7 : Terraform Provisioners Practical

## Project: Deploying a Flask Application on AWS EC2 Using Terraform Provisioners

## 1. Introduction

In this practical, I used Terraform Provisioners to deploy a simple Flask application on an AWS EC2 instance.

I created the required AWS infrastructure using Terraform and explored three types of provisioners:

- **File Provisioner:** Copies files from the Terraform Control Node to the EC2 instance.
- **Remote-exec Provisioner:** Executes commands on the remote EC2 instance.
- **Local-exec Provisioner:** Executes commands on the machine where Terraform is running.

I also learned how Terraform uses SSH authentication to connect to a newly created EC2 instance.

## 2. Architecture

I used two EC2 instances for this practical:

| Machine | Purpose |
|---|---|
| Terraform Control Node | Runs Terraform and manages AWS infrastructure |
| Application EC2 Instance | Hosts the Flask application |

**Workflow:**

1. Terraform creates the AWS infrastructure.
2. Terraform uses SSH to connect to the application EC2 instance.
3. File Provisioner copies the Flask application.
4. Remote-exec installs the required packages.
5. I manually start the Flask application and verify it in a browser.
6. Local-exec runs a command on the Terraform Control Node.

## 3. Create the Project Directory

**Terminal:** Terraform Control Node

I created a separate directory for this practical.

```bash
mkdir -p ~/terraform-provisioners
cd ~/terraform-provisioners
```

I created the files required for the project:

```bash
touch main.tf provider.tf variables.tf app.py
```

**Command references:**
- [Linux mkdir command](https://man7.org/linux/man-pages/man1/mkdir.1.html)
- [Linux cd and touch commands](https://www.gnu.org/software/bash/manual/)

## 4. Generate an SSH Key Pair

Before connecting to the EC2 instance, I generated an SSH key pair on my Terraform Control Node.

### Method 1: Using the complete command

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-provisioner-key
```

When prompted for a passphrase, I pressed Enter twice to leave it empty for this lab.

### Method 2: Using the interactive command

I can also generate a key pair using:

```bash
ssh-keygen
```

The command prompts me for the following details:

1. File location: `~/.ssh/terraform-provisioner-key`
2. Passphrase: Press Enter to leave it empty.
3. Confirm passphrase: Press Enter again.

The interactive command uses the system's default key type. On current OpenSSH versions, this is Ed25519.

### Generated files

Both methods generate two files:

| File | Purpose |
|---|---|
| `terraform-provisioner-key` | Private key |
| `terraform-provisioner-key.pub` | Public key |

I verified the generated files using:

```bash
ls -l ~/.ssh/terraform-provisioner-key*
```

**Important:** The private key must remain secure. I never upload it to GitHub or share it with others.

**Official documentation:** [OpenSSH ssh-keygen Manual](https://man.openbsd.org/ssh-keygen)

## 5. Configure the AWS Provider

I configured the AWS provider in `provider.tf`.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform to create and manage resources in the US East (N. Virginia) region.

**Official documentation:** [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 6. Create Variables

I defined the infrastructure values in `variables.tf` so that I could reuse and modify them easily.

```hcl
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_id" {
  default = "ami-0d97d7f07b25dd693"
}

variable "instance_type" {
  default = "t2.micro"
}
```

**Official documentation:** [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

## 7. Create the Flask Application

I created a simple Flask application in `app.py`.

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello Terraform! Application deployed using Terraform Provisioners."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

The application listens on port 80 and returns a simple message when someone accesses its home page.

**Official documentation:** [Flask Quickstart](https://flask.palletsprojects.com/en/stable/quickstart/)

## 8. Create AWS Infrastructure Using Terraform

I defined the AWS infrastructure in `main.tf`.

### 8.1 Create a VPC

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-Provisioner-VPC"
  }
}
```

This creates a VPC with the CIDR range `10.0.0.0/16`.

Documentation: [AWS VPC Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

### 8.2 Create a Public Subnet

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform-Public-Subnet"
  }
}
```

This creates a public subnet inside the VPC.

Documentation: [AWS Subnet Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

### 8.3 Create an Internet Gateway

```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Terraform-IGW"
  }
}
```

The Internet Gateway allows resources in the VPC to communicate with the internet when the routing and public IP configuration are also in place.

Documentation: [AWS Internet Gateway Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

### 8.4 Create a Route Table

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Terraform-Public-RT"
  }
}
```

The route sends traffic destined for any IPv4 address to the Internet Gateway.

Documentation: [AWS Route Table Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)

### 8.5 Associate the Route Table with the Subnet

```hcl
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```

This associates the public route table with the public subnet.

Documentation: [AWS Route Table Association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

### 8.6 Create a Security Group

```hcl
resource "aws_security_group" "web_sg" {
  name        = "terraform-provisioner-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Provisioner-SG"
  }
}
```

I allowed:

- Port 22 for SSH connections.
- Port 80 for HTTP traffic.
- All outbound traffic.

**Security note:** I used `0.0.0.0/0` for SSH during this lab. In a production environment, SSH access should be restricted to trusted IP addresses.

Documentation: [AWS Security Group Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

### 8.7 Register the SSH Public Key with AWS

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-provisioner-key"
  public_key = file("~/.ssh/terraform-provisioner-key.pub")
}
```

This registers my public key with AWS so that it can be associated with the EC2 instance.

Documentation: [AWS Key Pair Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

### 8.8 Create the EC2 Instance

```hcl
resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Provisioner-Server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/terraform-provisioner-key")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip python3-flask",
      "sudo nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 < /dev/null &"
    ]
  }
}
```

Here I configured the EC2 instance and explored the connection and provisioner blocks.

**Connection block:** Defines how Terraform connects to the EC2 instance using SSH.

**File provisioner:** Copies `app.py` from my Control Node to `/home/ubuntu/app.py` on the remote EC2 instance.

**Remote-exec provisioner:** Runs the package installation and application startup commands on the remote EC2 instance.

Documentation:
- [AWS EC2 Terraform Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Terraform Connection Block](https://developer.hashicorp.com/terraform/language/resources/provisioners/connection)
- [Terraform File Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/file)
- [Terraform Remote-exec Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec)

## 9. Initialize the Terraform Project

**Terminal:** Terraform Control Node

I initialized the Terraform working directory.

```bash
terraform init
```

This downloads the required provider plugins and initializes the working directory.

Documentation: [Terraform init](https://developer.hashicorp.com/terraform/cli/commands/init)

## 10. Validate and Review the Configuration

I checked whether my Terraform configuration was valid.

```bash
terraform validate
```

Then I reviewed the execution plan.

```bash
terraform plan
```

Documentation:
- [Terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)
- [Terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan)

## 11. Create the AWS Infrastructure

I applied the configuration to create the AWS resources.

```bash
terraform apply
```

I reviewed the plan and entered `yes` when Terraform asked for confirmation.

Terraform created the following eight AWS resources:

1. VPC
2. Public subnet
3. Internet Gateway
4. Route table
5. Route table association
6. Security group
7. AWS key pair
8. EC2 instance

The file and remote-exec provisioners were also executed as part of the EC2 creation process.

Documentation: [Terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply)

## 12. Verify the EC2 Instance

I checked the resources managed by Terraform.

```bash
terraform state list
```

I viewed the EC2 instance details to find its public IP address.

```bash
terraform state show aws_instance.web_server
```

The application EC2 instance created for this practical had:

| Detail | Value |
|---|---|
| Instance ID | `i-0b7243a819adb4e8f` |
| Instance type | `t2.micro` |
| Private IP | `10.0.1.242` |
| Public IP | `44.195.48.156` |
| Key pair | `terraform-provisioner-key` |

Documentation:
- [Terraform state list](https://developer.hashicorp.com/terraform/cli/commands/state/list)
- [Terraform state show](https://developer.hashicorp.com/terraform/cli/commands/state/show)

## 13. Connect to the Application EC2 Instance

**Terminal 1:** Terraform Control Node

I connected to the newly created EC2 instance using the private key.

```bash
ssh -i ~/.ssh/terraform-provisioner-key ubuntu@44.195.48.156
```

**Terminal 2:** Application EC2 Instance

After connecting, I verified that the application file had been copied.

```bash
ls -l /home/ubuntu/app.py
```

I checked the application file:

```bash
cat /home/ubuntu/app.py
```

Documentation: [OpenSSH ssh Manual](https://man.openbsd.org/ssh)

## 14. Start and Test the Flask Application

The file provisioner copied the application and the remote-exec provisioner installed the required packages.

However, the background startup command did not successfully start the Flask application automatically in this practical.

I started it manually on the application EC2 instance.

**Terminal 2:** Application EC2 Instance

```bash
sudo python3 /home/ubuntu/app.py
```

I kept the terminal running while testing the application.

I opened the following address in my browser:

```text
http://44.195.48.156
```

The browser displayed:

```text
Hello Terraform! Application deployed using Terraform Provisioners.
```

This confirmed that the Flask application was running and accessible through the public IP address.

## 15. Explore the Local-exec Provisioner

I also explored the Local-exec Provisioner.

Unlike Remote-exec, Local-exec runs commands on the machine where Terraform is executed.

I added the following separate resource to `main.tf`:

```hcl
resource "terraform_data" "local_exec_demo" {
  input = aws_instance.web_server.public_ip

  provisioner "local-exec" {
    command = "echo EC2 Instance Public IP: ${self.input}"
  }
}
```

I used a separate `terraform_data` resource so that I could demonstrate Local-exec without modifying or replacing the existing EC2 instance.

I applied the configuration:

```bash
terraform apply
```

Terraform executed the command on my Terraform Control Node and displayed:

```text
EC2 Instance Public IP: 44.195.48.156
```

The apply operation completed with:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Documentation:
- [Terraform Local-exec Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)
- [Terraform terraform_data Resource](https://developer.hashicorp.com/terraform/language/resources/terraform-data)

## 16. Final Terraform Resource Verification

I checked the Terraform state again.

```bash
terraform state list
```

The final state contained nine managed resources:

```text
aws_instance.web_server
aws_internet_gateway.igw
aws_key_pair.deployer
aws_route_table.public_rt
aws_route_table_association.public_association
aws_security_group.web_sg
aws_subnet.public_subnet
aws_vpc.my_vpc
terraform_data.local_exec_demo
```

## 17. GitHub Documentation

I kept the practical files organized inside my Terraform learning repository.

Repository: [My-Terraform-Journey](https://github.com/Yuvii2102/My-Terraform-Journey)

Folder: `07 - Terraform Provisioners Practicals`

The files included in the practical are:

```text
07 - Terraform Provisioners Practicals/
│
├── main.tf
├── provider.tf
├── variables.tf
├── app.py
├── .terraform.lock.hcl
├── .gitignore
└── Day-5-Terraform-Provisioners-Practical.md
```

I added the following entries to `.gitignore` to avoid committing Terraform working files and sensitive files:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.pem
```

I committed the configuration and documentation files to GitHub. I did not upload the private SSH key or Terraform state files.

## 18. Key Learnings

Through this practical, I learned:

- How to generate an SSH key pair and use it for EC2 authentication.
- How to create a VPC, subnet, Internet Gateway and route table using Terraform.
- How to configure security groups and EC2 instances.
- How to use Terraform connection blocks.
- How to transfer files using the File Provisioner.
- How to execute remote commands using the Remote-exec Provisioner.
- How to execute local commands using the Local-exec Provisioner.
- How to use `terraform_data` to run a provisioner separately from an infrastructure resource.
- How to verify resources using Terraform state commands.

## 19. Important Note About Provisioners

Terraform recommends using provisioners only when other alternatives are not suitable.

Provisioners can make infrastructure deployments harder to reproduce and troubleshoot. For production workloads, tools such as Ansible, cloud-init or pre-built machine images are often better choices for configuring instances.

Documentation: [HashiCorp - Provisioner Recommendations](https://developer.hashicorp.com/terraform/language/provisioners)

## 20. Cleanup

**Important:** The resources created by this practical may continue running and incur AWS charges.

Before destroying anything, I review the resources that Terraform plans to remove.

```bash
terraform plan -destroy
```

If I am sure that I want to remove the resources created by this project, I run:

```bash
terraform destroy
```

I review the plan and enter `yes` to confirm.

This removes the resources managed by this Terraform project. I should make sure I am in the correct project directory before running the command.

Documentation: [Terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)

---

## Official Documentation References

| Topic | Documentation |
|---|---|
| SSH key generation | [OpenSSH ssh-keygen](https://man.openbsd.org/ssh-keygen) |
| Terraform provisioners | [HashiCorp Provisioners](https://developer.hashicorp.com/terraform/language/provisioners) |
| Terraform AWS provider | [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) |
| AWS VPC | [AWS VPC Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| AWS EC2 | [AWS Instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| File provisioner | [File Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/file) |
| Remote-exec | [Remote-exec Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec) |
| Local-exec | [Local-exec Provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec) |
| Terraform state | [Terraform State Commands](https://developer.hashicorp.com/terraform/cli/commands/state) |
| Terraform cleanup | [Terraform Destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy) |

**End of Day 7 – Terraform Provisioners Practical**
