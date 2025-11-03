#!/usr/bin/env bash
set -euo pipefail

# Restore arrays from environment
eval "$REPOS_DEF"

get_install_path() {
  local type="$1"
  local subtype="$2"
  local name="$3"

  case "$type" in
    tmux)
      # Install to repo: config/tmux/plugins/tpm
      echo "$TMUX_HOME/$subtype/$name"
      ;;
    zsh)
      # Install to repo: config/zsh/config/plugins/ or config/zsh/config/themes/
      echo "$ZSH_HOME/config/$subtype/$name"
      ;;
    *)
      echo "Error: Unknown type '$type'" >&2
      return 1
      ;;
  esac
}

run_post_action() {
  local action="$1"
  local dest="$2"

  if [[ -n "$action" ]]; then
    echo "  🔧 Running post-action..."
    # Evaluate the action in a subshell with dest available
    eval "$action"
  fi
}

init_repos() {
  echo "Cloning repositories..."

  for entry in "${REPOS[@]}"; do
    # Split on pipe to separate main entry from post-action
    IFS='|' read -r main_entry post_action <<< "$entry"
    read -r type_subtype repo_url name clone_opts <<< "$main_entry"

    IFS=':' read -r type subtype <<< "$type_subtype"
    local dest=$(get_install_path "$type" "$subtype" "$name")

    if [[ -d "$dest" ]]; then
      echo "⏭️Skipping $name (already exists)"
    else
      echo "📦Cloning $name..."
      mkdir -p "$(dirname "$dest")"
      if [[ -n "$clone_opts" ]]; then
        git clone "$repo_url" "$dest" $clone_opts
      else
        git clone "$repo_url" "$dest"
      fi
      run_post_action "$post_action" "$dest"
    fi
  done

  echo "✅Repository initialization complete"
}

update_repos() {
  echo "Updating repositories..."

  for entry in "${REPOS[@]}"; do
    # Split on pipe to separate main entry from post-action
    IFS='|' read -r main_entry post_action <<< "$entry"
    read -r type_subtype repo_url name clone_opts <<< "$main_entry"

    IFS=':' read -r type subtype <<< "$type_subtype"
    local dest=$(get_install_path "$type" "$subtype" "$name")

    if [[ ! -d "$dest" ]]; then
      echo "⚠️Skipping $name (not found, run init first)"
      continue
    fi

    echo "🔄Updating $name..."

    # Try to pull from main first, fallback to master
    if git -C "$dest" rev-parse --verify main &>/dev/null; then
      git -C "$dest" pull origin main
    elif git -C "$dest" rev-parse --verify master &>/dev/null; then
      git -C "$dest" pull origin master
    else
      echo "⚠️ Warning: Could not determine default branch"
    fi
  done

  echo "✅Repository updates complete"
}

case "$1" in
  init)
    init_repos
    ;;
  update)
    update_repos
    ;;
  *)
    echo "Usage: $0 <init|update>"
    exit 1
    ;;
esac