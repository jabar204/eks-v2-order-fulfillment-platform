# Placeholders to replace after Terraform apply

## Resolved (live AWS account 283434716298 / eu-west-2)

| Item | Value |
|------|-------|
| Account ID | `283434716298` |
| Cluster | `eks-v2-dev-cluster` |
| VPC | `vpc-0104ccb441649f51c` |
| SQS queue | `https://sqs.eu-west-2.amazonaws.com/283434716298/eks-v2-dev-order-events` |
| ECR pattern | `283434716298.dkr.ecr.eu-west-2.amazonaws.com/eks-v2-dev-<service>` |
| GitHub app role | `arn:aws:iam::283434716298:role/eks-v2-dev-github-actions-app` |
| GitHub infra role | `arn:aws:iam::283434716298:role/eks-v2-dev-github-actions-infra` |

## GitHub Actions secrets / vars (set manually in repo settings)

| Name | Type | Value |
|------|------|-------|
| `AWS_ROLE_ARN_APP` | secret | `arn:aws:iam::283434716298:role/eks-v2-dev-github-actions-app` |
| `AWS_ROLE_ARN_INFRA` | secret | `arn:aws:iam::283434716298:role/eks-v2-dev-github-actions-infra` |
| `AWS_REGION` | variable | `eu-west-2` |

## Intentionally remaining in Git

| Pattern | Why |
|---------|-----|
| `REPLACE_WITH_ECR/<service>` | Kustomize **image name** keys in base Deployments — overlay rewrites them |
| `newTag: bootstrap` | Until Application Release pushes the first real `<git-sha>` |
| Grafana `adminPassword` in values | Temporary; rotate after Helm install |

## Search

```bash
git grep "REPLACE_AFTER"
git grep "ACCOUNT_ID"
git grep "bootstrap"
```
