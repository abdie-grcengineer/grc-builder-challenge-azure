# Week 2: Make the Rules Executable

Last week you expressed five controls as Terraform and produced machine-readable evidence. This week you write the policy that proves it, automatically, every time. Three policies in Rego, run with OPA and Conftest, each reading the same `plan.json` your Terraform already emits: SC-28 checks the encryption attestation, AC-3 checks that anonymous public access is blocked, CM-6 checks the four required tags. A compliant plan passes clean. A broken plan gets denied with a message that names the resource and the fix.

This is the enforcement layer. Week 1's controls live in code, but nothing yet stops someone from deleting the versioning block and applying anyway. After this week, a machine catches that before it ships, which is the difference between infrastructure as code and compliance as code with teeth.

Starter code: the [starter/](starter/) folder next to this file. Three policy stubs with their metadata headers, and three complete test files that define what done means. The tests are the spec. Do not edit them. Make them pass.

## What you are building

**SC-28, protection of information at rest.** Azure encrypts every storage account with AES-256 and will not let you turn it off, so the policy verifies the attestation instead of the toggle: deny any plan that contains storage accounts without the `encryption_key_source` output attesting `Microsoft.Storage` managed keys.

**AC-3, access enforcement.** Deny any storage account whose `allow_nested_items_to_be_public` is anything other than an explicit false. Missing counts as failing; a control you cannot see in the plan is a control you cannot prove.

**CM-6, configuration settings.** Deny any taggable resource (resource groups and storage accounts) missing one or more of Project, Environment, ManagedBy, and ComplianceScope. The `azurerm` provider has no `default_tags`, so there is no `tags_all` to lean on; the merged truth is just `values.tags`.

## Prerequisites

- OPA and Conftest. `brew install opa conftest` on macOS.
- Your week 1 build and its `plan.json`. The policies read the evidence you already produce.
- 45 to 60 minutes.

## Cost

Zero. Policies run locally against JSON. Nothing touches Azure this week.

## Build it

Open each policy file in `starter/policies/` and replace the stub `deny` rule. For each control: read the test file first, it shows the exact input shape your rule receives, then write the rule that makes both tests pass. Work one policy at a time and rerun the tests after every change:

```bash
opa test policies/ -v
```

You start at 3 passing, 3 failing. You are done at 6.

## Gate your real plan

Point Conftest at your actual week 1 plan:

```bash
conftest test --policy policies --namespace compliance.sc28_azure plan.json
conftest test --policy policies --namespace compliance.ac3_azure  plan.json
conftest test --policy policies --namespace compliance.cm6_azure  plan.json
```

All three pass against your compliant week 1 baseline. Then prove the gate has teeth: break a copy of week 1 (flip `allow_nested_items_to_be_public` to true, or delete the attestation output), regenerate `plan.json`, and watch the matching policy deny it by name.

## Done when

- `opa test policies/ -v` shows 6 of 6 passing.
- All three Conftest namespaces pass against your compliant week 1 plan.
- At least one deliberately broken plan gets denied with a message naming the resource and the fix.

## Make it a portfolio piece

Commit the policies next to your week 1 module with a README line like: "These OPA policies enforce SC-28, AC-3, and CM-6 against any Terraform plan for this stack, and they fail the build when a control is removed." Include the broken-plan denial output, an executable policy catching a real misconfiguration is a better artifact than any screenshot. Then post about it: what you broke, what caught it, and one true thing about learning Rego.

## Common snags

- **`rego_parse_error` on the `if` keyword.** The policies use `import rego.v1` syntax. Update OPA if yours is old: `brew upgrade opa`.
- **Tests pass but Conftest shows 0 tests run.** The namespace flag must match the package name exactly, `compliance.sc28_azure`, not `sc28_azure`.
- **Your deny fires on the compliant plan's resource group.** Check your type filter. Diagnostic settings are not taggable; resource groups and storage accounts are.
- **Stale plan.json.** The plan file is a snapshot. If you changed the Terraform, regenerate it or you are gating last week's truth.

That is brick two. The rules are executable now; the next bricks put them in the way of every change.
