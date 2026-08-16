# Argo CD failure procedure

## Symptoms

Application shows `OutOfSync`, `Degraded`, `Progressing` stuck, or `Unknown`.

## Checklist

1. **Git vs live**
   - `argocd app get <name>` or `kubectl get application -n argocd`
   - Confirm the tracked revision and path (`kubernetes/overlays/dev` or App-of-Apps children).

2. **Sync errors**
   - Open the Application events / sync result.
   - Common causes: invalid manifests, missing CRDs, image pull errors, Resource hooks failing (e.g. migration Job).

3. **Cluster health**
   - `kubectl get pods -A` — CrashLoopBackOff, ImagePullBackOff, Pending (scheduling / Karpenter).
   - `kubectl describe pod <pod>` for events.

4. **Image / registry**
   - Confirm ECR tag exists for the SHA in the overlay.
   - Confirm node IRSA / pull permissions if pulls fail.

5. **Self-heal / manual drift**
   - If someone edited live objects, enable sync/self-heal or run a controlled sync.
   - Evidence of self-heal: [`../evidence/gitops/08-argo-self-heal.md`](../evidence/gitops/08-argo-self-heal.md).

6. **Rollback**
   - If a bad SHA caused Degraded, follow [rollback](rollback.md).

## Avoid

- Long-lived `kubectl edit` that fights GitOps without updating Git.
- Force-deleting PVCs attached to StatefulSets unless you intend data loss.
