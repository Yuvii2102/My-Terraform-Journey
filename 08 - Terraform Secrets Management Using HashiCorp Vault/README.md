# Day 8 – Terraform Secrets Management Using HashiCorp Vault

## 1. Introduction

In this topic, I learned about Secrets Management and how to integrate HashiCorp Vault with Terraform.

As a DevOps engineer, we work with sensitive information such as passwords, API tokens, access keys, SSH keys and certificates.

Instead of storing these values directly inside configuration files, we can use a Secrets Management tool to store and manage them securely.

## 2. What is Secrets Management?

Secrets Management is the process of securely storing, accessing and managing sensitive information.

Examples of secrets:

- Database usernames and passwords
- AWS Access Keys and Secret Access Keys
- API tokens
- SSH private keys
- TLS certificates
- Application credentials

**Why do we need Secrets Management?**

1. Prevents sensitive information from being exposed in source code.
2. Avoids accidentally pushing passwords and credentials to GitHub.
3. Provides controlled access to sensitive information.
4. Makes it easier to manage and update credentials.
5. Helps protect sensitive information across applications and infrastructure.

### Example

Instead of directly writing a password in Terraform:

```hcl
password = "MySecretPassword123"
```

We can store the password in HashiCorp Vault and retrieve it when Terraform needs it.

## 3. What is HashiCorp Vault?

HashiCorp Vault is a Secrets Management tool used to securely store, access and manage sensitive information.

It helps applications and infrastructure tools retrieve secrets without directly storing credentials in their configuration files.

**Example:**

- Store a database password in Vault.
- Configure Terraform to authenticate with Vault.
- Allow Terraform to access the required secret.
- Retrieve the secret and use it in the infrastructure configuration.

Official documentation: https://developer.hashicorp.com/vault/docs

## 4. What are Secret Engines?

Secret Engines are components inside Vault that store, generate or manage secrets.

Different secret engines are designed for different purposes.

| Secret Engine | Purpose |
|---|---|
| KV | Stores key-value secrets such as usernames and passwords |
| AWS | Manages AWS-related credentials |
| Database | Manages database credentials |
| PKI | Generates and manages certificates |
| SSH | Manages SSH-related credentials |

### KV Secret Engine

For our practical, we will use the KV (Key-Value) Secret Engine.

It stores information in key-value pairs.

Example:

```text
Secret Name: test_secret

username = admin
password = abishek
```

Here:

- `username` and `password` are keys.
- `admin` and `abishek` are their respective values.

Documentation: https://developer.hashicorp.com/vault/docs/secrets/kv

## 5. What is a Mount Path?

A mount path is the location where a secret engine is enabled in Vault.

Example:

```text
kv/
```

If we create a secret named `test_secret` inside this mount, its path becomes:

```text
kv/test_secret
```

Terraform uses this path to identify and retrieve the secret.

## 6. Authentication in HashiCorp Vault

Authentication verifies the identity of a user or application trying to access Vault.

Vault supports several authentication methods:

- Token Authentication
- Username and Password
- AppRole Authentication
- LDAP
- JWT
- OIDC

For our practical, we will use AppRole Authentication.

### What is AppRole Authentication?

AppRole is an authentication method mainly designed for applications and machines.

It allows tools such as Terraform and Ansible to authenticate with Vault.

AppRole uses two important credentials:

**1. Role ID**

- Identifies the AppRole.
- Used during the authentication process.

**2. Secret ID**

- Acts as a secret credential for the AppRole.
- Used along with the Role ID to authenticate.

Terraform uses these credentials to authenticate with Vault.

Documentation: https://developer.hashicorp.com/vault/docs/auth/approle

## 7. What are Policies in Vault?

Policies define what an authenticated user or application is allowed to access.

For example, we may have several secrets stored in Vault, but Terraform should only access a particular secret.

We can create a policy to grant the required permissions.

Example policy:

```hcl
path "kv/data/test_secret" {
  capabilities = ["read"]
}
```

This example grants read access to the specified secret path when using a KV Version 2 engine mounted at `kv`.

The policy can then be attached to an AppRole.

**Important:** Authentication verifies identity, while authorization checks permissions.

Documentation: https://developer.hashicorp.com/vault/docs/concepts/policies

## 8. Authentication vs Authorization

| Authentication | Authorization |
|---|---|
| Verifies identity | Checks permissions |
| Answers: Who are you? | Answers: What can you access? |
| Uses AppRole credentials | Uses policies |

**Example:**

1. Terraform connects to Vault using its Role ID and Secret ID.
2. Vault verifies the credentials. This is authentication.
3. Vault checks the attached policy. This is authorization.
4. If permission is granted, Terraform can read the secret.

## 9. What is the Vault Development Server?

Vault provides a development server for learning, testing and demonstrations.

For our practical, we will start Vault in development mode.

Important characteristics:

- Starts quickly.
- Uses an in-memory storage backend.
- Provides a development root token.
- Uses simplified configuration.
- Is not suitable for production workloads.

**Note:** For production environments, Vault requires proper storage, TLS configuration, access controls and operational security.

## 10. What is the Terraform Vault Provider?

Terraform uses providers to communicate with external platforms and services.

We have already used the AWS provider to manage AWS infrastructure.

Similarly, Terraform provides a Vault provider to communicate with HashiCorp Vault.

Example:

```hcl
provider "vault" {
  address = "http://VAULT_SERVER_IP:8200"
}
```

The Vault provider allows Terraform to read and manage supported Vault resources.

Official documentation: https://registry.terraform.io/providers/hashicorp/vault/latest/docs

## 11. Resource vs Data Source in Terraform

This is an important concept when integrating Terraform with Vault.

| Resource | Data Source |
|---|---|
| Creates or manages objects | Reads existing information |
| Uses the `resource` keyword | Uses the `data` keyword |
| Example: Create an EC2 instance | Example: Read a secret from Vault |

### Resource Example

```hcl
resource "aws_instance" "example" {
  ami           = "ami-example"
  instance_type = "t2.micro"
}
```

This tells Terraform to manage an EC2 instance.

### Data Source Example

```hcl
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test_secret"
}
```

This tells Terraform to read an existing secret from Vault.

Documentation: https://developer.hashicorp.com/terraform/language/data-sources

## 12. How Terraform Integrates with Vault

The integration follows this workflow:

1. Store sensitive information in HashiCorp Vault.
2. Enable AppRole authentication.
3. Create a policy that grants the required access.
4. Attach the policy to an AppRole.
5. Generate the Role ID and Secret ID.
6. Configure the Terraform Vault provider.
7. Authenticate Terraform with Vault.
8. Retrieve the secret using a Terraform data source.
9. Use the retrieved value in the Terraform configuration.

### Integration Flow

```text
          HashiCorp Vault
                 |
                 |
          Stores Secrets
                 |
                 |
        AppRole Authentication
                 |
                 |
           Role ID + Secret ID
                 |
                 |
          Terraform Provider
                 |
                 |
          Data Source
                 |
                 |
          Retrieve Secret
                 |
                 |
           AWS Resources
```

### Example Scenario

Suppose I store the following information in Vault:

```text
username = admin
password = abishek
```

Terraform authenticates with Vault, retrieves the secret and uses the retrieved value as a tag on an AWS EC2 instance.

This demonstrates how Terraform can retrieve sensitive information from an external Secrets Management tool.

**Important security note:** Terraform state may contain retrieved secret values, even when those values are marked as sensitive. Sensitive values should not be exposed in logs or committed to GitHub. Access to Terraform state must be properly protected.

## 13. Important Concepts to Remember

| Concept | Explanation |
|---|---|
| Secrets Management | Securely storing and managing sensitive information |
| HashiCorp Vault | A tool used for Secrets Management |
| Secret Engine | Stores, generates or manages secrets |
| KV Engine | Stores key-value secrets |
| Mount Path | Location where a secret engine is enabled |
| AppRole | Authentication method for applications and machines |
| Role ID | Identifies an AppRole |
| Secret ID | Credential used for AppRole authentication |
| Policy | Defines access permissions |
| Authentication | Verifies identity |
| Authorization | Checks permissions |
| Vault Provider | Connects Terraform with Vault |
| Data Source | Reads existing information |
| Development Server | Simplified Vault server for learning |

## 14. Official Documentation

I referred to the following official documentation to understand these concepts:

1. [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs)
2. [KV Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/kv)
3. [AppRole Authentication](https://developer.hashicorp.com/vault/docs/auth/approle)
4. [Vault Policies](https://developer.hashicorp.com/vault/docs/concepts/policies)
5. [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
6. [Terraform Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)

## 15. What I Will Implement in the Practical

After understanding the theory, I will perform the following practical:

1. Install HashiCorp Vault on an Ubuntu EC2 instance.
2. Start the Vault development server.
3. Enable the KV secret engine.
4. Create a secret containing a username and password.
5. Enable AppRole authentication.
6. Create a Vault policy.
7. Attach the policy to an AppRole.
8. Generate the Role ID and Secret ID.
9. Configure the Terraform Vault provider.
10. Retrieve the secret using a Terraform data source.
11. Create an AWS EC2 instance using the retrieved value as a tag.

---

**Conclusion**

Through this topic, I learned why Secrets Management is important in DevOps, how HashiCorp Vault manages sensitive information, and how Terraform can authenticate with Vault and retrieve secrets using a data source.

The main idea is to avoid hardcoding sensitive information in Terraform configuration files and manage access to secrets through a dedicated Secrets Management solution.
