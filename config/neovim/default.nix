{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable       = true;
    vimAlias     = true;
    vimdiffAlias = true;
    withNodeJs   = false;
    withPython3  = false;
    withRuby     = false;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    tree-sitter # nvim-treesitter (main) builds parsers with it
  ];

  # Remove old nvim config before HM checks for conflicts
  home.activation.neovimConfigPre = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    run rm -rf $HOME/.config/nvim
  '';

  # Replace HM-generated nvim config with our symlink
  home.activation.neovimConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -rf $HOME/.config/nvim
    run ln -sf $HOME/nixos-config/config/neovim/dotfiles $HOME/.config/nvim
  '';
}
