# Storage evidence

## What this proves

- PostgreSQL / Redis data survives Pod delete (PVC-backed StatefulSets)
- EBS **VolumeSnapshot** reached `ReadyToUse`
- Restore path documented: PVC → snapshot → new PVC → verify data

## Artifacts

| File | Proof |
|------|--------|
| [10-postgres-persist.md](10-postgres-persist.md) | Postgres persist |
| [11-redis-persist.md](11-redis-persist.md) | Redis persist |
| [12-snapshot.md](12-snapshot.md) | Snapshot ReadyToUse |
| [`../screenshots/12-persistence.png`](../screenshots/12-persistence.png) | Bound PVCs / data |
| [`../screenshots/13-snapshot.png`](../screenshots/13-snapshot.png) | VolumeSnapshot |

Runbook: [`../../runbooks/postgresql-recovery.md`](../../runbooks/postgresql-recovery.md)
