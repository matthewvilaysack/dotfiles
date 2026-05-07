#!/usr/bin/env bash
# Symlink dotfiles in this repo into $HOME. Idempotent.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$repo/$1" dst="$HOME/$2"
  if [[ ! -e "$src" ]]; then
    echo "skip $dst (no $src in repo yet)"
    return 0
  fi
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%s)"
    echo "backed up existing $dst"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

# Import an existing $HOME file into the repo, then symlink it back.
# Usage: ./install.sh import .p10k.zsh p10k.zsh
import() {
  local home_rel="$1" repo_rel="$2"
  local src="$HOME/$home_rel" dst="$repo/$repo_rel"
  if [[ ! -f "$src" || -L "$src" ]]; then
    echo "nothing to import: $src is missing or already a symlink"
    return 1
  fi
  if [[ -e "$dst" ]]; then
    echo "$dst already exists in repo; aborting"
    return 1
  fi
  mv "$src" "$dst"
  ln -s "$dst" "$src"
  echo "imported $src -> $dst (and re-linked)"
}

if [[ "${1:-}" == "import" ]]; then
  shift
  import "$@"
  exit $?
fi

link zshrc    .zshrc
link zprofile .zprofile
link p10k.zsh .p10k.zsh

echo
echo "done. open a new shell to pick up changes."
