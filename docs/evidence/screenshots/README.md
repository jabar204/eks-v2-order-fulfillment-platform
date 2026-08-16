# Evidence screenshots

Auto-captured cluster/CLI evidence plus your manual UI/AWS screenshots.

## Auto-captured (cluster / gallery)

| File | What it shows |
|------|----------------|
| `01-evidence-gallery-full.png` | Full kubectl evidence pack |
| `02-https-healthz.png` | Live HTTPS `/healthz` → api-gateway ok |
| `03-https-dashboard-root.png` | Live dashboard over Traefik NLB (TLS) |
| `04-github-actions-release.png` | GitHub Application Release workflow page |
| `05-github-repo.png` | Public GitHub repo |
| `06-argo.png` | Argo apps Synced/Healthy (gallery) |
| `07-pods.png` | All application pods Running |
| `08-deployments.png` | Deployments Ready |
| `09-irsa.png` | ServiceAccount → IAM role ARNs |
| `10-external-secrets.png` | ExternalSecrets SecretSynced |
| `11-ingress-certs.png` | Ingress + cert-manager Certificates |
| `12-persistence.png` | Postgres/Redis data + Bound PVCs |
| `13-snapshot.png` | VolumeSnapshot ReadyToUse |
| `14-hpa.png` | HPAs |
| `15-keda.png` | KEDA ScaledObject Ready |
| `16-karpenter-nodes.png` | NodePools + nodes |
| `17-monitoring.png` | Monitoring stack pods |
| `18-networkpolicies.png` | NetworkPolicies across namespaces |
| `evidence-gallery.html` | Source HTML for gallery screenshots |

## Your screenshots (manual)

| File | What it shows |
|------|----------------|
| `19-dashboard-services-health.png` | Dashboard **Services** tab — all services green |
| `20-grafana-kubernetes-proxy.png` | Grafana Kubernetes / Proxy dashboard |
| `21-vscode-pods-running-dockerfile.png` | Distroless Dockerfile + `kubectl get pods` all Running |
| `22-dashboard-orders-ui.png` | Dashboard **Orders** UI (TOTAL ORDERS = 1) |
| `23-aws-sqs-queues.png` | AWS SQS: order-events, DLQ, Karpenter interruption |
| `24-argocd-cli-synced-healthy.png` | `kubectl get applications -n argocd` Synced/Healthy |
| `25-github-actions-app-release.png` | GitHub Actions Application Release history |
| `26-aws-ecr-repositories.png` | ECR private repos (9 immutable, KMS) |
| `27-argocd-ui-applications.png` | Argo CD UI — root / platform / order-fulfillment-dev |
| `28-https-api-gateway-healthz.png` | HTTPS healthz JSON `api-gateway` status ok |
