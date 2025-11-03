wt() {
  local cmd="$1"
  local branch="$2"
  local base_repo="/Users/jamesmccartney/gitRepos/holibob"
  local wt_dir="/Users/jamesmccartney/gitRepos/holibob-worktrees"
  local wt_path="$wt_dir/$branch"

  if [ -z "$cmd" ] || [ -z "$branch" ]; then
    echo "Usage: wt <add|remove> <branch>"
    return 1
  fi

  case "$cmd" in
    add)
     git fetch origin

      if [ -d "$wt_path" ]; then
        echo "❌ Worktree path '$wt_path' already exists."
        return 1
      fi

      # If remote branch exists, track it, otherwise create from origin master and unset master tracking
      if git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
        git worktree add -b "$branch" "$wt_path" "origin/$branch"
        echo "✅ Worktree tracking remote branch '$branch' created at $wt_path"
      else
        git worktree add -b "$branch" "$wt_path" origin/master
        git -C "$wt_path" branch --unset-upstream
        echo "✅ New branch '$branch' worktree created at $wt_path from origin/master"
      fi


      # Optionally copy idea config
      if [ -d "$base_repo/.idea" ]; then
        echo "✅ Copying .idea folder from $base_repo"
        cp -r "$base_repo/.idea" "$wt_path"
      fi

      # Optionally open in IntelliJ
      if command -v idea >/dev/null 2>&1; then
        echo "✅ Opening $wt_path in IDE."
        idea "$wt_path"
      fi
      ;;
    remove)
      if [ ! -d "$wt_path" ]; then
        echo "❌ Worktree path '$wt_path' does not exist."
        return 1
      fi

      git worktree remove --force "$wt_path"

      if [ -d "$wt_path" ]; then
        cd "$wt_path"
        rm -rf "$wt_path"
        echo "🗑️ Deleted folder $wt_path"
      fi

      echo "✅ Worktree '$branch' removed."
      ;;
    *)
      echo "❌ Unknown command: $cmd"
      echo "Usage: wt <add|remove> <branch>"
      return 1
      ;;
  esac
}

_wt_autocomplete() {
  local words cword
  words=("${(z)BUFFER}")
  cword=$((CURRENT - 1))

  local commands=("add" "remove")
  local branches worktrees

  if (( cword == 1 )); then
    compadd "${commands[@]}"
    return
  fi

  if (( cword == 2 )); then
    case "${words[2]}" in
      add)
        # List git branches for adding a worktree
        branches=($(git branch --all --format='%(refname:short)'))
        compadd "${branches[@]}"
        ;;
      remove)
        # List existing worktrees for removal
        worktrees=($(git worktree list --porcelain | grep "worktree " | awk '{print $2}'))
        compadd "${worktrees[@]}"
        ;;
    esac
    return
  fi
}

# Register the completion for your command (replace `wt` with your actual command)
compdef _wt_autocomplete wt

compdef _wt_autocomplete wt
