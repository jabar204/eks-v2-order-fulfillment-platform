# Rollback (GitOps image SHA)

## Goal

Return from a bad application image to a known-good immutable SHA without cluster-side improvisation.

## Procedure

1. Identify the last known-good short Git SHA that was pushed to ECR (from release history or `kubernetes/overlays/dev/kustomization.yaml` history).
2. Update each affected service `newTag` in `kubernetes/overlays/dev/kustomization.yaml` to that SHA (or revert the GitOps commit that introduced the bad tag).
3. Commit and push to `main`.
4. Wait for Argo CD to sync (`Synced` / `Healthy`).
5. Confirm Pods are running the previous image:

```bash
kubectl get pods -o wide
kubectl describe deploy <service> | grep -i image
```

## Notes

- Tags are immutable ECR digests keyed by Git SHA — do not use `latest`.
- Prefer reverting the GitOps commit over editing the live cluster; Argo CD is the source of truth.
