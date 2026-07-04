# Week 2 starter: Make the Rules Executable

You write the policies. This starter gives you the structure and the tests that define "done." Nothing here is the solution.

## What you get

- Three policy files, each with the required metadata header and an empty `deny` stub: SC-28 (encryption attestation), AC-3 (public access), CM-6 (required tags).
- Three test files. These are your spec. Do not edit them. Make them pass.

## Run the tests

```bash
opa test policies/ -v
```

Out of the box: **3 passing, 3 failing**. The passing ones confirm a compliant plan produces no denial. The failing ones are your work, each one says a non-compliant plan should be denied and right now your stub denies nothing.

Implement the three `deny` rules until it is **6 passing**.

## Then run it against your real week 1 plan

```bash
# in your week 1 terraform dir
terraform plan -out=tfplan
terraform show -json tfplan > plan.json

# back here
conftest test --policy policies --namespace compliance.sc28_azure plan.json
conftest test --policy policies --namespace compliance.ac3_azure  plan.json
conftest test --policy policies --namespace compliance.cm6_azure  plan.json
```

All three should pass against your compliant week 1 plan. Then break a copy of week 1 (delete the `encryption_key_source` output, or flip `allow_nested_items_to_be_public` to true), regenerate the plan, and watch the matching policy fail with a message that names the resource and the fix.

## The one technique you need

Everything you need lives in two places inside the plan JSON. Resource settings are in `input.planned_values.root_module.resources[]`, each entry carrying a stable `.address` (like `azurerm_storage_account.primary`, the random name suffix never appears in addresses) plus its planned `.values`. Outputs are in `input.planned_values.outputs`, keyed by name, with the value under `.value`. Match resources by `.type` and `.address`, never by the generated name. The test files show you the exact input shape.

## Files

- `policies/sc28_encryption_azure.rego`: your build
- `policies/ac3_no_public_azure.rego`: your build
- `policies/cm6_required_tags_azure.rego`: your build
- `policies/*_test.rego`: the spec, complete, do not edit
