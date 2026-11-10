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

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
variable "server_names" {
  description = "List of server names"
  type        = list(string)
  default     = ["server1", "server2", "server3"]
}

variable "instance_types" {
  description = "Instance types for different environments"
  type        = map(string)

  default = {
    dev  = "t2.micro"
    test = "t3.micro"
    prod = "t3.small"
  }
}
