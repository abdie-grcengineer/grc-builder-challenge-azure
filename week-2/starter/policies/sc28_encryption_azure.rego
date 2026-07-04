# METADATA
# title: SC-28 - Encryption at Rest (Azure Storage)
# description: Plans containing storage accounts must attest the encryption key source.
# custom:
#   control_id: SC-28
#   framework: nist-800-53
#   severity: high
#   remediation: Add the encryption_key_source output attesting Microsoft.Storage managed keys.
package compliance.sc28_azure

import rego.v1

# YOUR BUILD: Azure encrypts every storage account at rest and will not let
# you turn it off, so the policy checks the attestation, not the toggle.
# Deny when the plan contains at least one azurerm_storage_account but the
# encryption_key_source output is missing, or is present with any value other
# than "Microsoft.Storage".
#
# Where to look: storage accounts are in
# input.planned_values.root_module.resources[] (type == "azurerm_storage_account").
# Outputs are in input.planned_values.outputs, keyed by name, with the value
# under .value. The test file shows the exact input shape.
#
# Make the two tests in sc28_encryption_azure_test.rego pass. The stub below
# keeps `deny` defined so the tests load. Replace it.
deny contains msg if {
	false
	msg := "todo"
}
