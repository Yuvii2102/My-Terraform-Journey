terraform {
  backend "s3" {
    bucket       = "yuvraj-terraform-remote-state-2026"
    key          = "terraform/day4/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
