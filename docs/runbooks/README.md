# Runbooks

| Doc | Purpose |
|-----|---------|
| [application-deployment.md](application-deployment.md) | Code → CI → ECR → GitOps → Argo CD → EKS |
| [rollback.md](rollback.md) | Revert to a known-good image SHA |
| [postgresql-recovery.md](postgresql-recovery.md) | Pod survival + EBS snapshot restore |
| [dlq-recovery.md](dlq-recovery.md) | Investigate and replay SQS DLQ messages |
| [argocd-failure.md](argocd-failure.md) | OutOfSync / Degraded checklist |
| [cost-control.md](cost-control.md) | Cost decisions and teardown |
