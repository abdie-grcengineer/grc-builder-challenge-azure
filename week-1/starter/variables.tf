variable "location" {
  type        = string
  description = "Azure region to deploy into."
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Short project identifier. Becomes part of storage account names and the Project tag. Lowercase letters and numbers only, because storage account names allow nothing else."
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,7}$", var.project_name))
    error_message = "project_name must be 3-8 lowercase letters or numbers, starting with a letter (storage account names are capped at 24 characters)."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment. Drives the Environment tag."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
