# Week 1 solution: One Storage Account, Five Controls

This Terraform module enforces SC-28, AC-3, CM-6, and AU-3 on a cloud storage account and emits the proof as JSON. A primary Azure storage account holds data, a second account receives its access logs, and every control is expressed as configuration: default encryption at rest attested through an output (SC-28), anonymous public access blocked on both accounts (AC-3), blob versioning plus four required tags on every resource (CM-6), and a diagnostic setting that ships StorageRead, StorageWrite, and StorageDelete from the primary blob service to the log account (AU-3 and AU-6).

## What's here

- `main.tf`: the full implementation, all five controls
- `variables.tf`, `outputs.tf`: inputs and outputs, including the SC-28 encryption attestation output
- `evidence/plan.json`: machine-readable proof, generated with `terraform show -json`
- `verify.sh`: audits all five controls against live Azure after an apply

## Run it

```bash
az login
export ARM_SUBSCRIPTION_ID=<your subscription id>
terraform init
terraform plan -var project_name=<3-8 lowercase chars> -var environment=dev
```

The provider deliberately has no hardcoded subscription. Point `ARM_SUBSCRIPTION_ID` at the subscription you intend, and check it twice; I deployed to the wrong one before pinning my local copy.

## Verify it

Plan-only: regenerate the evidence and inspect it.

```bash
terraform plan -out=tfplan
terraform show -json tfplan > evidence/plan.json
```

`evidence/plan.json` shows `allow_nested_items_to_be_public` false on both accounts, `versioning_enabled` true, the four tags (Project, Environment, ManagedBy, ComplianceScope) on all three resources, the diagnostic setting with its three log categories, and the `encryption_key_source` output attesting `Microsoft.Storage` managed keys.

Applied: `./verify.sh` runs the same five checks against the live resources with the az CLI.
