#!/usr/bin/env bash
# Week 1 verification. Run after `terraform apply`.
# Confirms all five controls: SC-28 (encryption), CM-6 (versioning + tags),
# AC-3 (public access blocked on both accounts), AU-3 (access logging).
set -euo pipefail

ACCOUNT=$(terraform output -raw storage_account_name)
ACCOUNT_ID=$(terraform output -raw storage_account_id)
LOG_ACCOUNT=$(terraform output -raw log_storage_account_name)
RG=$(terraform output -raw resource_group_name)
echo "Verifying storage account: $ACCOUNT"
echo

echo "SC-28 encryption at rest:"
az storage account show --name "$ACCOUNT" --resource-group "$RG" \
  --query "{keySource: encryption.keySource, blobEncrypted: encryption.services.blob.enabled}" -o json
echo

echo "CM-6 blob versioning:"
az storage account blob-service-properties show --account-name "$ACCOUNT" --resource-group "$RG" \
  --query "{versioningEnabled: isVersioningEnabled}" -o json
echo

echo "AC-3 public access on the primary account (must be false):"
az storage account show --name "$ACCOUNT" --resource-group "$RG" \
  --query "{allowBlobPublicAccess: allowBlobPublicAccess}" -o json
echo

echo "AC-3 public access on the log account (must be false):"
az storage account show --name "$LOG_ACCOUNT" --resource-group "$RG" \
  --query "{allowBlobPublicAccess: allowBlobPublicAccess}" -o json
echo

echo "CM-6 tags (all four keys must be present on every resource):"
az group show --name "$RG" --query tags -o json
az storage account show --name "$ACCOUNT" --resource-group "$RG" --query tags -o json
az storage account show --name "$LOG_ACCOUNT" --resource-group "$RG" --query tags -o json
echo

echo "AU-3 access logging (diagnostic setting on the primary blob service):"
az monitor diagnostic-settings list --resource "$ACCOUNT_ID/blobServices/default" \
  --query "[].{name: name, categories: logs[?enabled].category, destination: storageAccountId}" -o json
echo

echo "Compliant when: keySource shows Microsoft.Storage with blob encryption true,"
echo "versioning shows true, allowBlobPublicAccess is false on BOTH accounts, all"
echo "three resources carry Project/Environment/ManagedBy/ComplianceScope, and the"
echo "diagnostic setting lists StorageRead, StorageWrite, and StorageDelete with"
echo "the log account as its destination."
