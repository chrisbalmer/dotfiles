#!/bin/bash

if [ ! -f "~/.zshrc" ]; then
  mv ~/.zshrc ~/.zshrc.old
fi
ln -s $(pwd)/.zshrc ~/.zshrc

if [ ! -f "~/.config/starship.toml" ]; then
  mv ~/.config/starship.toml ~/.config/starship.toml.old
fi
ln -s $(pwd)/.config/starship.toml ~/.config/starship.toml
