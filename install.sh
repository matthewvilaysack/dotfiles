#!/usr/bin/env bash
# Symlink dotfiles in this repo into $HOME. Idempotent.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$repo/$1" dst="$HOME/$2"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%s)"
    echo "backed up existing $dst"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

link zshrc    .zshrc
link zprofile .zprofile

echo
echo "done. open a new shell to pick up changes."
