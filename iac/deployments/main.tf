provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "kv_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "keyvault"
  }
}

resource "azurerm_key_vault" "main" {
  name                            = var.key_vault_name
  location                        = azurerm_resource_group.kv_rg.location
  resource_group_name             = azurerm_resource_group.kv_rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.sku_name
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  
  # Optional: Network ACLs can be added here if needed
  # network_acls {
  #   default_action             = "Deny"
  #   bypass                     = "AzureServices"
  #   ip_rules                   = []
  #   virtual_network_subnet_ids = []
  # }

  # Optional: Access Policies can be added here if needed
  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = "<Azure AD Object ID of User/Service Principal>"
  #   key_permissions = [
  #     "get", "list", "create", "delete", "recover", "backup", "restore"
  #   ]
  #   secret_permissions = [
  #     "get", "list", "set", "delete", "recover", "backup", "restore"
  #   ]
  #   certificate_permissions = [
  #     "get", "list", "create", "import", "delete", "recover", "backup", "restore"
  #   ]
  # }

  tags = {
    environment = var.environment
    project     = "keyvault"
  }
}