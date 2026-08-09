# Checkov decisions (dev)

Every Checkov finding is either fixed in Terraform or consciously accepted here.

## Fixed / improved

| Topic | Change |
|-------|--------|
| ECR encryption | Customer-managed KMS (`aws_kms_key.eks`) |
| Secrets Manager encryption | Customer-managed KMS (`aws_kms_key.secrets`) |
| CloudWatch Logs encryption | EKS log group uses KMS with Logs service policy |
| VPC endpoint SG egress | Restricted to VPC CIDR on TCP/443 |
| EKS secrets encryption | Already enabled |
| Image scan on push | Already enabled |
| IRSA / split GitHub OIDC roles | Already least-privilege split (infra vs app) |

## Accepted exceptions (dev)

| Finding | Reason |
|---------|--------|
| S3 cross-region replication (state bucket) | Skipped for dev cost; recommend for production DR |
| Secrets Manager automatic rotation | Deferred — secrets are app-managed strings; no rotation Lambda yet |
| EKS public API endpoint | Retained for admin access; restricted via `cluster_public_access_cidrs` (tighten to `/32` before shared use) |
| Postgres/Redis in-cluster vs RDS | Assignment requires StatefulSets; accept AZ/PVC operational trade-offs |
| Checkov soft_fail in `infra-ci.yml` | Keeps signal without blocking PRs while exceptions are documented |

Update this file when accepting or closing new findings.
