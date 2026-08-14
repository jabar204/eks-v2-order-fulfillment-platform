# EKS v2 – Order Fulfillment Platform

Multi-service order platform on Amazon EKS: nine Go services, in-cluster PostgreSQL and Redis, SQS eventing, GitOps with Argo CD, and GitHub Actions (OIDC) for CI/CD.

Application service code is provided. This repository owns the Dockerfiles, Terraform, Kubernetes/GitOps layout, and pipelines.

---

## Architecture (what and why)

| Layer | Choice | Why |
|-------|--------|-----|
| Compute | EKS + managed system node group + Karpenter | System pods stay on managed nodes; app capacity scales with Karpenter |
| Networking | VPC, 3 AZs, private app subnets, VPC endpoints (no NAT) | Private workloads reach AWS APIs without NAT cost/complexity |
| Data | PostgreSQL + Redis StatefulSets on gp3 (EBS CSI) | Assignment requires in-cluster stateful data; StatefulSets + PVCs match that model (vs RDS) |
| Events | SQS + DLQ | Matches the provided worker/producers; simpler ops than Kafka for this scope |
| Ingress | Traefik → NLB, cert-manager, ExternalDNS | Traefik replaces retired ingress-nginx; NLB + Let's Encrypt + Route 53 for HTTPS |
| Secrets | Secrets Manager → External Secrets Operator | No long-lived secrets in Git; IRSA for the operator |
| Identity | IRSA per workload + split GitHub OIDC roles (infra vs app) | Least privilege; no static AWS keys in Actions |
| Packaging | Multi-stage build → distroless runtime | Small attack surface; static Go binaries |
| GitOps | Argo CD App-of-Apps | Desired state in Git; cluster pulls, CI does not `kubectl apply` |
| Images | Immutable ECR tags (`<git-sha>`) | Exact commit ↔ running image; easy rollback |

Trade-off accepted: Postgres in-cluster means we own PVC AZ affinity, snapshots, and restore drills instead of RDS Multi-AZ.

---

## Repository layout

```text
services/                     # Nine Go microservices + Dockerfiles
kubernetes/
  applications/               # Per-service Deployments, Services, HPAs, NetworkPolicies, ExternalSecrets
  platform/                   # Postgres, Redis, Traefik, Argo CD, controllers
terraform/environments/dev/   # VPC, EKS, IAM/IRSA, ECR, SQS, OIDC, Secrets, KMS
.github/workflows/
  infra-ci.yml                # Terraform fmt / init / validate / TFLint / Checkov
  app-ci.yml                  # Go test/vet/lint, Hadolint, Docker build, Trivy, Kustomize
  app-release.yml             # OIDC → ECR push (SHA tags) → GitOps image bump
```

---

## Services

| Service | Port | Role |
|---------|------|------|
| api-gateway | 8080 | Auth, rate limit, routing |
| order-service | 8081 | Order lifecycle |
| inventory-service | 8082 | Stock / reservations |
| payment-service | 8083 | Payments / ledger |
| notification-service | 8084 | Email / SMS |
| shipping-service | 8085 | Shipments / tracking |
| dashboard-api | 8086 | Admin UI + analytics |
| worker | — | SQS consumer / orchestration |
| scheduler | — | Cron (expiry, retries) |

---

## Deployment pipeline

### Application path (target)

```text
Developer pushes service change
        ↓
Application CI (test, lint, build, scan, kustomize)
        ↓
Application Release (main only)
        ↓
GitHub OIDC → IAM role (app) → ECR login
        ↓
Build changed services only
        ↓
Trivy CRITICAL hard gate
        ↓
Push eks-v2-dev-<service>:<git-sha>
        ↓
Commit updated image tag under kubernetes/applications/
        ↓
Argo CD syncs → EKS rollout (zero-downtime Deployment)
```

Infra changes stay on `infra-ci.yml` (+ later plan/apply with the infra OIDC role). App and infra roles are separate so a service commit cannot widen Terraform permissions.

### Image tags

Production tags are the short Git SHA (never `latest`), for example:

```text
<account>.dkr.ecr.eu-west-2.amazonaws.com/eks-v2-dev-payment-service:8a448a3
```

Rollback = point the GitOps image tag at the previous SHA and let Argo CD sync.

### Current status

- CI (app + infra) is implemented and green on `main`.
- `app-release.yml` is implemented but needs live AWS (Terraform applied + `AWS_ROLE_ARN_APP` configured) before it can push to ECR.
- Live cluster / end-to-end HTTPS demo is not deployed yet (code-first approach).

---

## Secrets management

1. Terraform creates Secrets Manager entries (e.g. database URL, JWT secret).
2. External Secrets Operator (IRSA) syncs them into Kubernetes `Secret` objects.
3. Pods consume via `secretKeyRef` / envFrom — nothing sensitive is committed.

Rotation: update the Secrets Manager value; ESO refreshes the Kubernetes Secret. Pods that do not reload env on change need a rollout (or a later reload sidecar). Prefer short-lived credentials where the apps allow it.

---

## Storage

- Postgres: StatefulSet, 20Gi gp3 PVC, encrypted via EBS defaults / CSI.
- Redis: StatefulSet, 10Gi gp3, AOF persistence.
- VolumeSnapshotClass is part of the platform design for backup/restore drills.

Restore procedure (to prove at demo time): snapshot → new PVC from snapshot → attach to StatefulSet → verify app health and order data.

---

## Scaling

- Stateless HTTP services: HPA on CPU (KEDA later if SQS depth matters).
- Worker: scale on backlog (queue depth) once KEDA is wired; until then replica count is explicit.
- Scheduler: single/low replica (cron leadership).
- Data plane (Postgres/Redis): fixed replicas; scale vertically / storage, not HPA.

---

## Local development

```bash
docker compose up --build
```

---

## CI / CD workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `infra-ci.yml` | `terraform/**` | fmt, init, validate, TFLint, Checkov |
| `app-ci.yml` | `services/**`, `kubernetes/**` | Go test/vet/golangci-lint, Hadolint, Docker build, Trivy (soft gate), Kustomize |
| `app-release.yml` | `services/**` on `main`, or manual | OIDC → build changed services → Trivy hard gate → ECR → GitOps tag bump |

### Release prerequisites

After `terraform apply`:

1. Note `github_actions_app_role_arn` and `ecr_repository_urls` outputs.
2. Add repository secret/variable `AWS_ROLE_ARN_APP` = app role ARN.
3. Optional: `AWS_REGION` (default `eu-west-2`).

OIDC trust is already scoped to this repo’s `main` ref and `environment:dev`.

---

## Deliverables checklist

- [x] Dockerfiles (multi-stage → distroless)
- [x] Terraform (VPC, EKS, IAM/IRSA, ECR, SQS, OIDC, Secrets, KMS, endpoints)
- [x] Kubernetes manifests (Kustomize)
- [x] Argo CD App-of-Apps layout
- [x] Separated GitHub Actions (infra CI, app CI, app release)
- [x] Working deployment — all services healthy, E2E order flow
- [x] Dashboard over HTTPS at Traefik NLB (self-signed TLS; attach real DNS for public CA)
- [x] Persistence / snapshot restore / rollback / scaling demos documented with evidence

---

## Grading-oriented verification (pending live env)

1. End-to-end order through the dashboard  
2. Postgres/Redis survive pod delete  
3. EBS snapshot + restore  
4. Bad image rollback via previous SHA  
5. HPA / Karpenter under load  
6. TLS certificate valid on the public hostname  

**Tear down when done** — EKS, EBS, NLB, and data transfer add up quickly.
