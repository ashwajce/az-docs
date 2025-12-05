# Azure Key Vault Landing Zone Documentation

## 1. Overview

Azure Key Vault is a cloud service for securely storing and accessing secrets, keys, and certificates. In an enterprise landing zone, Key Vault is a central component for application secrets management, encryption key management, and certificate lifecycle management.

This document describes recommended patterns plus **Terraform examples** for deploying and consuming Azure Key Vault in a standardized way.

---

## 2. Design Principles

- Centralized secrets and key management
- Private-by-default access (Private Endpoints)
- Identity-based access with Managed Identities and RBAC
- Separation of duties between platform and application teams
- Full auditability (logging to Log Analytics / Event Hub)
- Automated provisioning using Terraform

---

## 3. Core Concepts

- **Secrets** – connection strings, API keys, passwords
- **Keys** – encryption keys for data-at-rest (e.g., disk, database, app-level crypto)
- **Certificates** – TLS/SSL certs (optionally with auto-renewal)
- **Access Control** – Azure RBAC or Vault Access Policies (prefer RBAC for new designs)
- **Network Security** – private endpoints + firewall rules

---

## 4. Recommended Architecture

### 4.1 Logical Structure

- **Per environment** Key Vaults (e.g., `dev`, `test`, `prod`)
- Optionally **per application** or **per business domain**, depending on isolation and blast radius requirements
- Integration with:
  - AKS (via Workload Identity or managed identities)
  - App Services / Functions
  - Virtual Machines / Scale Sets
  - Data services (e.g., SQL MI, Synapse, etc.)

### 4.2 Access Model

- Prefer **Azure RBAC** over legacy access policies
- Use **Managed Identities** for applications
- Use **Privileged Identity Management (PIM)** for admin roles
- Restrict secret operations to a small group of platform/security admins

---

## 5. Networking & Security

- Enable **Private Endpoint** for Key Vault in a dedicated subnet
- Configure **Firewall** to block public network access or restrict to specific trusted ranges
- Enforce **Soft Delete** and **Purge Protection**
- Send **logs and metrics** to:
  - Log Analytics Workspace
  - (Optional) Event Hub / Storage for long-term archiving

---

## 6. Terraform – Base Infrastructure

### 6.1 Resource Group

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-sec-kv-prod"
  location = "westeurope"
}
```

### 6.2 Virtual Network & Subnet for Private Endpoint (optional but recommended)

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-hub-prod"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet_kv_pe" {
  name                 = "snet-kv-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.10.0/24"]

  enforce_private_link_endpoint_network_policies = true
}
```

---

## 7. Terraform – Key Vault with RBAC

### 7.1 Key Vault (RBAC enabled, private access)

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-prod-core-001"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

### 7.2 Private Endpoint for Key Vault

```hcl
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-kv-prod-core-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_kv_pe.id

  private_service_connection {
    name                           = "psc-kv-prod-core-001"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}
```

> NOTE: You may also want to create a **Private DNS Zone**: `privatelink.vaultcore.azure.net` and link it to the VNet.

```hcl
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "kv-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "kv_record" {
  name                = azurerm_key_vault.kv.name
  zone_name           = azurerm_private_dns_zone.kv.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  records = [azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address]
}
```

---

## 8. Terraform – Secrets, Keys, and Certificates

### 8.1 Secret Example

```hcl
resource "azurerm_key_vault_secret" "db_conn" {
  name         = "db-connection-string"
  value        = "Server=tcp:myserver.database.windows.net,1433;Database=mydb;User Id=dbuser;Password=SuperSecret123!;"
  key_vault_id = azurerm_key_vault.kv.id

  content_type = "text/plain"

  lifecycle {
    ignore_changes = [value] # If rotated manually
  }
}
```

### 8.2 Key Example

```hcl
resource "azurerm_key_vault_key" "app_key" {
  name         = "app-encryption-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "encrypt",
    "decrypt",
    "wrapKey",
    "unwrapKey",
  ]
}
```

### 8.3 Certificate Example (Self-Signed)

```hcl
resource "azurerm_key_vault_certificate" "tls_cert" {
  name         = "app-tls-cert"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_actions {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject            = "CN=app.example.internal"
      validity_in_months = 12
      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]
    }
  }
}
```

---

## 9. Terraform – RBAC Assignments for Managed Identities

### 9.1 Example: Grant an App’s Managed Identity access to Key Vault Secrets

Assume you already have a **User-Assigned Managed Identity** for an application:

```hcl
resource "azurerm_user_assigned_identity" "app_mi" {
  name                = "uami-app-backend-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

Create a role assignment with built-in role `Key Vault Secrets User`:

```hcl
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_mi.principal_id
}
```

> The application can now use this managed identity to fetch secrets from the vault.

---

## 10. Integration Patterns

### 10.1 App Service / Function Apps

- Enable **System-Assigned Managed Identity**
- Grant `Key Vault Secrets User` role on Key Vault
- Reference secrets via Key Vault references in app settings, e.g.:  
  `@Microsoft.KeyVault(SecretUri=https://kv-prod-core-001.vault.azure.net/secrets/db-connection-string/)`

### 10.2 AKS (Workload Identity / Managed Identity)

- Use **Azure AD Workload Identity** or **Managed Identity** for pods
- Grant appropriate roles on Key Vault to the workload identity
- Use CSI Secrets Store driver or SDK to consume secrets

---

## 11. Logging & Monitoring

- Enable diagnostic settings on Key Vault:
  - Send **AuditEvent** logs to Log Analytics
- Monitor:
  - Secret/Key/Certificate access patterns
  - Failed authentication attempts
  - Changes to access control and configuration

Terraform example (Log Analytics already exists):

```hcl
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "diag-kv-prod-core-001"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}
```

---

## 12. Governance & Standards

- Define **naming convention** for vaults:
  - `kv-<env>-<domain>-<seq>` (e.g., `kv-prod-core-001`)
- Enforce via **Azure Policy**:
  - Private endpoints required for Key Vault
  - Soft delete and purge protection enabled
  - Public network access disabled
- Use scripts or Terraform modules to standardize vault creation

---

## 13. References

- Azure Key Vault documentation: https://learn.microsoft.com/azure/key-vault/
- Key Vault security overview: https://learn.microsoft.com/azure/key-vault/general/security-features
- Terraform Key Vault provider docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
