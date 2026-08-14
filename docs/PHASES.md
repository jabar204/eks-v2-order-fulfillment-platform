# Phases 5–28 runbook (live cluster)

Ordered verification after Terraform + bootstrap (Phases 1–4) and Application Release.

| Phase | Goal | Status |
|------:|------|--------|
| 5 | IRSA proof (SA → IAM role → AWS API) | in progress |
| 6 | External Secrets sync Secrets Manager → K8s Secrets | done (KMS decrypt fix) |
| 7 | CD: Argo syncs overlay; all app pods Ready | done |
| 8 | Argo self-heal (mutate then observe restore) | pending |
| 9 | Ingress + TLS (Traefik / cert-manager) | in progress |
| 10 | Postgres survives pod delete | pending |
| 11 | Redis survives pod delete | pending |
| 12 | EBS VolumeSnapshot + restore | pending |
| 13 | SQS publish/consume path | pending |
| 14 | DLQ present and documented | pending |
| 15 | HPA objects present / CPU scale demo | pending |
| 16 | KEDA ScaledObject on worker / SQS | pending |
| 17 | Karpenter controller + NodePool | pending |
| 18 | Karpenter provisions under pending pods | pending |
| 19 | Zero-downtime rolling update | pending |
| 20 | Rollback via previous image SHA | pending |
| 21 | kube-prometheus-stack + alerts | pending |
| 22 | Security posture notes | pending |
| 23 | Cost notes / teardown reminder | pending |
| 24 | Evidence pack (commands + outputs) | pending |
| 25 | E2E order via API/dashboard | pending |
| 26 | NetworkPolicy default-deny verified | pending |
| 27 | README deliverables checklist updated | pending |
| 28 | Final review / tear-down guidance | pending |

Evidence artifacts live under `docs/evidence/`.
