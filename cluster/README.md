# Talos Kubernetes Cluster

This directory contains the Talos Linux configuration for the "homeland" Kubernetes cluster.

## Overview

This setup uses Talos Linux to create a Kubernetes cluster with custom configurations for networking, storage, and cluster-specific settings. The configuration is modular, using patches to customize different aspects of the cluster.

## Prerequisites

- [Talosctl](https://www.talos.dev/v1.7/talos-guides/install/talosctl/) installed
- [SOPS](https://github.com/getsops/sops) installed for secrets decryption
- [Age](https://github.com/FiloSottile/age) for encryption key management
- Access to the target machines
- Network connectivity to `192.168.178.10`
- Age private key for decrypting secrets

## Secrets Management

The `secrets.yaml` file is encrypted using SOPS with Age encryption. To work with the encrypted secrets:

### Decrypt Secrets

To decrypt the secrets file for use with Talos:

```bash
# Decrypt to a temporary file
sops -d cluster/secrets.yaml > /tmp/secrets.yaml

# Or decrypt in-place (use with caution)
sops -d -i cluster/secrets.yaml
```

### Re-encrypt Secrets

After making changes to the secrets file:

```bash
# Re-encrypt the file
sops -e -i cluster/secrets.yaml
```

### Environment Setup

Ensure your Age private key is available:

```bash
# Set the Age key file path
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# Or set the key directly
export SOPS_AGE_KEY="AGE-SECRET-KEY-..."
```

## Usage

### 1. Decrypt Secrets

First, decrypt the encrypted secrets file:

```bash
# Decrypt secrets to a temporary file
sops -d cluster/secrets.yaml > /tmp/secrets.yaml
```

### 2. Generate Configurations

Generate the Talos configurations with all patches applied:

```bash
talosctl gen config homeland https://192.168.178.10:6443 \
  --with-secrets /tmp/secrets.yaml \
  --config-patch @cluster/patches/cluster.yaml \
  --config-patch @cluster/patches/disks.yaml \
  --config-patch @cluster/patches/network.yaml \
  --config-patch @cluster/patches/kubernetes.yaml \
  --config-patch-control-plane @cluster/patches/donetsk.yaml \
  --output cluster/rendered/ \
  --force
```

This command:

- Creates a cluster named "homeland"
- Sets the Kubernetes API endpoint to `https://192.168.178.10:6443`
- Uses the decrypted secrets from `/tmp/secrets.yaml`
- Applies all configuration patches
- Outputs rendered configurations to `cluster/rendered/`

**Note**: Remember to clean up the temporary decrypted secrets file:

```bash
rm /tmp/secrets.yaml
```

### 3. Apply Configuration to Control Plane

Apply the generated configuration to the control plane node:

```bash
talosctl apply-config \
  -f cluster/rendered/controlplane.yaml \
  -n 192.168.178.10 \
  --insecure
```

### 4. Configure Talosctl Client

Set up the talosctl client to communicate with your cluster:

```bash
# Set the endpoint
talosctl config endpoint 192.168.178.10

# Set the default node
talosctl config node 192.168.178.10
```

### 5. Bootstrap the Cluster (First Time Only)

If this is a new cluster, bootstrap the Kubernetes control plane:

```bash
talosctl bootstrap -n 192.168.178.10
```

### 6. Get Kubeconfig

Retrieve the Kubernetes configuration:

```bash
talosctl kubeconfig -n 192.168.178.10
```

## Common Operations

### Check Cluster Status

```bash
# Check Talos service status
talosctl service -n 192.168.178.10

# Check cluster health
talosctl health -n 192.168.178.10

# Get cluster info
kubectl cluster-info
```

### Add Worker Nodes

To add worker nodes, apply the worker configuration:

```bash
talosctl apply-config \
  -f cluster/rendered/worker.yaml \
  -n <worker-node-ip> \
  --insecure
```

### Update Configuration

To update the cluster configuration:

1. Decrypt the secrets file: `sops -d cluster/secrets.yaml > /tmp/secrets.yaml`
2. Modify the appropriate patch files in `cluster/patches/`
3. Regenerate configurations using the generation command (with decrypted secrets)
4. Apply the updated configurations:
5. Clean up: `rm /tmp/secrets.yaml`

```bash
talosctl apply-config \
  -f cluster/rendered/controlplane.yaml \
  -n 192.168.178.10
```

## Configuration Patches

The cluster uses several patch files to customize the Talos configuration:

- **`cluster.yaml`**: General cluster-wide settings
- **`disks.yaml`**: Disk partitioning and storage configuration
- **`network.yaml`**: Network interface and routing configuration
- **`kubernetes.yaml`**: Kubernetes-specific settings and features
- **`donetsk.yaml`**: Control plane node specific configuration

## Troubleshooting

### Check Node Status

```bash
talosctl get nodes -n 192.168.178.10
```

### View Logs

```bash
# System logs
talosctl logs -n 192.168.178.10

# Kubernetes logs
talosctl logs -n 192.168.178.10 kubernetes
```

### Reset Node (Caution!)

```bash
talosctl reset -n 192.168.178.10 --graceful
```

## Security Notes

- The `secrets.yaml` file contains sensitive cluster secrets and is encrypted with SOPS/Age
- Ensure your Age private key is securely stored and backed up
- Never commit decrypted secrets to version control
- The `--insecure` flag is used for initial setup; remove it once certificates are properly configured
- Always clean up temporary decrypted files after use

### Git Hooks Protection

The repository includes git hooks to prevent accidentally committing unencrypted secrets. To install them:

```bash
# From repository root
./scripts/setup-hooks.sh
```

The pre-commit hook will automatically check that `cluster/secrets.yaml` is encrypted before allowing commits. See `../hooks/README.md` for more details.

## Network Configuration

- **Cluster Endpoint**: `https://192.168.178.10:6443`
- **Control Plane Node**: `192.168.178.10`

Make sure your network allows communication on the required Talos and Kubernetes ports.

## References

- [Talos Documentation](https://www.talos.dev/)
- [Talos Configuration Reference](https://www.talos.dev/v1.7/reference/configuration/)
- [SOPS Documentation](https://github.com/getsops/sops)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
