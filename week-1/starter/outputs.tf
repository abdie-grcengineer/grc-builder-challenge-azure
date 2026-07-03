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

# TODO (SC-28 attestation): add an output that surfaces the encryption key
# source in effect. The account uses Microsoft-managed keys (AES-256) unless a
# customer_managed_key block says otherwise, so derive it, for example:
#
#   length(azurerm_storage_account.primary.customer_managed_key) == 0
#     ? "Microsoft.Storage" : "Microsoft.Keyvault"
#
# This is your machine-readable proof of encryption at rest. `az storage
# account show --query encryption.keySource` confirms the same value live.
