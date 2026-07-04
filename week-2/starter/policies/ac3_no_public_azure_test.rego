package compliance.ac3_azure

import rego.v1

# Compliant: both accounts explicitly block anonymous public access.
compliant_input := {"planned_values": {"root_module": {"resources": [
	{
		"address": "azurerm_storage_account.primary",
		"type": "azurerm_storage_account",
		"values": {"allow_nested_items_to_be_public": false},
	},
	{
		"address": "azurerm_storage_account.log",
		"type": "azurerm_storage_account",
		"values": {"allow_nested_items_to_be_public": false},
	},
]}}}

# Non-compliant: one account allows public access.
broken_input := {"planned_values": {"root_module": {"resources": [
	{
		"address": "azurerm_storage_account.primary",
		"type": "azurerm_storage_account",
		"values": {"allow_nested_items_to_be_public": false},
	},
	{
		"address": "azurerm_storage_account.log",
		"type": "azurerm_storage_account",
		"values": {"allow_nested_items_to_be_public": true},
	},
]}}}

test_blocked_accounts_pass if {
	count(deny) == 0 with input as compliant_input
}

test_public_account_denied if {
	count(deny) == 1 with input as broken_input
}
