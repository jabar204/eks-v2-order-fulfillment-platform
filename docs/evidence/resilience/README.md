# Resilience evidence

## What this proves

- SQS normal processing path + DLQ present
- Rolling update / zero-downtime notes
- E2E order through dashboard
- Cost / teardown after validation

## Artifacts

| File | Proof |
|------|--------|
| [13-14-sqs-dlq.md](13-14-sqs-dlq.md) | SQS + DLQ |
| [19-rolling-update.md](19-rolling-update.md) | Rolling update |
| [25-e2e.md](25-e2e.md) | E2E order |
| [23-cost.md](23-cost.md) | Cost notes |
| [27-readme.md](27-readme.md) | README checkpoint |
| [28-teardown.md](28-teardown.md) | Teardown |
| [`../screenshots/23-aws-sqs-queues.png`](../screenshots/23-aws-sqs-queues.png) | SQS + DLQ in AWS |
| [`../screenshots/22-dashboard-orders-ui.png`](../screenshots/22-dashboard-orders-ui.png) | Order id present |

Runbooks: [dlq](../../runbooks/dlq-recovery.md) · [rollback](../../runbooks/rollback.md) · [cost](../../runbooks/cost-control.md)
