# Credential / secret review

Run during final portfolio cleanup (AWS env already destroyed).

## Static AWS keys

```text
git grep -i "aws_access_key"
```

**Result:** no matches.

```text
git grep -i "aws_secret"
```

**Result:** matches are Terraform resource names (`aws_secretsmanager_secret`) and ARN references — not static access-key material.

## Broader secret-like strings

```text
git grep -i "password"
git grep -i "token"
git grep -i "secret"
```

Review guidance:

- Expect hits for External Secrets, Secrets Manager Terraform, JWT secret *resource* names, Grafana bootstrap comments, and documentation.
- Do **not** treat every hit as a leaked credential; none of the reviewed hits were long-lived AWS access keys committed to Git.
- Screenshots were reviewed for obvious secrets/tokens before publishing; prefer redacting account-specific console URLs if sharing externally beyond this portfolio repo.

## Placeholders

`REPLACE_WITH_ECR/<service>` remains intentional as Kustomize **image name keys** rewritten by the dev overlay and Application Release (`kustomize edit set image`). Documented in [`../../PLACEHOLDERS.md`](../../PLACEHOLDERS.md).

`ACCOUNT_ID` as a literal placeholder string is not used; account id appears as Terraform `data.aws_caller_identity` interpolations and as the live ECR hostname captured during the demo (`283434716298...`).
