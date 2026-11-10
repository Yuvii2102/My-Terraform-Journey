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
