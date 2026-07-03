# Week 1: One Storage Account, Five Controls

The GRC Engineering Builder Challenge is six weekly builds, each one harder than the last, starting with a single cloud resource that satisfies real NIST 800-53 controls and ending with a full pipeline that generates its own compliance evidence. Every week ships a working artifact straight to your portfolio, so by the end you have six public proofs that you can turn a written control into running infrastructure.

Want in? Clone this repo, open the [starter/](starter/) folder, and build week 1 yourself. Everything you need is here: the brief below, the starter code, and a verify script that tells you when you've met all five controls. It costs under a cent in an Azure sandbox and takes under an hour.

You have spent enough time treating spreadsheets like controls. This week ends that. You are going to write Terraform for a single cloud storage account that satisfies five NIST 800-53 controls and produces machine-readable proof of every one. No screenshots, no narrative, just code you wrote and the evidence it generates.

This is brick one of the pipeline. Everything in the next five weeks reads, gates, signs, or maps what you build today. So build it yourself. Do not copy a module off the internet. The skill you are after is being able to look at a control and express it as infrastructure.

Starter code: the [starter/](starter/) folder next to this file. It gives you the project shape, a resource group, and two empty storage accounts so the project validates. The controls are yours to add. The starter is a runway, not the plane.

My completed build lives in [solution/](solution/), with the evidence committed alongside it. Do the work in the starter first; the solution is there to compare against, not to copy from.

## What you are building

One primary storage account holds data. A separate log storage account receives its access logs. Both enforce the same baseline. Here are the five controls and what each one means in practice. Your job is to find the right `azurerm` resources in the Terraform registry and wire them up.

**SC-28, protection of information at rest.** The primary account must encrypt objects at rest. The log account too. Azure encrypts every storage account with Microsoft-managed keys (AES-256) by default and will not let you turn it off, so your job is to surface that fact as machine-readable proof rather than to enable it.

**AC-3, access enforcement.** Anonymous public access must be blocked at the account level. Azure exposes this as one flag, `allow_nested_items_to_be_public`, and it must be false on both accounts so no container or blob can ever be opened to the internet.

**CM-6, configuration settings, part one.** Blob versioning on the primary account, so prior object states are recoverable and auditable.

**CM-6, configuration settings, part two.** Four required tags on every taggable resource: Project, Environment, ManagedBy, ComplianceScope. The `azurerm` provider has no `default_tags` block, so the clean way to do this is one `locals` tag map referenced in the `tags` argument of every resource, so you cannot forget them on a new one.

**AU-3 and AU-6, audit record content and review.** The primary account logs blob access to the dedicated log account. On Azure that is a diagnostic setting, and it attaches to the blob service inside the account, not to the account itself.

That last one is the only fiddly part. The diagnostic setting has to target the blob sub-resource, which means pointing it at `<storage account id>/blobServices/default` and enabling the StorageRead, StorageWrite, and StorageDelete log categories. Scope matters. If your diagnostic setting deploys but no logs ever arrive, that is why.

## Prerequisites

- An Azure subscription with permission to create resource groups and storage accounts. A sandbox subscription is easiest.
- Terraform 1.6 or newer. Check with `terraform version`.
- Azure CLI with a working login. Run `az login` and confirm the right subscription with `az account show`.
- 30 to 45 minutes.

## Cost

Under one cent if you destroy the same day. Empty storage accounts have no idle cost. You can also stay plan-only and never create anything.

The evidence you need comes from `terraform plan`. If you want the full experience, apply, verify, and then run the cleanup at the bottom.

## Build it

The starter has `main.tf`, `variables.tf`, and `outputs.tf` with the provider, a random suffix, the resource group, and the two storage accounts already declared. Open `main.tf` and work through the TODOs. For each control:

- Find the `azurerm` resource or argument that implements it. The Terraform registry page for the `azurerm` provider is your reference. Search the resource name, read the example, write your version.
- Wire it to the right account. Public access and versioning are arguments on the storage account itself. The diagnostic setting is its own resource that points at the primary account's blob service by id.
- For tags, define the four-tag map once in `locals` and reference it on the resource group and both accounts.
- For logging, add the diagnostic setting on the primary account's blob service, enable the three Storage log categories, and target the log account.

Then add the SC-28 attestation output: surface the encryption key source in effect as a Terraform output. That one value is your proof of encryption in machine-readable form.

## Run it and capture evidence

Open `evidence/plan.json` and find your storage account. You should see the encryption in effect (SC-28), `allow_nested_items_to_be_public` false on both accounts (AC-3), versioning enabled and the four tags (CM-6), and the diagnostic setting with its log categories (AU-3). That JSON is your evidence. Hold onto it. Week 2 reads it.

If you applied, also capture state and run the checks.

## Done when

- `terraform validate` passes.
- `evidence/plan.json` contains all five controls: the encryption attestation, public access blocked on both accounts, versioning enabled, the four tags, and the diagnostic setting target.
- If you applied, `verify.sh` shows encryption with Microsoft-managed keys, versioning enabled, public blob access false on both accounts, the four tags on every resource, and the diagnostic setting delivering the three Storage log categories.

`verify.sh` in the starter runs all five live checks for you. Notice that it audits both accounts and all three resources, not just the primary. A verification script only vouches for what it actually checks, and partial coverage passing is how gaps hide.

## Tear it down

`terraform destroy` removes the resource group and everything in it, blobs included. No need to empty anything first. Just make sure you are in the right subscription before you run it.

## Make it a portfolio piece

Add a new project to your portfolio this week. Keep it short and concrete:

- A one-paragraph writeup: "This Terraform module enforces SC-28, AC-3, CM-6, and AU-3 on a cloud storage account and emits the proof as JSON." Name the controls. Naming controls is the whole skill.
- Your `main.tf`, `variables.tf`, `outputs.tf` in a public repo.
- The `evidence/plan.json` committed alongside it.
- A README that says what it enforces and how to verify it.

Then post on LinkedIn. Tag GRC Engineering Club, use #GRCEngClubChallenge, and say one true thing about what was harder than you expected. That last part is what makes people stop scrolling.

## Common snags

- **StorageAccountAlreadyTaken.** Storage account names are globally unique. The `random_id` suffix prevents this. If you hardcoded a name, change it.
- **Invalid storage account name.** Names must be 3 to 24 characters, lowercase letters and numbers only. No hyphens, no underscores. If you copied a naming convention from another cloud, that is why it failed.
- **Diagnostic setting deploys but logs never arrive.** The setting must target the blob service (`.../blobServices/default`), not the storage account itself. Scope the target resource id to the sub-resource.
- **Terraform cannot authenticate.** Run `az login` first, and if you have more than one subscription, set the right one with `az account set` before any Terraform command.

That is brick one. Next week you write the policy that proves it, automatically, every time.
