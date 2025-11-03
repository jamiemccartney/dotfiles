#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew is not installed. Please install it first from https://brew.sh" >&2
  exit 1
fi

echo "Installing packages..."
brew install ripgrep
brew install neovim
brew install --cask ghostty
brew install fd

echo "✅ Package installation complete"
