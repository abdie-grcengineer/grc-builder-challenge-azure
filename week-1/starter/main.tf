terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  # Storage account names: 3-24 chars, lowercase letters and numbers only.
  primary_name = "${var.project_name}${var.environment}dat${random_id.suffix.hex}"
  log_name     = "${var.project_name}${var.environment}log${random_id.suffix.hex}"

  # TODO (CM-6): define one tag map here with Project, Environment, ManagedBy,
  # and ComplianceScope, then reference it in the tags argument of the resource
  # group and both storage accounts so you cannot forget them on a new resource.
}

# The resource group and two base accounts are here so the skeleton validates.
# The controls are yours.
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

resource "azurerm_storage_account" "primary" {
  name                     = local.primary_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "log" {
  name                     = local.log_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ---------------------------------------------------------------------------
# YOUR BUILD: add the controls. Each is an argument or resource you write.
#
#   SC-28  Azure encrypts both accounts at rest by default with
#          Microsoft-managed keys (AES-256) and will not let you turn it off.
#          Your job is the attestation output in outputs.tf.
#   CM-6   turn on blob versioning for the primary account.
#   AC-3   block anonymous public access on both accounts.
#          allow_nested_items_to_be_public must be false, explicitly.
#   AU-3   add a diagnostic setting on the primary account's blob service
#          (target "<account id>/blobServices/default") that sends
#          StorageRead, StorageWrite, and StorageDelete to the log account.
#
# Look up the azurerm resource names in the Terraform registry. The full
# brief in ../README.md explains what each control is and how to verify it.
# ---------------------------------------------------------------------------
