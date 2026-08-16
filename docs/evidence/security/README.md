# Security evidence

## What this proves

- **IRSA** — ServiceAccounts annotated with IAM role ARNs; no static AWS keys in pods
- **External Secrets** — Secrets Manager → Kubernetes Secrets (`SecretSynced`)
- **NetworkPolicies** applied
- Credential scan notes for the repository

## Artifacts

| File | Proof |
|------|--------|
| [05-irsa.md](05-irsa.md) | IRSA notes |
| [06-external-secrets.md](06-external-secrets.md) | ESO notes |
| [22-security.md](22-security.md) | Security posture |
| [26-networkpolicy.md](26-networkpolicy.md) | NetworkPolicy |
| [credential-review.md](credential-review.md) | `git grep` review results |
| [`../screenshots/09-irsa.png`](../screenshots/09-irsa.png) | SA → IAM roles |
| [`../screenshots/10-external-secrets.png`](../screenshots/10-external-secrets.png) | ExternalSecrets synced |
| [`../screenshots/18-networkpolicies.png`](../screenshots/18-networkpolicies.png) | NetworkPolicies |
| [`../screenshots/21-vscode-pods-running-dockerfile.png`](../screenshots/21-vscode-pods-running-dockerfile.png) | Distroless Dockerfile + pods |

## Confirmations

| Control | Status |
|---------|--------|
| GitHub → AWS via OIDC | Confirmed in release workflow + ECR push evidence |
| Pod → AWS via IRSA | Confirmed |
| Secrets Manager → K8s via External Secrets | Confirmed |
| Trivy CRITICAL hard gate on release | Confirmed (`exit-code: 1` in `app-release.yml`) |
| Distroless + `USER nonroot` | Confirmed in all service Dockerfiles |
