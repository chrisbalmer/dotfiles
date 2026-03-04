#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

if [ -f "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.old"
fi
ln -s "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

if [ -f "$HOME/.config/starship.toml" ]; then
  mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.old"
fi
ln -s "$SCRIPT_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# Setup 1Password SSH Agent config
mkdir -p "$HOME/.config/1Password/ssh"
if [ -f "$HOME/.config/1Password/ssh/agent.toml" ]; then
  mv "$HOME/.config/1Password/ssh/agent.toml" "$HOME/.config/1Password/ssh/agent.toml.old"
fi
ln -s "$SCRIPT_DIR/.config/1Password/ssh/agent.toml" "$HOME/.config/1Password/ssh/agent.toml"

# Setup 1Password SSH Agent socket on MacOS
AGENT="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
NEW_AGENT="$HOME/.1password/agent.sock"
mkdir -p "$HOME/.1password"

if [[ -S "$AGENT" && ! -S "$NEW_AGENT" ]]; then
    ln -s "$AGENT" "$NEW_AGENT"
fi
