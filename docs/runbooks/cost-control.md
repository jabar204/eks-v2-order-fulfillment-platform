# Cost-control decisions

| Decision | Why |
|----------|-----|
| Karpenter consolidation | Return unused EC2 capacity when pods drain |
| HPA + KEDA | Scale pods with demand instead of over-provisioning |
| gp3 EBS | Cost-effective default for Postgres/Redis PVCs |
| ECR lifecycle / immutable SHA tags | Avoid unbounded `latest` sprawl; retain only needed SHAs |
| CloudWatch log retention | Cap retention on cluster/app logs |
| No NAT (VPC endpoints) | Avoid NAT Gateway hourly + data charges for AWS API access |
| Destroy dev when idle | EKS control plane, NLB, EBS, and nodes dominate cost |

## After validation

This project’s AWS development environment was **destroyed** after evidence capture. To re-run live demos, re-apply Terraform and reconfigure GitHub OIDC secrets. See [`../evidence/resilience/28-teardown.md`](../evidence/resilience/28-teardown.md).
