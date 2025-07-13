# Flux GitOps Configuration

This directory contains the Flux GitOps configuration for managing Kubernetes workloads and infrastructure declaratively.

## Overview

Flux automatically synchronizes the cluster state with the configuration stored in this Git repository. It provides:

- **GitOps workflow**: All changes go through Git
- **Automated deployments**: Flux watches for changes and applies them
- **Secret management**: Integration with SOPS/Age for encrypted secrets
- **Multi-environment support**: Organized by clusters and environments

## Prerequisites

- [Flux CLI](https://fluxcd.io/flux/installation/) installed
- kubectl configured for your cluster
- GitHub personal access token with repo permissions
- SOPS/Age key for secret decryption

## Setup

### 1. Bootstrap Flux

Bootstrap Flux in your Kubernetes cluster:

```bash
flux bootstrap github \
  --token-auth \
  --owner=sydorovdmytro \
  --repository=homeland \
  --branch=main \
  --path=flux/clusters/production
```

This command:

- Installs Flux components in the `flux-system` namespace
- Creates necessary CRDs and RBAC
- Sets up GitOps sync with this repository
- Configures Flux to watch the `flux/clusters/production` path

### 2. Configure SOPS Secret

Create the Age key secret for SOPS decryption:

```bash
cat ~/.config/sops/age/keys.txt | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/dev/stdin
```

This allows Flux to decrypt SOPS-encrypted secrets automatically.

## Usage

### Check Flux Status

```bash
# Check Flux system status
flux get all

# Check specific components
flux get sources git
flux get kustomizations
flux get helmreleases
```

### Viewing Logs

```bash
# Flux controller logs
flux logs --level=info --all-namespaces

# Specific controller logs
kubectl logs -n flux-system deployment/source-controller
kubectl logs -n flux-system deployment/kustomize-controller
```

### Force Reconciliation

```bash
# Force sync from Git
flux reconcile source git flux-system

# Force reconcile kustomization
flux reconcile kustomization infrastructure
```

## Workflow

1. **Make changes** to configurations in this directory
2. **Commit and push** changes to the repository
3. **Flux detects** changes automatically (default: 1 minute)
4. **Applies changes** to the cluster

### Manual Sync

For immediate deployment without waiting:

```bash
flux reconcile source git flux-system
```

## Secret Management

Secrets are encrypted using SOPS with Age encryption:

### Encrypting Secrets

```bash
# Encrypt a secret file
sops -e -i secret-file.yaml
```

### Viewing Encrypted Secrets

```bash
# Decrypt and view (read-only)
sops -d secret-file.yaml
```

## Troubleshooting

### Common Issues

**Flux not syncing:**

```bash
# Check source status
flux get sources git

# Check for errors
flux logs --level=error
```

**SOPS decryption failing:**

```bash
# Verify age secret exists
kubectl get secret sops-age -n flux-system

# Check kustomize controller logs
kubectl logs -n flux-system deployment/kustomize-controller
```

**Resource conflicts:**

```bash
# Check kustomization status
flux get kustomizations

# Force reconciliation
flux reconcile kustomization <name> --with-source
```

## References

- [Flux Documentation](https://fluxcd.io/flux/)
- [Flux CLI Reference](https://fluxcd.io/flux/cmd/)
- [SOPS Integration](https://fluxcd.io/flux/guides/mozilla-sops/)
- [GitOps Principles](https://fluxcd.io/flux/concepts/)
