# METADATA
# title: AC-3 - Access Enforcement (Azure Storage public access)
# description: Every azurerm_storage_account must block anonymous public access.
# custom:
#   control_id: AC-3
#   framework: nist-800-53
#   severity: critical
#   remediation: Set allow_nested_items_to_be_public = false on the storage account.
package compliance.ac3_azure

import rego.v1

# YOUR BUILD: deny any azurerm_storage_account whose
# allow_nested_items_to_be_public is not false. Anything other than an
# explicit false (true, or the value missing entirely) gets denied; a control
# you cannot see in the plan is a control you cannot prove.
#
# Where to look: input.planned_values.root_module.resources[] where
# .type == "azurerm_storage_account"; the flag is in .values. Use .address in
# your message so the denial names the exact resource. The test file shows the
# exact input shape.
#
# The stub below keeps `deny` defined so the tests load. Replace it.
deny contains msg if {
	false
	msg := "todo"
}
