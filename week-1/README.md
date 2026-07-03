# Week 1: One Bucket, Five Controls

You have spent enough time treating spreadsheets like controls. This week ends that. You are going to write Terraform for a single cloud storage bucket that satisfies five NIST 800-53 controls and produces machine-readable proof of every one. No screenshots, no narrative, just code you wrote and the evidence it generates.

This is brick one of the pipeline. Everything in the next five weeks reads, gates, signs, or maps what you build today. So build it yourself. Do not copy a module off the internet. The skill you are after is being able to look at a control and express it as infrastructure.

Starter code: download `week-1-starter.zip` attached to this post. It gives you the project shape and two empty buckets so the project validates. The controls are yours to add. The starter is a runway, not the plane.

## What you are building

One primary bucket holds data. A separate log bucket receives its access logs. Both enforce the same baseline. Here are the five controls and what each one means in practice. Your job is to find the right AWS resources in the Terraform registry and wire them up.

**SC-28, protection of information at rest.** The primary bucket must encrypt objects by default. The log bucket too. Server-side encryption with AES-256 is enough for this week.

**AC-3, access enforcement.** Public access must be blocked on all four vectors. AWS exposes four separate flags for this, and all four have to be true. Three is not enough. They are four independent doors.

**CM-6, configuration settings, part one.** Versioning on the primary bucket, so prior object states are recoverable and auditable.

**CM-6, configuration settings, part two.** Four required tags on every taggable resource: Project, Environment, ManagedBy, ComplianceScope. The clean way to do this is the provider `default_tags` block, so you cannot forget them on a new resource.

**AU-3 and AU-6, audit record content and review.** The primary bucket logs access to the dedicated log bucket. The log bucket needs ownership controls set so it can accept a log-delivery ACL before logging will work.

That last one is the only fiddly part. Access logging needs the destination bucket to allow the S3 log delivery group to write to it, and on modern AWS that means setting object ownership first, then the ACL, then pointing logging at it. Sequence matters. If you get an AccessDenied, that is why.

## Prerequisites

- An AWS account with permission to create S3 buckets. A sandbox account is easiest.
- Terraform 1.6 or newer. Check with `terraform version`.
- AWS CLI v2 with a working profile. If you use SSO, export credentials first: `eval "$(aws configure export-credentials --profile <your-profile> --format env)"`.
- 30 to 45 minutes.

## Cost

Under one cent if you destroy the same day. Empty S3 buckets have no idle cost. You can also stay plan-only and never create anything.

The evidence you need comes from `terraform plan`. If you want the full experience, apply, verify, and then run the cleanup at the bottom.

## Build it

The starter has `main.tf`, `variables.tf`, and `outputs.tf` with the provider, a random suffix, and the two buckets already declared. Open `main.tf` and work through the TODOs. For each control:

- Find the AWS provider resource that implements it. The Terraform registry page for the `aws` provider is your reference. Search the resource name, read the example, write your version.
- Wire it to the right bucket. Encryption, versioning, and the public access block each attach to a bucket by id.
- For tags, add the `default_tags` block to the provider so all four tags apply everywhere automatically.
- For logging, set ownership controls on the log bucket, give it a log-delivery-write ACL, then add the logging resource on the primary pointing at the log bucket.

Then add the SC-28 attestation output: surface the encryption algorithm in effect as a Terraform output. That one value is your proof of encryption in machine-readable form.

## Run it and capture evidence

Open `evidence/plan.json` and find your bucket. You should see the encryption rule (SC-28), the four-flag public access block all true (AC-3), the four tags (CM-6), and the logging block (AU-3). That JSON is your evidence. Hold onto it. Week 2 reads it.

If you applied, also capture state and run the checks.

## Done when

- `terraform validate` passes.
- `evidence/plan.json` contains all five controls: the encryption rule, the four-flag public access block, versioning enabled, the four tags, and the logging target.
- If you applied, `verify.sh` shows AES256, versioning Enabled, and all four public-access flags true.

`verify.sh` in the starter runs the three live checks for you.

## On GCP?

Same controls, different resources.

- `google_storage_bucket` with `uniform_bucket_level_access = true` covers AC-3
- A `versioning { enabled = true }` block covers CM-6, Google-managed or KMS encryption covers SC-28
- A `logging` block covers AU-3
- Use `labels` instead of tags for CM-6.

The shape of the work is identical. Find the resources, wire them up.

## Tear it down

Versioned buckets will not destroy while they hold object versions. Empty first, then destroy.

## Make it a portfolio piece

Add a new project to your portfolio this week. Keep it short and concrete:

- A one-paragraph writeup: "This Terraform module enforces SC-28, AC-3, CM-6, and AU-3 on a cloud storage bucket and emits the proof as JSON." Name the controls. Naming controls is the whole skill.
- Your `main.tf`, `variables.tf`, `outputs.tf` in a public repo.
- The `evidence/plan.json` committed alongside it.
- A README that says what it enforces and how to verify it.

Then post on LinkedIn. Tag GRC Engineering Club, use #GRCEngClubChallenge, and say one true thing about what was harder than you expected. That last part is what makes people stop scrolling.

## Common snags

- **BucketAlreadyExists.** S3 names are globally unique. The `random_id` suffix prevents this. If you hardcoded a name, change it.
- **AccessDenied on the log bucket.** The log-delivery-write ACL needs object ownership controls set first. Sequence the ownership controls before the ACL.
- **SSO credential errors from Terraform.** Run the `export-credentials` line from prerequisites before any Terraform command.
- **Only three public-access flags set.** All four must be true. Check `block_public_acls`, `block_public_policy`, `ignore_public_acls`, and `restrict_public_buckets`.

That is brick one. Next week you write the policy that proves it, automatically, every time.
