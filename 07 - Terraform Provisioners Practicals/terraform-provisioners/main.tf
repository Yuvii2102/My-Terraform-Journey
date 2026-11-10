# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-Provisioner-VPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform-Public-Subnet"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Terraform-IGW"
  }
}

# Create Route Table
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

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
# Create Security Group
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
# Create AWS Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-provisioner-key"
  public_key = file("~/.ssh/terraform-provisioner-key.pub")
}
# Create EC2 Instance
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

  # SSH Connection
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/terraform-provisioner-key")
    host        = self.public_ip
  }

  # File Provisioner
  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  # Remote-exec Provisioner
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip python3-flask",
      "sudo nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 < /dev/null &"
    ]
  }
}
# --------------------------------------------------
# Local-exec Demonstration
# --------------------------------------------------

resource "terraform_data" "local_exec_demo" {
  input = aws_instance.web_server.public_ip

  provisioner "local-exec" {
    command = "echo EC2 Instance Public IP: ${self.input}"
  }
}
