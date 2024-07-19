#!/bin/bash

if [ ! -f "~/.zshrc" ]; then
  mv ~/.zshrc ~/.zshrc.old
fi
ln -s .zshrc ~/.zshrc

if [ ! -f "~/.config/starship.toml" ]; then
  mv ~/.config/starship.toml ~/.config/starship.toml.old
fi
ln -s .config/starship.toml ~/.config/starship.toml
