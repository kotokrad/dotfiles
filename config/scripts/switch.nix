{ pkgs }:

with pkgs;

writeShellScriptBin "switch" ''
  # remove compiled lua files
  rm -rf ~/.config/nvim/lua
  cd ~/nixos-config
  sudo nixos-rebuild switch --flake '.#'
  # compile neovim config
  ${pkgs.neovim}/bin/nvim --headless -c "lua require('aniseed.env').init()" -c q

''
