provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test_secret"
}

output "vault_username" {
  value     = data.vault_kv_secret_v2.example.data["username"]
  sensitive = true
}

resource "aws_instance" "vault_demo" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name     = "Terraform-Vault-Demo"
    Username = data.vault_kv_secret_v2.example.data["username"]
  }
}
