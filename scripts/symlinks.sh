#!/usr/bin/env bash
set -euo pipefail

echo "Creating symlinks..."

ln -sfn "$GHOSTTY_HOME" "$SYMLINK_CONFIG_DIR/ghostty"
echo "  ✓ ghostty -> $SYMLINK_CONFIG_DIR/ghostty"

ln -sfn "$TMUX_HOME" "$SYMLINK_CONFIG_DIR/tmux"
echo "  ✓ tmux -> $SYMLINK_CONFIG_DIR/tmux"

ln -sfn "$ZSH_HOME" "$SYMLINK_CONFIG_DIR/zsh"
echo "  ✓ zsh -> $SYMLINK_CONFIG_DIR/zsh"

ln -sfn "$ZSH_HOME/.zshrc" "$HOME/.zshrc"
echo "  ✓ .zshrc -> $HOME/.zshrc"

ln -sfn "$NVIM_HOME" "$SYMLINK_CONFIG_DIR/nvim"
echo "  ✓ nvim -> $SYMLINK_CONFIG_DIR/nvim"

echo "✅ Symlinks created"
