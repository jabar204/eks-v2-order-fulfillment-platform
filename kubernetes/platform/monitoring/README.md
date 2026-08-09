# Monitoring (kube-prometheus-stack)

Focused stack: Prometheus, Grafana, Alertmanager, kube-state-metrics, node-exporter.

## Install (bootstrap)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f kubernetes/platform/monitoring/values.yaml
```

Apply custom alerts:

```bash
kubectl apply -k kubernetes/platform/monitoring
```

## Alerts included

| Alert | Intent |
|-------|--------|
| PodCrashLooping | Restarts > 3 in 15m |
| DeploymentReplicasUnavailable | Apps unavailable > 10m |
| HighCPU | App pod CPU > 80% for 10m |
| PostgresUnavailable | StatefulSet not ready |
| RedisUnavailable | StatefulSet not ready |
| WorkerQueueBacklog | Worker under scale pressure |

Replace Grafana `adminPassword` after Terraform/secrets bootstrap.
