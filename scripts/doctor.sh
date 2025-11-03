#!/usr/bin/env bash
set -euo pipefail

# Restore arrays from environment
eval "$BREW_PACKAGES_DEF"
eval "$BREW_CASKS_DEF"
eval "$SYMLINKS_DEF"
eval "$REPOS_DEF"

echo "🔍 Running dotfiles doctor..."
echo ""

ERRORS=0
WARNINGS=0

# Check Homebrew
echo "Checking Homebrew..."
if command -v brew &> /dev/null; then
  echo "  ✓ Homebrew installed"
else
  echo "  ✗ Homebrew not installed"
  ((ERRORS++))
fi
echo ""

# Check installed packages
echo "Checking packages..."
for pkg in "${BREW_PACKAGES[@]}"; do
  if command -v "$pkg" &> /dev/null || brew list "$pkg" &> /dev/null; then
    echo "  ✓ $pkg installed"
  else
    echo "  ✗ $pkg not installed"
    ((ERRORS++))
  fi
done

# Check casks
for cask in "${BREW_CASKS[@]}"; do
  # Check if cask is installed via brew or by looking for common app locations
  if brew list --cask "$cask" &> /dev/null; then
    echo "  ✓ $cask installed"
  elif [ "$cask" = "ghostty" ] && [ -d "/Applications/Ghostty.app" ]; then
    echo "  ✓ $cask installed"
  else
    echo "  ✗ $cask not installed"
    ((ERRORS++))
  fi
done
echo ""

# Check symlinks
echo "Checking symlinks..."
for entry in "${SYMLINKS[@]}"; do
  IFS=':' read -r target link <<< "$entry"
  if [ -L "$link" ]; then
    actual_target=$(readlink "$link")
    if [ "$actual_target" = "$target" ]; then
      echo "  ✓ $(basename "$link") -> $target"
    else
      echo "  ⚠ $(basename "$link") points to wrong target"
      echo "    Expected: $target"
      echo "    Actual: $actual_target"
      ((WARNINGS++))
    fi
  elif [ -e "$link" ]; then
    echo "  ⚠ $(basename "$link") exists but is not a symlink"
    ((WARNINGS++))
  else
    echo "  ✗ $(basename "$link") symlink missing"
    ((ERRORS++))
  fi
done
echo ""

# Check repositories
echo "Checking repositories..."
for entry in "${REPOS[@]}"; do
  # Split on pipe to separate main entry from post-action
  IFS='|' read -r main_entry post_action <<< "$entry"
  read -r type_subtype repo_url name clone_opts <<< "$main_entry"

  IFS=':' read -r type subtype <<< "$type_subtype"

  case "$type" in
    tmux)
      dest="$TMUX_HOME/$subtype/$name"
      ;;
    zsh)
      dest="$ZSH_HOME/config/$subtype/$name"
      ;;
  esac

  if [ -d "$dest/.git" ]; then
    echo "  ✓ $name cloned"
  elif [ -d "$dest" ]; then
    echo "  ⚠ $name directory exists but not a git repo"
    ((WARNINGS++))
  else
    echo "  ✗ $name not cloned"
    ((ERRORS++))
  fi
done
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo "✅ All checks passed! Your dotfiles are healthy."
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo "⚠️  $WARNINGS warning(s) found. Everything should work, but you may want to review."
  exit 0
else
  echo "❌ $ERRORS error(s) and $WARNINGS warning(s) found."
  echo ""
  echo "Run './scripts/dotfiles init' to set up your dotfiles."
  exit 1
fi
