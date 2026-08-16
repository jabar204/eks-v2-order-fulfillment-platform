# Networking / HTTPS evidence

## What this proves

- Working HTTPS path through NLB → Traefik → API Gateway / dashboard
- Ingress and certificate objects present during the live demo

## Artifacts

| File | Proof |
|------|--------|
| [09-https.md](09-https.md) | HTTPS notes |
| [`../screenshots/02-https-healthz.png`](../screenshots/02-https-healthz.png) | HTTPS `/healthz` |
| [`../screenshots/03-https-dashboard-root.png`](../screenshots/03-https-dashboard-root.png) | Dashboard over TLS |
| [`../screenshots/28-https-api-gateway-healthz.png`](../screenshots/28-https-api-gateway-healthz.png) | healthz JSON ok |
| [`../screenshots/11-ingress-certs.png`](../screenshots/11-ingress-certs.png) | Ingress + certs |
| [`../screenshots/19-dashboard-services-health.png`](../screenshots/19-dashboard-services-health.png) | Dashboard services green |
| [`../screenshots/22-dashboard-orders-ui.png`](../screenshots/22-dashboard-orders-ui.png) | Orders UI (E2E) |
