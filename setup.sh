#!/bin/bash
# Link these dotfiles into $HOME. Safe to re-run: Coder runs it on every
# workspace start (coder dotfiles), and it's how a Mac is set up.
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)

# link <path in this repo> <target>: keep a real file once as <target>.old,
# then point <target> at the repo copy. An existing link is just replaced.
link() {
  local src="$SCRIPT_DIR/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.old"
  fi
  ln -sfn "$src" "$dst"
}

link .zshrc "$HOME/.zshrc"
link .config/starship.toml "$HOME/.config/starship.toml"
link .config/git/config "$HOME/.config/git/config"
link .config/herdr/config.toml "$HOME/.config/herdr/config.toml"

# Refuse commits that would publish machine-specific values (hooks/pre-commit)
if [ -d "$SCRIPT_DIR/.git" ]; then
  git -C "$SCRIPT_DIR" config core.hooksPath hooks
fi

if [ "$(uname -s)" = Darwin ]; then
  link .config/1Password/ssh/agent.toml "$HOME/.config/1Password/ssh/agent.toml"

  # The 1Password SSH agent socket, at a path without spaces
  AGENT="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  mkdir -p "$HOME/.1password"
  if [ -S "$AGENT" ]; then
    ln -sfn "$AGENT" "$HOME/.1password/agent.sock"
  fi

  # Machine-specific settings, from 1Password (see README)
  if command -v op >/dev/null 2>&1; then
    "$SCRIPT_DIR/scripts/zshrc-local-sync.sh" \
      || echo "setup.sh: couldn't sync ~/.zshrc.local from 1Password; run zshrc_local_sync later"
  else
    echo "setup.sh: 1Password CLI not found; ~/.zshrc.local not synced"
  fi
fi
