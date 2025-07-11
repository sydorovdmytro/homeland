# Homeland - Home Lab Infrastructure

This repository contains the infrastructure as code for my home lab setup.

## 📁 Components

### [🚀 Kubernetes Cluster](./cluster/)

[Talos](https://www.talos.dev/) Linux-based Kubernetes cluster with custom configurations for networking, storage, and security.

[📖 View Cluster Documentation](./cluster/README.md)

## � Quick Start

1. **Set up git hooks** (prevents committing unencrypted secrets):

   ```bash
   ./scripts/setup-hooks.sh
   ```

2. **Deploy components**:
   - [Kubernetes Cluster](./cluster/README.md)

## 📚 References

- [Talos Documentation](https://www.talos.dev/)
- [Git Hooks Documentation](./hooks/README.md)
