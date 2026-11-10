variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0d97d7f07b25dd693"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
