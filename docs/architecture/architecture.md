# EKS Order Fulfillment Platform Architecture

## Objective

Design and deploy a production-style microservices platform on Amazon EKS using Infrastructure as Code, GitOps, secure secrets management, and Kubernetes best practices.

### AWS
- Amazon VPC
- Amazon EKS
- Amazon ECR
- Amazon SQS
- AWS Secrets Manager
- Route 53
- IAM
- Amazon EBS

### Kubernetes
- Traefik
- cert-manager
- ExternalDNS
- ArgoCD
- External Secrets Operator
- Karpenter
- Metrics Server
- EBS CSI Driver

### Application
- API Gateway
- Order Service
- Inventory Service
- Payment Service
- Shipping Service
- Notification Service
- Scheduler
- Worker
- Dashboard API
- PostgreSQL
- Redis