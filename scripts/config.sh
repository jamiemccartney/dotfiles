#!/usr/bin/env bash

# Directory paths
export REPO_ROOT="$(pwd)"
export CONFIG_DIR="$REPO_ROOT/config"
export SYMLINK_CONFIG_DIR="$HOME/.config"

export TMUX_HOME="$CONFIG_DIR/tmux"
export ZSH_HOME="$CONFIG_DIR/zsh"
export NVIM_HOME="$CONFIG_DIR/nvim"
export GHOSTTY_HOME="$CONFIG_DIR/ghostty"

# Brew packages to install
BREW_PACKAGES=(
  "ripgrep"
  "neovim"
  "fd"
  "tmux"
)

# Brew casks to install
BREW_CASKS=(
  "ghostty"
)

# Symlinks to create (format: "source:target")
SYMLINKS=(
  "$GHOSTTY_HOME:$SYMLINK_CONFIG_DIR/ghostty"
  "$TMUX_HOME:$SYMLINK_CONFIG_DIR/tmux"
  "$ZSH_HOME:$SYMLINK_CONFIG_DIR/zsh"
  "$ZSH_HOME/.zshrc:$HOME/.zshrc"
  "$NVIM_HOME:$SYMLINK_CONFIG_DIR/nvim"
)

# Repositories to clone (format: "type:subtype url name [clone_opts] | post_action")
REPOS=(
  "tmux:plugins https://github.com/tmux-plugins/tpm tpm"
  "zsh:themes https://github.com/spaceship-prompt/spaceship-prompt.git spaceship-prompt | ln -sf \"$ZSH_HOME/config/themes/spaceship-prompt/spaceship.zsh\" \"$ZSH_HOME/config/themes/spaceship.zsh-theme\""
  "zsh:plugins https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions"
  "zsh:plugins https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting"
  "zsh:plugins https://github.com/fdellwing/zsh-bat.git zsh-bat"
)

# Export array definitions for subshells
export BREW_PACKAGES_DEF="$(declare -p BREW_PACKAGES)"
export BREW_CASKS_DEF="$(declare -p BREW_CASKS)"
export SYMLINKS_DEF="$(declare -p SYMLINKS)"
export REPOS_DEF="$(declare -p REPOS)"
