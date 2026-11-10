locals {
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
}

resource "aws_instance" "my_server" {
  ami           = var.ami_id
  instance_type = local.instance_type

  tags = {
    Name        = "My-Terraform-Server"
    Environment = var.environment
  }
}
