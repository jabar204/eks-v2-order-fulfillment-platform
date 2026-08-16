# SQS DLQ recovery

## Normal path

```text
Order event → SQS → Worker → success → message deleted
```

## Failure path

```text
Message → processing failure → visibility timeout / retries → maxReceiveCount → DLQ
```

Evidence notes: [`../evidence/resilience/13-14-sqs-dlq.md`](../evidence/resilience/13-14-sqs-dlq.md).

## Investigate a DLQ message

1. Inspect the DLQ in the AWS console or CLI (`ReceiveMessage` with a short visibility timeout for inspection only).
2. Capture message body, approximate receive count, and timestamps.
3. Check worker logs for the correlation id / order id.
4. Fix the root cause (bad payload, downstream outage, permissions).

## Safe replay

1. After the fix is deployed and healthy, **re-drive** or copy the message back to the main queue (console redrive, or `SendMessage` with the original body).
2. Confirm the worker processes successfully and the message is deleted from the main queue.
3. Delete or archive the DLQ copy once confirmed — avoid double-processing business side effects.

Do not blindly purge the DLQ without sampling messages first.
