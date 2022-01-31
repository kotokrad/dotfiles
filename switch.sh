#!/bin/sh

# remove compiled lua files
rm -rf ~/.config/nvim/lua
sudo nixos-rebuild switch --flake '.#'
# compile neovim config
nvim --headless -c "lua require('aniseed.env').init()" -c q
