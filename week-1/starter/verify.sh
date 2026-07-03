#!/usr/bin/env bash
# Week 1 verification. Run after `terraform apply`.
# Confirms SC-28 (encryption), CM-6 (versioning), AC-3 (public access blocked).
set -euo pipefail

ACCOUNT=$(terraform output -raw storage_account_name)
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

echo "AC-3 public access (must be false):"
az storage account show --name "$ACCOUNT" --resource-group "$RG" \
  --query "{allowBlobPublicAccess: allowBlobPublicAccess}" -o json
echo

echo "If keySource shows Microsoft.Storage with blob encryption true, versioning"
echo "shows true, and allowBlobPublicAccess is false, the account is compliant."
