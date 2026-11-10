moved {
  from = aws_instance.my_server
  to   = module.ec2_instance.aws_instance.this
}

module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = "Terraform-Module-Server"
}
