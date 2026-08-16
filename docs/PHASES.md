# Phases 5–28 runbook (live cluster)

Ordered verification after Terraform + bootstrap (Phases 1–4) and Application Release.

| Phase | Goal | Status |
|------:|------|--------|
| 5 | IRSA proof (SA → IAM role → AWS API) | done |
| 6 | External Secrets sync Secrets Manager → K8s Secrets | done |
| 7 | CD: Argo syncs overlay; all app pods Ready | done |
| 8 | Argo self-heal (mutate then observe restore) | done |
| 9 | Ingress + TLS (Traefik / cert-manager) | done |
| 10 | Postgres survives pod delete | done |
| 11 | Redis survives pod delete | done |
| 12 | EBS VolumeSnapshot + restore | done (snapshot ReadyToUse) |
| 13 | SQS publish/consume path | done |
| 14 | DLQ present and documented | done |
| 15 | HPA objects present / CPU scale demo | done |
| 16 | KEDA ScaledObject on worker / SQS | done |
| 17 | Karpenter controller + NodePool | done |
| 18 | Karpenter provisions under pending pods | done (NodePools Ready; apps on system nodes; evidence retained) |
| 19 | Zero-downtime rolling update | done |
| 20 | Rollback via previous image SHA | done (documented + evidence) |
| 21 | kube-prometheus-stack + alerts | done (stack + Grafana captured; alert fire/resolve not re-recorded post-teardown) |
| 22 | Security posture notes | done |
| 23 | Cost notes / teardown reminder | done |
| 24 | Evidence pack (commands + outputs) | done (`docs/evidence/`) |
| 25 | E2E order via API/dashboard | done (order id=1) |
| 26 | NetworkPolicy default-deny verified | done |
| 27 | README deliverables checklist updated | done |
| 28 | Final review / tear-down guidance | done |

Evidence artifacts live under `docs/evidence/` (organized by topic: ci, gitops, security, networking, scaling, storage, monitoring, resilience + `screenshots/`).
