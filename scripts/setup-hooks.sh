#!/bin/bash

# Setup script to install git hooks from the hooks/ directory
# Run this script from the repository root: ./scripts/setup-hooks.sh

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/hooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "Setting up git hooks for homeland repository..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: This script must be run from the repository root"
    exit 1
fi

# Create git hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install each hook from hooks/ directory
for hook_file in "$HOOKS_DIR"/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        target_file="$GIT_HOOKS_DIR/$hook_name"

        echo "Installing $hook_name hook..."
        cp "$hook_file" "$target_file"
        chmod +x "$target_file"
        echo "✓ $hook_name hook installed"
    fi
done

echo ""
echo "Git hooks setup complete!"
echo ""
echo "Installed hooks:"
ls -la "$GIT_HOOKS_DIR" | grep -v "\.sample$" | grep -E "^-.*x.*" || echo "  (none)"

echo ""
echo "To test the pre-commit hook:"
echo "  echo 'test' > cluster/secrets.yaml"
echo "  git add cluster/secrets.yaml"
echo "  git commit -m 'test' # This should fail"
echo "  git reset HEAD cluster/secrets.yaml"
echo "  git checkout cluster/secrets.yaml"
