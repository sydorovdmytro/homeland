# Git Hooks

This directory contains git hooks for the homeland repository to ensure security and consistency.

## Available Hooks

### pre-commit

Prevents committing unencrypted secrets by checking that `cluster/secrets.yaml` is properly encrypted with SOPS.

**What it does:**

- Checks if `cluster/secrets.yaml` exists
- Verifies the file contains SOPS metadata (`sops:` and `version:` keys)
- Blocks commit if the file appears to be unencrypted
- Provides helpful error messages with remediation steps

**Bypass (use carefully):**

```bash
git commit --no-verify
```

## Installation

Run the setup script from the repository root:

```bash
./scripts/setup-hooks.sh
```

This will copy all hooks from this directory to `.git/hooks/` and make them executable.

## Testing

To test the pre-commit hook:

```bash
# This should fail (unencrypted file)
echo 'unencrypted: content' > cluster/secrets.yaml
git add cluster/secrets.yaml
git commit -m "test"

# Clean up
git reset HEAD cluster/secrets.yaml
git checkout cluster/secrets.yaml
```

## Manual Installation

If you prefer to install hooks manually:

```bash
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
