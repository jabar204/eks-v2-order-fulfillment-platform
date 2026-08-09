# KEDA

Scales the **worker** from SQS queue depth (not CPU).

## Install (bootstrap)

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm upgrade --install keda kedacore/keda \
  -n keda --create-namespace \
  -f kubernetes/platform/keda/values.yaml
```

Then apply the ScaledObject / TriggerAuthentication (via Argo CD platform sync or):

```bash
kubectl apply -k kubernetes/platform/keda
```

## Design

| Workload | Scaler | Signal |
|----------|--------|--------|
| HTTP services | HPA | CPU |
| Worker | KEDA | SQS `ApproximateNumberOfMessages` |
| Nodes | Karpenter | pending pods |

Replace `REPLACE_AFTER_TERRAFORM_APPLY` with the SQS queue URL and worker IRSA role ARN after `terraform apply`.
