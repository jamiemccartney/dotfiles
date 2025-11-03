#!/usr/bin/env bash
set -euo pipefail

# Restore arrays from environment
eval "$BREW_PACKAGES_DEF"
eval "$BREW_CASKS_DEF"

if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew is not installed. Please install it first from https://brew.sh" >&2
  exit 1
fi

MODE="${1:-install}"

if [ "$MODE" = "update" ]; then
  echo "Upgrading packages..."

  for pkg in "${BREW_PACKAGES[@]}"; do
    echo "  Upgrading $pkg..."
    brew upgrade "$pkg" || brew install "$pkg"
  done

  for cask in "${BREW_CASKS[@]}"; do
    echo "  Upgrading $cask (cask)..."
    brew upgrade --cask "$cask" || brew install --cask "$cask"
  done

  echo "✅ Package upgrade complete"
else
  echo "Installing packages..."

  for pkg in "${BREW_PACKAGES[@]}"; do
    echo "  Installing $pkg..."
    brew install "$pkg"
  done

  for cask in "${BREW_CASKS[@]}"; do
    echo "  Installing $cask (cask)..."
    brew install --cask "$cask"
  done

  echo "✅ Package installation complete"
fi
