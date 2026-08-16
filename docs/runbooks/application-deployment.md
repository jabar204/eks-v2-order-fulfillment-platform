# Application deployment

## Flow

```text
code change → CI → ECR → GitOps overlay commit → Argo CD → EKS
```

1. Push changes to `services/**` (and/or related paths) on `main`.
2. **Application CI** runs tests, lint, image build, Trivy (soft gate in CI), and Kustomize validation.
3. **Application Release** assumes the app IAM role via **GitHub OIDC**, builds changed services, fails on **Trivy CRITICAL**, pushes `eks-v2-dev-<service>:<git-sha>` to **ECR**.
4. Release commits updated `newName` / `newTag` under `kubernetes/overlays/dev/kustomization.yaml`.
5. **Argo CD** detects the Git change and syncs the `order-fulfillment-dev` (and related) Applications onto **EKS**.
6. Kubernetes performs a rolling update on Deployments (readiness gates keep traffic on healthy Pods).

## Prerequisites (live environment)

- Terraform applied for the target account/region
- Repository secret `AWS_ROLE_ARN_APP` set to the app OIDC role ARN
- Argo CD installed and pointed at this repository / overlay

## Verify

```bash
kubectl get applications -n argocd
kubectl get pods -A | grep -E 'api-gateway|order-service|worker'
```

See also: [rollback](rollback.md), [Argo CD failure](argocd-failure.md).
