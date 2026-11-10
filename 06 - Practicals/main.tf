resource "aws_instance" "state_demo" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-State-Demo"
  }
}
