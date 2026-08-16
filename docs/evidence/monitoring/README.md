# Monitoring evidence

## What this proves

- kube-prometheus-stack components running
- Grafana dashboards available (Kubernetes / Proxy)
- Prometheus scraping cluster/workload metrics

## Artifacts

| File | Proof |
|------|--------|
| [21-monitoring.md](21-monitoring.md) | Monitoring notes |
| [`../screenshots/17-monitoring.png`](../screenshots/17-monitoring.png) | Monitoring pods |
| [`../screenshots/20-grafana-kubernetes-proxy.png`](../screenshots/20-grafana-kubernetes-proxy.png) | Grafana dashboard |

## Alerts

Alert rules ship with kube-prometheus-stack. A deliberate fire/resolve recording (e.g. forced CrashLoop) was not re-captured after teardown; redeploy if a fresh alert lifecycle screenshot is required.
