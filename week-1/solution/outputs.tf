output "resource_group_name" {
  description = "Resource group holding everything."
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Primary storage account name."
  value       = azurerm_storage_account.primary.name
}

output "storage_account_id" {
  description = "Primary storage account resource id."
  value       = azurerm_storage_account.primary.id
}

output "log_storage_account_name" {
  description = "Log storage account name."
  value       = azurerm_storage_account.log.name
}

# SC-28 attestation: machine-readable proof of encryption at rest. Azure
# encrypts every storage account with AES-256 and Microsoft-managed keys
# unless a customer_managed_key block says otherwise, so the key source is
# derived from that block's absence. `az storage account show --query
# encryption.keySource` confirms the same value live.
output "encryption_key_source" {
  description = "Encryption key source in effect on the primary account (SC-28)."
  value       = length(azurerm_storage_account.primary.customer_managed_key) == 0 ? "Microsoft.Storage" : "Microsoft.Keyvault"
}
