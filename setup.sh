#!/bin/bash

if [ ! -f "~/.zshrc" ]; then
  mv ~/.zshrc ~/.zshrc.old
fi
ln -s $(dirname "$0")/.zshrc ~/.zshrc

if [ ! -f "~/.config/starship.toml" ]; then
  mv ~/.config/starship.toml ~/.config/starship.toml.old
fi
ln -s $(dirname "$0")/.config/starship.toml ~/.config/starship.toml
