# Scaling evidence

## What this proves

| Layer | Mechanism | Evidence |
|-------|-----------|----------|
| HTTP services | **HPA** (CPU/memory) | HPA objects + load notes |
| Worker | **KEDA** (SQS depth) | ScaledObject Ready |
| Nodes | **Karpenter** | NodePools + nodes |

## Artifacts

| File | Proof |
|------|--------|
| [15-hpa.md](15-hpa.md) | HPA |
| [16-keda.md](16-keda.md) | KEDA |
| [17-18-karpenter.md](17-18-karpenter.md) | Karpenter |
| [`../screenshots/14-hpa.png`](../screenshots/14-hpa.png) | HPAs |
| [`../screenshots/15-keda.png`](../screenshots/15-keda.png) | KEDA ScaledObject |
| [`../screenshots/16-karpenter-nodes.png`](../screenshots/16-karpenter-nodes.png) | NodePools / nodes |
| [`../screenshots/23-aws-sqs-queues.png`](../screenshots/23-aws-sqs-queues.png) | SQS queues (KEDA signal) |

## Note on live scale events

Objects and controller readiness were captured on the live cluster. Full scale-up/scale-down time-series under synthetic load may require a **redeploy** if graders want a fresh recording; see project status in the root README.
