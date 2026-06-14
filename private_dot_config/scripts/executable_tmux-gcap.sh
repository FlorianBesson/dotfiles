#!/usr/bin/env bash

set -uo pipefail

repo_path="${1:-}"
commit_message="${2:-}"

pause_on_error() {
  printf '\nAppuie sur Entrée pour fermer...'
  read -r _
}

if [ -z "$repo_path" ] || [ -z "$commit_message" ]; then
  echo "usage: tmux-gcap.sh <repo-path> <commit-message>"
  pause_on_error
  exit 1
fi

if ! cd "$repo_path"; then
  echo "Impossible d'ouvrir: $repo_path"
  pause_on_error
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Ce dossier n'est pas un repo git: $repo_path"
  pause_on_error
  exit 1
fi

if ! git add -A; then
  echo "git add -A a echoue"
  pause_on_error
  exit 1
fi

if ! git commit -m "$commit_message"; then
  echo "git commit a echoue"
  pause_on_error
  exit 1
fi

if ! git push; then
  echo "git push a echoue"
  pause_on_error
  exit 1
fi
