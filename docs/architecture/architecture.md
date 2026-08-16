# Architecture — EKS order fulfillment platform

## Objective

Design and deploy a production-style microservices platform on Amazon EKS using Infrastructure as Code, GitOps, secure secrets management, and Kubernetes operational patterns.

## End-to-end delivery path

```text
GitHub → OIDC → ECR → Argo CD → EKS
```

Release detail:

```text
Git push → CI → OIDC → ECR → SHA image → dev Kustomize overlay → Git commit → Argo CD → EKS
```

## Inside the cluster

```text
NLB → Traefik → API Gateway → microservices

SQS → Worker (KEDA)
PostgreSQL → EBS (gp3)
Redis → EBS (gp3)
HPA (HTTP) · KEDA (queue) · Karpenter (nodes)
Prometheus / Grafana
```

## AWS

- Amazon VPC (private app subnets, VPC endpoints)
- Amazon EKS
- Amazon ECR (immutable SHA tags, KMS)
- Amazon SQS (+ DLQ)
- AWS Secrets Manager
- IAM (IRSA + GitHub OIDC roles)
- Amazon EBS (gp3 via CSI)
- Optional: Route 53 / ACM-style public TLS when DNS is attached

## Kubernetes platform

- Traefik (ingress → NLB)
- cert-manager
- Argo CD (App-of-Apps)
- External Secrets Operator
- Karpenter
- KEDA
- Metrics Server
- EBS CSI Driver
- kube-prometheus-stack

## Application workloads

api-gateway · order-service · inventory-service · payment-service · shipping-service · notification-service · scheduler · worker · dashboard-api · PostgreSQL · Redis
