# Traefik Ingress Controller

Traefik is the external traffic entry point for the EKS Order Fulfillment Platform.

## Traffic flow

```text
Internet
  ↓
Route 53
  ↓
AWS Network Load Balancer
  ↓
Traefik
  ↓
Kubernetes routing resource
  ↓
API Gateway or Dashboard Service