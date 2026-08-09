# Placeholders to replace after Terraform apply

Run before go-live:

```bash
git grep "REPLACE_"
git grep "ACCOUNT_ID"
git grep "bootstrap"
```

## Values that depend on AWS outputs

| Placeholder / location | Terraform output / source |
|------------------------|---------------------------|
| `ACCOUNT_ID` in `kubernetes/overlays/dev/kustomization.yaml` | AWS account ID (`aws_caller_identity`) |
| `newTag: bootstrap` in overlay images | First real `<git-sha>` from Application Release |
| `REPLACE_WITH_ECR/<service>` (base Deployments) | Left as Kustomize image **name**; overlay rewrites |
| `REPLACE_AFTER_TERRAFORM_APPLY` SQS URL (worker, producers) | `sqs_queue_url` (or equivalent) |
| Worker SA `eks.amazonaws.com/role-arn` | `worker_sqs_role_arn` / `app_irsa_role_arns["worker"]` |
| KEDA values / TriggerAuthentication IRSA | Worker or dedicated KEDA role ARN |
| KEDA ScaledObject `queueURL` | SQS queue URL |
| External Secrets / ALB controller / Karpenter role ARNs | Matching Terraform IRSA outputs |
| ALB controller `vpcId` | `vpc_id` |
| Grafana `adminPassword` | Generate + store in Secrets Manager |
| GitHub secret `AWS_ROLE_ARN_APP` | `github_actions_app_role_arn` |
| GitHub secret `AWS_ROLE_ARN_INFRA` | `github_actions_infra_role_arn` |
| GitHub var `AWS_REGION` | `eu-west-2` |

## Intentionally unchanged until first release

- Overlay `newTag: bootstrap` — CD replaces per service on first successful release.
- Base image names `REPLACE_WITH_ECR/...` — Kustomize image transformer keys, not live registry hosts.
