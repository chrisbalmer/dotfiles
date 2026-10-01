#!/usr/bin/env bash
# Write ~/.zshrc.local from its master copy, a 1Password Document, so every Mac
# gets the same machine-specific settings. Prints a diff when the file changes.
#
#   ZSHRC_LOCAL_DOCUMENT  Document title (default: zshrc.local)
#   ZSHRC_LOCAL_VAULT     Vault (default: Private)
set -euo pipefail

doc=${ZSHRC_LOCAL_DOCUMENT:-zshrc.local}
vault=${ZSHRC_LOCAL_VAULT:-Private}
dst="$HOME/.zshrc.local"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

op document get "$doc" --vault "$vault" --out-file "$tmp" --force >/dev/null

if [ -f "$dst" ] && cmp -s "$tmp" "$dst"; then
  echo "~/.zshrc.local is up to date."
  exit 0
fi
if [ -f "$dst" ]; then
  diff -u "$dst" "$tmp" || true
fi
install -m 600 "$tmp" "$dst"
echo "Updated ~/.zshrc.local; open a new shell to load it."
