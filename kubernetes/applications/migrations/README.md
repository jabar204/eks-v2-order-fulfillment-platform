# Database migrations

One shared Postgres database. Schema changes run as a Kubernetes **Job** before application sync (Argo CD sync-wave `-1`), so services do not race to create tables.

## Flow

```text
Argo CD sync
   ↓
migration Job (wave -1)
   ↓
schema applied (idempotent SQL)
   ↓
application Deployments (wave 0+)
```

## Rollback

1. Prefer **forward-fix** migrations (`002_*.sql`) over destructive edits.
2. If a bad migration ships: restore Postgres from the latest EBS VolumeSnapshot (see `kubernetes/platform/storage/RESTORE.md`), then redeploy the previous Git revision.
3. Do not drop columns until all services that read them are rolled back.

Services still keep `CREATE TABLE IF NOT EXISTS` as a safety net; the Job is the source of truth for ordered schema changes.
