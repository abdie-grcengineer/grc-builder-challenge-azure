# Week 1 starter: Your First Compliant Resource

This is scaffolding, not a solution. The provider, the resource group, and both storage accounts are wired up so the project validates out of the box. Your job is to add the five controls marked `# TODO` in `main.tf` and `outputs.tf`.

## Use it

```bash
az login                  # confirm the right subscription with `az account show`
terraform init
terraform validate        # passes as-is (skeleton), passes again once you finish
terraform plan -out=tfplan

mkdir -p evidence
terraform show -json tfplan > evidence/plan.json
```

## What to add

- SC-28: encryption at rest is on by default with Microsoft-managed keys; add the attestation output in `outputs.tf`
- CM-6: a `blob_properties` block with `versioning_enabled = true` on the primary account
- AC-3: `allow_nested_items_to_be_public = false` on both accounts, explicitly
- AU-3: `azurerm_monitor_diagnostic_setting` on the primary account's blob service (`<account id>/blobServices/default`) with StorageRead, StorageWrite, and StorageDelete, targeting the log account
- CM-6 tags: define the four-tag map in `locals` and reference it on the resource group and both accounts

## Done when

Run `./verify.sh` after `terraform apply`. It audits all five controls against live Azure: encryption key source, blob versioning, public access on both accounts, the four tags on all three resources, and the diagnostic setting with its log categories. A green run means what it says only because the coverage is complete; a check script that audits three of five controls will happily pass a half-built baseline.

If you stayed plan-only, confirm `evidence/plan.json` contains the same five things: the encryption attestation, public access blocked on both accounts, versioning enabled, the four tags, and the diagnostic setting.

## Files

- `main.tf`: provider, resource group, storage accounts, and the TODOs you complete
- `variables.tf`: input variables (complete)
- `outputs.tf`: outputs (the SC-28 attestation is yours to add)
- `verify.sh`: post-apply audit of all five controls
- `terraform.tfvars.example`: copy to `terraform.tfvars` and edit
