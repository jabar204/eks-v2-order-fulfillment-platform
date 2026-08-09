# Postgres snapshot / restore runbook

## Layout

```text
Postgres Pod
   ↓
PVC (postgres-data-postgres-0)
   ↓
EBS volume (gp3, encrypted)
   ↓
VolumeSnapshot (ebs-snapshot-class)
   ↓
restore → new PVC → attach to StatefulSet
```

## Take a snapshot

```bash
kubectl apply -f kubernetes/platform/storage/volumesnapshot-postgres-test.yaml
kubectl get volumesnapshot -n data
kubectl get volumesnapshotcontent
```

Wait until `READYTOUSE=true`.

## Restore (dev drill)

1. Scale Postgres down: `kubectl scale statefulset postgres -n data --replicas=0`
2. Create a PVC from the snapshot:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data-restore
  namespace: data
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: gp3
  resources:
    requests:
      storage: 20Gi
  dataSource:
    name: postgres-data-test
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

3. Point the StatefulSet volumeClaimTemplate / temporary restore Deployment at the restored PVC (or swap PVC names carefully in a maintenance window).
4. Scale Postgres back up and verify `orders` row counts match the pre-failure state.
5. Document evidence (timestamps, row counts) for the assignment demo.

## Redis

Redis uses a 10Gi gp3 PVC with AOF. For this project, prove Pod delete survival; full snapshot restore is required for Postgres (source of truth).
