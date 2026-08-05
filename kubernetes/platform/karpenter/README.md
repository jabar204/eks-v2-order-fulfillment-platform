# Karpenter

Karpenter provides just-in-time EC2 node provisioning for the EKS cluster.

## Architecture

The managed EKS node group hosts critical system components:

- Karpenter controller
- CoreDNS
- Metrics Server
- ArgoCD
- cert-manager
- External Secrets

Karpenter-created nodes host application workloads.

## AWS dependencies

Terraform creates:

- Karpenter controller IRSA role
- Karpenter node IAM role
- EC2 instance profile
- EKS access entry
- SQS interruption queue
- EventBridge rules and targets
- Subnet and security-group discovery tags

## Kubernetes resources

- Helm-installed Karpenter controller
- EC2NodeClass
- General-purpose NodePool
- Spot NodePool

## Installation

The controller is installed using the official OCI Helm chart.

```bash
helm upgrade --install karpenter \
  oci://public.ecr.aws/karpenter/karpenter \
  --version 1.14.0 \
  --namespace kube-system \
  --values values.yaml