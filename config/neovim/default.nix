{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable       = true;
    vimAlias     = true;
    vimdiffAlias = true;
    withNodeJs   = true;
    withPython3  = true;
    withRuby     = true;
    extraLuaPackages = ps: [ ps.jsregexp ]; # used in `luasnip` snippets
  };

  home.packages = with pkgs; [
    glib # nvim-tree uses `gio trash`
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
