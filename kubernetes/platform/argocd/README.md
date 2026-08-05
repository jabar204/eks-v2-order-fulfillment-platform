# Argo CD — App-of-Apps

GitOps entrypoint for the order fulfillment platform.

## Layout

```text
argocd/
├── applications/
│   ├── applications.yaml      # business apps (dev overlay)
│   ├── infrastructure.yaml    # postgres, redis
│   └── platform.yaml          # traefik, cert-manager, ESO, Karpenter, …
├── kustomization.yaml         # wires project + child Applications
├── project.yaml               # AppProject (order-fulfillment)
├── root-application.yaml      # bootstrap Application (apply once)
├── values.yaml                # Helm values for installing Argo CD itself
└── README.md
```

## Sync waves

| Wave | Apps |
|------|------|
| 0 | storage, metrics-server |
| 1 | cert-manager, external-secrets, external-dns, aws-load-balancer-controller |
| 2 | traefik, karpenter |
| 3 | postgres, redis |
| 4 | apps-dev |

## Bootstrap

1. Install Argo CD (Helm), using `values.yaml`:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f kubernetes/platform/argocd/values.yaml
```

2. Apply the root app (points Argo at this folder):

```bash
kubectl apply -f kubernetes/platform/argocd/root-application.yaml
```

3. Argo CD syncs `project.yaml` + everything under `applications/`.

## Notes

- Update `repoURL` in `root-application.yaml` and the child Applications if the GitHub remote differs.
- `apps-dev` expects `kubernetes/overlays/dev` to exist; keep it as a stub until manifests land.
- Platform charts that are Helm-only can later switch their Application `source` to `helm` + `values.yaml` under each component folder.
