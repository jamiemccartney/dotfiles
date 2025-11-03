#!/usr/bin/env bash
set -euo pipefail

# Restore arrays from environment
eval "$SYMLINKS_DEF"

echo "Creating symlinks..."

for entry in "${SYMLINKS[@]}"; do
  IFS=':' read -r source target <<< "$entry"
  ln -sfn "$source" "$target"
  echo "  ✓ $(basename "$target") -> $target"
done

echo "✅ Symlinks created"
