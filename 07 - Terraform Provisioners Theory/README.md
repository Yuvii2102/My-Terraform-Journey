# Day 7 – Terraform Provisioners

## 1. Introduction to Terraform Provisioners

Terraform is an Infrastructure as Code (IaC) tool used to create and manage cloud infrastructure.

For example, using Terraform, I can create EC2 instances, VPCs, subnets, security groups and other AWS resources.

But sometimes creating infrastructure is not enough. We may also need to perform additional tasks after creating the resources.

For example:
- Installing Python or Java on an EC2 instance.
- Copying application files to an EC2 instance.
- Installing required packages.
- Executing shell commands on a remote machine.
- Performing additional actions during resource creation or destruction.

To perform these tasks, Terraform provides a concept called **Provisioners**.

## 2. What are Terraform Provisioners?

Terraform Provisioners allow us to execute commands or perform additional actions on local or remote machines during infrastructure operations.

Using provisioners, we can connect to an EC2 instance, copy files, install software and execute commands.

For example, when Terraform creates an EC2 instance, we can use provisioners to:

1. Connect to the EC2 instance using SSH.
2. Copy an application file from our local machine.
3. Install Python and Flask.
4. Execute the application on the EC2 instance.

This helps automate infrastructure creation along with additional configuration tasks.

## 3. Types of Terraform Provisioners

Terraform provides three commonly used provisioners:

1. File Provisioner
2. Remote-exec Provisioner
3. Local-exec Provisioner

### 3.1 File Provisioner

File Provisioner is used to copy files or directories from a local machine to a remote machine.

For example, if I have a Python application named `app.py` on my local machine and want to copy it to an EC2 instance, I can use File Provisioner.

**Example:**

```hcl
provisioner "file" {
  source      = "app.py"
  destination = "/home/ubuntu/app.py"
}
```

**Important attributes:**

- `source`: Location of the file on the local machine.
- `destination`: Location where the file should be copied on the remote machine.

**Real-world use cases:**

- Copying application files to EC2.
- Transferring configuration files.
- Copying YAML and JSON files.
- Transferring scripts and deployment files.

### 3.2 Remote-exec Provisioner

Remote-exec Provisioner is used to execute commands on a remote machine.

It connects to the remote machine using SSH and runs the specified commands.

For example, after creating an EC2 instance, I can use Remote-exec to install Python, install Flask and execute my application.

**Example:**

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt update -y",
    "sudo apt install python3 python3-pip -y",
    "pip3 install flask"
  ]
}
```

**Important attribute:**

- `inline`: Contains the commands that need to execute on the remote machine.

**Real-world use cases:**

- Installing Python, Java or Node.js.
- Installing application dependencies.
- Running shell scripts.
- Starting application services.
- Executing commands on an EC2 instance.

### 3.3 Local-exec Provisioner

Local-exec Provisioner executes commands on the same machine where Terraform is running.

Unlike Remote-exec, it does not connect to a remote EC2 instance.

For example, if I want to create a log file or print a message during Terraform execution, I can use Local-exec.

**Example:**

```hcl
provisioner "local-exec" {
  command = "echo Terraform execution completed"
}
```

Another example is creating a log file:

```hcl
provisioner "local-exec" {
  command = "echo EC2 instance created >> terraform.log"
}
```

**Real-world use cases:**

- Creating log files.
- Printing execution messages.
- Running local scripts.
- Triggering external commands.
- Recording infrastructure deployment progress.

## 4. Difference Between Provisioner Types

| Provisioner | Purpose | Where it executes |
|---|---|---|
| File | Copies files | Transfers files to remote machine |
| Remote-exec | Executes commands | Remote machine |
| Local-exec | Executes commands | Local machine |

**Example:**

If I want to deploy a Python application on EC2:

- File Provisioner copies `app.py` to EC2.
- Remote-exec installs Python and Flask and executes commands on EC2.
- Local-exec can create a deployment log on my local machine.

## 5. Connection Block

When using File Provisioner or Remote-exec to work with a remote machine, Terraform needs connection details.

For an Ubuntu EC2 instance, we generally use SSH authentication.

The connection block provides the information required to connect to the instance.

**Example:**

```hcl
connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
}
```

**Explanation:**

- `type`: Specifies the connection protocol. Here we use SSH.
- `user`: Specifies the remote machine's username.
- `private_key`: Specifies the private SSH key used for authentication.
- `host`: Specifies the IP address of the remote machine.

For Ubuntu EC2 instances, the default SSH username is generally `ubuntu`.

The private key must match the public key configured for the EC2 instance.

## 6. The Self Keyword in Terraform

The `self` keyword is used inside a provisioner or connection block to refer to the resource in which the block is defined.

For example:

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-example"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
}
```

Here, `self.public_ip` refers to the public IP address of the EC2 instance being created.

If I want to access a resource attribute outside its own resource block, I can use the resource reference.

For example:

```hcl
aws_instance.my_server.public_ip
```

**Remember:**

- Inside the resource's provisioner or connection block, use `self`.
- Outside the resource block, use the resource reference.

## 7. Creation-Time Provisioners

By default, provisioners are creation-time provisioners.

This means they execute during resource creation.

For example, when Terraform creates an EC2 instance:

1. Terraform creates the EC2 instance.
2. Terraform establishes the SSH connection.
3. File Provisioner copies the application file.
4. Remote-exec executes the required commands.

This helps automate additional tasks during infrastructure creation.

## 8. Destruction-Time Provisioners

Terraform also supports destruction-time provisioners.

These provisioners execute when Terraform destroys a resource.

We can configure a provisioner to run during destruction using:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo EC2 instance is being destroyed"
}
```

Here, the command executes during the destruction of the resource instead of its creation.

**Use cases:**

- Printing cleanup messages.
- Recording resource deletion information.
- Performing additional cleanup actions.

## 9. Real-World Scenario – Application Deployment on EC2

Let's understand how provisioners can help in a real DevOps task.

Imagine a development team has a Python Flask application named `app.py`.

Whenever developers update the application, they want the DevOps team to create the required infrastructure and deploy the application for testing.

If this process is performed manually, it takes time to create infrastructure, configure the network, connect to EC2 and deploy the application.

Using Terraform Provisioners, we can automate many of these steps.

**Deployment workflow:**

1. Create a VPC.
2. Create a public subnet.
3. Create an Internet Gateway.
4. Create a route table and associate it with the public subnet.
5. Create a security group.
6. Create an EC2 instance.
7. Establish an SSH connection.
8. Copy `app.py` using File Provisioner.
9. Install Python and Flask using Remote-exec.
10. Execute the application.

The developer can then access the application using the EC2 public IP address and the application port.

This reduces manual work and helps developers test their application faster.

## 10. Advantages of Terraform Provisioners

1. **Automation:** Helps automate additional tasks during infrastructure creation.
2. **File Transfer:** Allows us to copy application and configuration files to remote machines.
3. **Command Execution:** Allows us to execute commands on local and remote machines.
4. **Less Manual Work:** Reduces the need to manually connect to EC2 and perform basic tasks.
5. **Integration:** Can be used along with Terraform infrastructure resources.

## 11. Limitations of Terraform Provisioners

Provisioners are useful, but they also have some limitations.

1. **Connection Dependency:** Remote provisioners require a working connection to the remote machine.
2. **Failure Handling:** If a provisioner fails, Terraform may mark the resource as tainted, depending on the operation and configuration.
3. **Limited Configuration Management:** Provisioners are not designed to replace complete configuration management tools.
4. **Troubleshooting:** Debugging remote command failures can be difficult.
5. **Reusability:** Managing complex installation and deployment scripts through provisioners can become difficult.

**Important:** Terraform generally recommends using alternatives such as cloud-init, user data or configuration management tools when they are suitable. Provisioners should be used when other options are not practical.

## 12. Terraform Provisioners vs Ansible

| Terraform Provisioners | Ansible |
|---|---|
| Part of Terraform | Separate configuration management tool |
| Executes commands and transfers files | Automates configuration and application deployment |
| Can run during resource creation or destruction | Can manage existing infrastructure |
| Suitable for simple provisioning tasks | Suitable for complex configuration management |
| Limited configuration management features | Provides reusable playbooks and roles |

Terraform is mainly used to provision infrastructure, while Ansible is used to configure and manage systems.

Both tools can work together in a DevOps workflow.

## 13. Important Interview Questions

**1. What are Terraform Provisioners?**

Terraform Provisioners allow us to execute commands or perform additional actions on local or remote machines during infrastructure operations.

**2. What are the three types of Terraform Provisioners?**

- File Provisioner
- Remote-exec Provisioner
- Local-exec Provisioner

**3. What is the difference between Local-exec and Remote-exec?**

Local-exec runs commands on the machine where Terraform is executed, whereas Remote-exec runs commands on a remote machine.

**4. What is File Provisioner?**

File Provisioner is used to copy files or directories from a local machine to a remote machine.

**5. Why do we use the connection block?**

The connection block provides the details required for Terraform to connect to a remote machine, such as SSH username, private key and host IP.

**6. What is the purpose of the self keyword?**

The `self` keyword is used to refer to the resource in which the provisioner or connection block is defined.

**7. When do provisioners execute by default?**

Provisioners execute during resource creation by default.

**8. Can provisioners execute during resource destruction?**

Yes. We can configure a provisioner using `when = destroy` to execute during resource destruction.

**9. Why should we avoid using provisioners whenever possible?**

Provisioners can make infrastructure deployments harder to maintain and troubleshoot. Alternatives such as cloud-init and configuration management tools are often more suitable.

**10. Can Terraform and Ansible work together?**

Yes. Terraform can create infrastructure, and Ansible can configure the created servers and deploy applications.

## Conclusion

In this topic, I learned how Terraform Provisioners help perform additional tasks along with infrastructure creation.

I understood the differences between File, Remote-exec and Local-exec Provisioners and learned about SSH connections, the self keyword and creation-time and destruction-time provisioners.

I also understood how Terraform Provisioners can be used in real-world DevOps tasks such as deploying applications on EC2 instances.

In the next practical, I will use these concepts to automate application deployment on AWS using Terraform.
