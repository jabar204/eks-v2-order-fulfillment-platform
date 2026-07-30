# Terraform remote state bootstrap

Creates the S3 bucket used by environment backends.

State locking uses **S3 native lockfiles** (`use_lockfile = true` in
`environments/*/backend.tf`). No DynamoDB lock table is required.

## Apply once (local state)

```bash
cd terraform/backend
terraform init
terraform apply
```

Then configure each environment backend against the bucket name output.
