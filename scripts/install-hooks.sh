#!/bin/bash
# Install git hooks for Yoda.nvim

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SCRIPTS_DIR="$REPO_ROOT/scripts"

echo "🔧 Installing git hooks for Yoda.nvim..."
echo ""

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
echo "📝 Installing pre-commit hook..."
if [ -f "$HOOKS_DIR/pre-commit" ]; then
  echo "⚠️  Existing pre-commit hook found, backing up to pre-commit.backup"
  mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup"
fi

# Create symlink to the hook script
ln -s "$SCRIPTS_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will run 'make lint' and 'make test' before each commit."
echo ""
echo "To skip the hook (not recommended), use:"
echo "  git commit --no-verify"
echo ""
echo "To uninstall, run:"
echo "  rm $HOOKS_DIR/pre-commit"
echo ""

