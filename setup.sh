#!/bin/bash

if [ ! -f "~/.zshrc" ]; then
  mv ~/.zshrc ~/.zshrc.old
fi
ln -s $(dirname "$0")/.zshrc ~/.zshrc

if [ ! -f "~/.config/starship.toml" ]; then
  mv ~/.config/starship.toml ~/.config/starship.toml.old
fi
ln -s $(dirname "$0")/.config/starship.toml ~/.config/starship.toml

# Setup 1Password SSH Agent on MacOS
AGENT="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
NEW_AGENT="$HOME/.1password/agent.sock"
mkdir -p ~/.1password

if [[ -S $AGENT && ! -S $NEW_AGENT ]]; then
    ln -s $AGENT $NEW_AGENT
fi
