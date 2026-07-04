# METADATA
# title: CM-6 - Configuration Settings (Azure required tags)
# description: Taggable resources must carry the four required compliance tags.
# custom:
#   control_id: CM-6
#   framework: nist-800-53
#   severity: medium
#   remediation: Reference the shared locals tag map in the resource's tags argument.
package compliance.cm6_azure

import rego.v1

required := {"Project", "Environment", "ManagedBy", "ComplianceScope"}

taggable := {"azurerm_resource_group", "azurerm_storage_account"}

# YOUR BUILD: deny any taggable resource that is missing one or more required
# tags. Azure has no tags_all equivalent (the azurerm provider has no
# default_tags), so the full tag set is simply values.tags, and a resource
# with no tags argument at all has no tags key, which must also be denied.
#
# Where to look: input.planned_values.root_module.resources[] where .type is
# in the taggable set. Name the resource and the missing keys in your message.
# The test file shows the exact input shape.
#
# The stub keeps `deny` defined (empty) so the test file loads. Replace it.
deny contains msg if {
	false
	msg := "todo"
}
