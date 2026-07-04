package compliance.cm6_azure

import rego.v1

# Compliant: all four required tags present.
compliant_input := {"planned_values": {"root_module": {"resources": [{
	"address": "azurerm_storage_account.primary",
	"type": "azurerm_storage_account",
	"values": {"tags": {
		"Project": "builder",
		"Environment": "dev",
		"ManagedBy": "terraform",
		"ComplianceScope": "nist-800-53",
	}},
}]}}}

# Non-compliant: only one tag present.
broken_input := {"planned_values": {"root_module": {"resources": [{
	"address": "azurerm_storage_account.primary",
	"type": "azurerm_storage_account",
	"values": {"tags": {"Project": "builder"}},
}]}}}

test_all_tags_present_passes if {
	count(deny) == 0 with input as compliant_input
}

test_missing_tags_denied if {
	count(deny) >= 1 with input as broken_input
}
