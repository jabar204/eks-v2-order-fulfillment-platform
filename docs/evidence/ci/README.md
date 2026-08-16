# CI / OIDC / ECR evidence

## What this proves

- Green **Application CI** and **Application Release** on GitHub Actions
- **GitHub OIDC** authenticating to AWS (no static access keys in Actions)
- **SHA-tagged images** in private ECR repositories

## Screenshots

| File | Proof |
|------|--------|
| [`../screenshots/04-github-actions-release.png`](../screenshots/04-github-actions-release.png) | Application Release workflow |
| [`../screenshots/25-github-actions-app-release.png`](../screenshots/25-github-actions-app-release.png) | Release run history |
| [`../screenshots/05-github-repo.png`](../screenshots/05-github-repo.png) | Repository |
| [`../screenshots/26-aws-ecr-repositories.png`](../screenshots/26-aws-ecr-repositories.png) | ECR repos (immutable tags, KMS) |

## Notes

- Release workflow uses `permissions: id-token: write` and `aws-actions/configure-aws-credentials` with role assumption (OIDC).
- Overlay tags in `kubernetes/overlays/dev/kustomization.yaml` were set to SHA `188340b` during the live demo.
- Terraform CI is workflow `infra-ci.yml` (fmt, validate, TFLint, Checkov). Re-check Actions on `main` after documentation pushes that touch `terraform/**`.
