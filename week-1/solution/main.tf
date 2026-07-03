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

  # CM-6: one shared tag map referenced by every resource, so a new resource
  # can't be created without the four required tags.
  tags = {
    Project         = var.project_name
    Environment     = var.environment
    ManagedBy       = "terraform"
    ComplianceScope = "nist-800-53"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "primary" {
  name                            = local.primary_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  blob_properties {
    versioning_enabled = true
  }
  tags = local.tags
}


resource "azurerm_storage_account" "log" {
  name                            = local.log_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  blob_properties {
    versioning_enabled = true
  }
  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "grc" {
  name               = "grc-logs"
  target_resource_id = "${azurerm_storage_account.primary.id}/blobServices/default"
  storage_account_id = azurerm_storage_account.log.id
  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
}
