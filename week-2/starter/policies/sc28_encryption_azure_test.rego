package compliance.sc28_azure

import rego.v1

# A compliant plan: a storage account plus the attestation output showing
# Microsoft-managed keys.
compliant_input := {"planned_values": {
	"root_module": {"resources": [{
		"address": "azurerm_storage_account.primary",
		"type": "azurerm_storage_account",
		"name": "primary",
		"values": {"customer_managed_key": []},
	}]},
	"outputs": {"encryption_key_source": {"value": "Microsoft.Storage"}},
}}

# A non-compliant plan: a storage account with no encryption attestation output.
broken_input := {"planned_values": {
	"root_module": {"resources": [{
		"address": "azurerm_storage_account.primary",
		"type": "azurerm_storage_account",
		"name": "primary",
		"values": {"customer_managed_key": []},
	}]},
	"outputs": {},
}}

test_attested_account_passes if {
	count(deny) == 0 with input as compliant_input
}

test_missing_attestation_denied if {
	count(deny) == 1 with input as broken_input
}
