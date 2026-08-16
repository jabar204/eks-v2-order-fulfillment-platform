# PostgreSQL recovery (EBS snapshot / restore)

## Pod-level failure

Postgres is a StatefulSet with a Bound PVC. Deleting the Pod recreates it on the same volume; application data remains.

Evidence of this drill: [`../evidence/storage/10-postgres-persist.md`](../evidence/storage/10-postgres-persist.md).

## Volume / AZ failure — restore from VolumeSnapshot

Documented path:

```text
PVC → EBS VolumeSnapshot → new PVC from snapshot → attach to Postgres → verify data
```

1. Ensure a `VolumeSnapshot` of the Postgres PVC is `ReadyToUse` (see [`../evidence/storage/12-snapshot.md`](../evidence/storage/12-snapshot.md)).
2. Create a PVC from the snapshot (VolumeSnapshotClass / CSI restore).
3. Point the Postgres StatefulSet (or a recovery StatefulSet) at the restored PVC — carefully, in a maintenance window for production.
4. Start Postgres and verify row counts / known test markers.
5. Re-point applications when healthy.

## Prevention

- Keep regular VolumeSnapshots for critical PVCs.
- Prefer gp3 with encryption defaults from the CSI / account baseline.
