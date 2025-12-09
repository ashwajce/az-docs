output "key_vault_id" {
  description = "The ID of the Azure Key Vault."
  value       = azurerm_key_vault.akv.id
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault."
  value       = azurerm_key_vault.akv.vault_uri
}

output "private_endpoint_ip_address" {
  description = "The IP address of the Key Vault's Private Endpoint."
  value       = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}
