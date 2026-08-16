# Evidence pack

Validation evidence from the live AWS EKS deployment (later destroyed for cost control). Screenshots remain under [`screenshots/`](screenshots/).

| Category | Contents |
|----------|----------|
| [ci](ci/) | Application CI, Terraform CI, OIDC, ECR SHA images |
| [gitops](gitops/) | Argo CD Synced/Healthy, self-heal, rollback |
| [security](security/) | IRSA, External Secrets, NetworkPolicies, credential review |
| [networking](networking/) | HTTPS dashboard / healthz, ingress, certs |
| [scaling](scaling/) | HPA, KEDA, Karpenter |
| [storage](storage/) | Postgres/Redis persistence, VolumeSnapshot |
| [monitoring](monitoring/) | Prometheus / Grafana |
| [resilience](resilience/) | SQS/DLQ, rolling update, E2E, teardown |
| [screenshots](screenshots/) | PNG gallery (`01`–`28`) |

Phase status log: [`../PHASES.md`](../PHASES.md)
