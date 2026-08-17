# EKS v2 — Production-Style Order Fulfillment Platform

A production-style, cloud-native order fulfillment platform built on **Amazon EKS**, designed to demonstrate modern DevOps, Platform Engineering, GitOps, DevSecOps, autoscaling, observability, security and disaster-recovery practices.

The platform consists of **9 Go microservices** deployed to Kubernetes and provisioned through Terraform. Application delivery is automated using GitHub Actions, Amazon ECR and Argo CD, with GitHub OIDC and Kubernetes IRSA used to eliminate long-lived AWS credentials.

> **Project Status: Completed and validated on AWS.**
>
> The complete platform was successfully provisioned on AWS, deployed to Amazon EKS and validated through end-to-end testing. Deployment, GitOps, HTTPS, autoscaling, persistent storage, monitoring, secrets management and AWS integrations were tested in the live environment. Evidence was captured before the development infrastructure was destroyed to prevent unnecessary AWS costs.

---

# Architecture

The platform follows a layered cloud-native architecture:

```text
Developer
    │
    ▼
GitHub
    │
    ├──── Application CI
    │       ├── Go test
    │       ├── Go vet
    │       ├── golangci-lint
    │       ├── Hadolint
    │       ├── Docker build
    │       ├── Trivy
    │       └── Kustomize validation
    │
    ▼
Application Release
    │
    ├── GitHub OIDC
    │
    ▼
AWS IAM
    │
    ▼
Amazon ECR
    │
    │ Immutable <git-sha> image
    ▼
Kustomize Dev Overlay
    │
    ▼
Git Commit
    │
    ▼
Argo CD
    │
    ▼
Amazon EKS
```

Application traffic follows:

```text
Internet
   │
   ▼
Route53 / DNS
   │
   ▼
AWS Load Balancer
   │
   ▼
Traefik
   │
   ▼
API Gateway
   │
   ├── Order Service
   ├── Inventory Service
   ├── Payment Service
   ├── Notification Service
   └── Shipping Service
             │
             ▼
            SQS
             │
             ▼
           Worker

Dashboard API
Scheduler

PostgreSQL ── EBS
Redis      ── EBS
```

Platform capabilities include:

```text
HPA        → workload scaling
KEDA       → SQS-driven worker scaling
Karpenter  → EC2/node capacity scaling

External Secrets → AWS Secrets Manager
IRSA             → AWS workload permissions
cert-manager     → TLS certificates

Prometheus
    │
    ▼
Grafana
    │
    ▼
Alertmanager
```

---

# Technology Stack

| Area                   | Technology                                      |
| ---------------------- | ----------------------------------------------- |
| Cloud                  | AWS                                             |
| Kubernetes             | Amazon EKS                                      |
| Infrastructure as Code | Terraform                                       |
| Containers             | Docker                                          |
| Application            | Go                                              |
| Container Registry     | Amazon ECR                                      |
| CI/CD                  | GitHub Actions                                  |
| Authentication         | GitHub OIDC                                     |
| GitOps                 | Argo CD                                         |
| Configuration          | Kustomize                                       |
| Ingress                | Traefik                                         |
| Messaging              | Amazon SQS                                      |
| Dead Letter Queue      | Amazon SQS DLQ                                  |
| Database               | PostgreSQL                                      |
| Cache                  | Redis                                           |
| Storage                | Amazon EBS gp3                                  |
| Workload Autoscaling   | Kubernetes HPA                                  |
| Event Autoscaling      | KEDA                                            |
| Node Autoscaling       | Karpenter                                       |
| Secrets                | AWS Secrets Manager + External Secrets Operator |
| AWS Pod Authentication | IRSA                                            |
| TLS                    | cert-manager                                    |
| DNS                    | ExternalDNS / Route53                           |
| Monitoring             | Prometheus                                      |
| Visualisation          | Grafana                                         |
| Alerting               | Alertmanager                                    |
| Image Security         | Trivy                                           |
| Container Linting      | Hadolint                                        |
| Go Linting             | golangci-lint                                   |

---

# Microservices

The platform contains nine independently containerised Go services.

| Service              | Port | Responsibility                                       |
| -------------------- | ---: | ---------------------------------------------------- |
| api-gateway          | 8080 | External API entry point, routing and authentication |
| order-service        | 8081 | Order lifecycle management                           |
| inventory-service    | 8082 | Inventory management                                 |
| payment-service      | 8083 | Payment processing                                   |
| notification-service | 8084 | Notification handling                                |
| shipping-service     | 8085 | Shipping workflow                                    |
| worker               | 8090 | Asynchronous SQS event processing                    |
| scheduler            | 8091 | Scheduled/background operations                      |
| dashboard-api        | 8086 | Operational dashboard API                            |

Each service is packaged using a **multi-stage Docker build** with a minimal/distroless runtime image.

---

# Infrastructure as Code

AWS infrastructure is managed using Terraform.

Terraform provisions the core infrastructure required by the platform, including:

* Amazon VPC
* public/private networking
* Amazon EKS
* EKS managed node capacity
* IAM roles
* EKS OIDC integration
* IRSA roles
* Amazon ECR repositories
* Amazon SQS
* Dead Letter Queue
* AWS Secrets Manager
* AWS KMS
* VPC endpoints
* GitHub Actions OIDC roles
* supporting controller IAM permissions

Terraform state is stored remotely rather than locally to support reliable infrastructure management.

Infrastructure workflows are separated into:

```text
infra-ci.yml
terraform-plan.yml
terraform-apply.yml
```

Infrastructure changes are validated before deployment, while Terraform apply is intentionally controlled rather than automatically executing every infrastructure change.

---

# CI Pipeline

Application CI runs automatically when relevant application or Kubernetes files change.

```text
Developer Push / Pull Request
            │
            ▼
       Application CI
            │
     ┌──────┼─────────┐
     │      │         │
     ▼      ▼         ▼
 Go Test  Go Vet   golangci-lint
     │
     ▼
 Hadolint
     │
     ▼
 Docker Build
     │
     ▼
 Trivy Scan
     │
     ▼
 Kustomize Validation
```

The pipeline validates all nine services through a GitHub Actions matrix strategy.

This provides early feedback before application changes can progress toward release.

---

# Continuous Delivery & GitOps

Application releases follow a GitOps delivery model.

```text
Application Change
        │
        ▼
Application CI
        │
        ▼
Application Release
        │
        ▼
GitHub OIDC
        │
        ▼
Temporary AWS Credentials
        │
        ▼
Docker Build
        │
        ▼
Trivy Security Gate
        │
        ▼
Amazon ECR
        │
        ▼
service:<git-sha>
        │
        ▼
kubernetes/overlays/dev
        │
        ▼
newTag: <git-sha>
        │
        ▼
Git Commit
        │
        ▼
Argo CD
        │
        ▼
Amazon EKS
```

Images are promoted using immutable Git commit SHA tags rather than relying on mutable `latest` tags.

The release workflow updates the **Kustomize development overlay** rather than directly modifying base Deployment manifests.

This keeps:

```text
kubernetes/applications/*
```

as reusable application bases while:

```text
kubernetes/overlays/dev
```

contains environment-specific image promotion.

Argo CD continuously reconciles the desired state stored in Git with the state running inside EKS.

---

# GitOps Architecture

The Git repository acts as the source of truth for application deployment state.

```text
Base manifests
      │
      ▼
kubernetes/applications/*
      │
      ▼
Dev Kustomize Overlay
      │
      ▼
kubernetes/overlays/dev
      │
      ▼
Argo CD
      │
      ▼
Amazon EKS
```

The project uses an Argo CD App-of-Apps structure, with the development application targeting the Kustomize overlay.

This separates:

* reusable Kubernetes resources;
* environment configuration;
* image promotion;
* cluster reconciliation.

---

# Security Architecture

Security was designed into both the CI/CD pipeline and Kubernetes environment.

## GitHub → AWS

GitHub Actions authenticates to AWS using **OpenID Connect (OIDC)**.

```text
GitHub Actions
      │
      ▼
OIDC Token
      │
      ▼
AWS STS
      │
      ▼
Temporary Credentials
```

This removes the requirement to store long-lived AWS access keys in GitHub.

## Kubernetes → AWS

Kubernetes workloads use **IAM Roles for Service Accounts (IRSA)**.

For example:

```text
Worker Pod
    │
    ▼
worker ServiceAccount
    │
    ▼
EKS OIDC
    │
    ▼
Worker IAM Role
    │
    ▼
Amazon SQS
```

AWS permissions are therefore attached to workload identities rather than embedded credentials.

## Secrets

Application secrets follow:

```text
AWS Secrets Manager
        │
        ▼
External Secrets Operator
        │
        ▼
ExternalSecret
        │
        ▼
Kubernetes Secret
        │
        ▼
Application
```

Sensitive values such as database connection information and JWT signing secrets are therefore not stored directly in application manifests.

Additional security controls include:

* KMS encryption;
* NetworkPolicies;
* namespace isolation;
* ResourceQuota;
* LimitRange;
* image vulnerability scanning;
* minimal/distroless container images;
* IAM least-privilege design;
* immutable container image promotion.

---

# Autoscaling Strategy

The project implements autoscaling at **three different infrastructure layers**.

## 1. HPA — HTTP workloads

Kubernetes Horizontal Pod Autoscaler is used for resource-driven application scaling.

```text
Traffic increases
       │
       ▼
CPU utilisation increases
       │
       ▼
HPA
       │
       ▼
Additional Pods
```

## 2. KEDA — asynchronous worker

The worker is event-driven, so CPU alone is not an ideal scaling signal.

KEDA scales the worker based on Amazon SQS queue depth.

```text
SQS backlog increases
        │
        ▼
KEDA
        │
        ▼
Worker replicas increase
        │
        ▼
Messages processed
        │
        ▼
Queue drains
        │
        ▼
Worker replicas decrease
```

## 3. Karpenter — infrastructure capacity

Karpenter handles underlying compute capacity.

```text
Pods require capacity
        │
        ▼
Unschedulable Pods
        │
        ▼
Karpenter
        │
        ▼
EC2 capacity
        │
        ▼
Node joins EKS
        │
        ▼
Pods scheduled
```

Together this provides:

```text
HPA       → Pod scaling based on application load
KEDA      → Pod scaling based on event backlog
Karpenter → Node scaling based on scheduling demand
```

---

# Persistent Storage

PostgreSQL and Redis are deployed as StatefulSets using persistent storage.

```text
StatefulSet
     │
     ▼
PVC
     │
     ▼
gp3 StorageClass
     │
     ▼
Amazon EBS
```

Persistent data therefore exists independently from the lifetime of an individual Pod.

Deleting and recreating a Pod does not automatically remove its persistent EBS-backed data.

---

# Backup & Disaster Recovery

The platform includes EBS snapshot support through Kubernetes VolumeSnapshots.

```text
PersistentVolumeClaim
        │
        ▼
Amazon EBS
        │
        ▼
VolumeSnapshot
        │
        ▼
EBS Snapshot
```

A restore runbook is included in the repository to document recovery of persistent data from snapshots.

This provides a documented disaster-recovery path for stateful workloads.

---

# Messaging & Failure Handling

Amazon SQS provides asynchronous communication for event-driven workloads.

```text
Application
     │
     ▼
SQS Queue
     │
     ▼
Worker
     │
     ▼
Event Processing
```

Failed messages can be retried and eventually moved to a Dead Letter Queue after the configured maximum receive count.

```text
Message
   │
   ▼
Processing Failure
   │
   ▼
Retry
   │
   ▼
Retry limit reached
   │
   ▼
DLQ
```

This prevents repeatedly failing events from blocking normal queue processing and provides a location for investigation and recovery.

---

# Kubernetes Reliability & Hardening

The Kubernetes configuration includes operational controls such as:

* readiness probes;
* liveness probes;
* resource requests;
* resource limits;
* PodDisruptionBudgets;
* topology spreading / anti-affinity;
* NetworkPolicies;
* default-deny networking;
* ResourceQuota;
* LimitRange;
* StatefulSets;
* persistent storage;
* autoscaling.

These controls are intended to improve availability, scheduling behaviour, resource governance and workload isolation.

---

# Observability

The monitoring stack is based on:

```text
Applications / Kubernetes
          │
          ▼
      Prometheus
          │
          ├─────────► Alertmanager
          │
          ▼
        Grafana
```

The monitoring configuration provides visibility into cluster and workload health, including:

* Pod health;
* Deployment availability;
* CPU utilisation;
* memory utilisation;
* node health;
* persistent storage;
* autoscaling behaviour;
* application availability.

Alerting rules are included for important operational conditions such as unavailable workloads and resource pressure.

---

# HTTPS & Ingress

External application access follows:

```text
Internet
   │
   ▼
DNS
   │
   ▼
AWS Load Balancer
   │
   ▼
Traefik
   │
   ▼
Kubernetes Services
```

TLS certificate management is handled using cert-manager.

The live environment successfully demonstrated HTTPS access to the deployed platform before the development infrastructure was destroyed.

---

# Database Migrations

Database schema changes are handled through a Kubernetes migration Job rather than allowing multiple application replicas to independently attempt schema changes.

```text
Deployment
    │
    ▼
Migration Job
    │
    ▼
PostgreSQL
    │
    ▼
Application rollout
```

This provides a more controlled database deployment process.

---

# Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── app-ci.yml
│       ├── app-release.yml
│       ├── infra-ci.yml
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
│
├── services/
│   ├── api-gateway/
│   ├── order-service/
│   ├── inventory-service/
│   ├── payment-service/
│   ├── notification-service/
│   ├── shipping-service/
│   ├── worker/
│   ├── scheduler/
│   └── dashboard-api/
│
├── kubernetes/
│   ├── applications/
│   ├── overlays/
│   │   └── dev/
│   └── platform/
│
├── terraform/
│   ├── backend/
│   └── environments/
│       └── dev/
│
└── docs/
    ├── architecture/
    ├── decisions/
    ├── diagrams/
    ├── evidence/
    └── runbooks/
```

---

# Validation & Evidence

The platform was deployed to a live AWS environment and tested before teardown.

Validation evidence includes:

* successful GitHub Actions CI;
* successful application release workflow;
* GitHub OIDC authentication;
* Amazon ECR repositories and immutable image tags;
* live EKS nodes;
* all application workloads running;
* Argo CD `Synced` and `Healthy`;
* HTTPS application access;
* IRSA configuration;
* External Secrets;
* TLS certificates;
* PostgreSQL and Redis persistence;
* EBS VolumeSnapshots;
* HPA;
* KEDA;
* Karpenter;
* NetworkPolicies;
* Prometheus/Grafana monitoring;
* Amazon SQS;
* AWS infrastructure teardown.

See:

**`docs/evidence/`**

for captured validation evidence.

---

# Cost Management

The environment was designed as a development/portfolio environment rather than a permanently running production system.

Cost-conscious decisions include:

* autoscaling;
* Karpenter capacity management;
* gp3 storage;
* controlled log retention;
* ECR lifecycle management;
* resource requests and limits;
* Terraform-managed infrastructure;
* destroying the development environment after validation.

After completing the live AWS validation and capturing evidence, the environment was destroyed to prevent unnecessary ongoing AWS charges.

Because the infrastructure is defined as code, it can be recreated using Terraform when required.

---

# Project Outcome

This project demonstrates an end-to-end DevOps and Platform Engineering workflow covering:

**Infrastructure**

Terraform → AWS → Amazon EKS

**Application Delivery**

GitHub Actions → OIDC → ECR → Kustomize → Argo CD → EKS

**Security**

OIDC → IRSA → External Secrets → KMS → NetworkPolicies → Trivy

**Scaling**

HPA → KEDA → Karpenter

**State**

StatefulSets → PVC → gp3 → EBS → VolumeSnapshots

**Observability**

Prometheus → Grafana → Alertmanager

**Reliability**

health probes → PDBs → topology controls → GitOps reconciliation → DLQ → backup/recovery

The project was successfully deployed and validated in AWS before the development environment was intentionally destroyed for cost control.

---

# Evidence

Live deployment and validation evidence is available under:

```text
docs/evidence/
```

The evidence demonstrates the platform operating on AWS rather than only showing infrastructure and Kubernetes configuration.

---

# Final Status

**Status: Completed ✅**

The infrastructure, Kubernetes platform, CI/CD pipelines, GitOps workflow, security controls, autoscaling, persistent storage, observability and application workloads were implemented and validated against a live Amazon EKS environment.

The live development environment was subsequently destroyed after validation to avoid unnecessary AWS costs.
