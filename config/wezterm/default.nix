{ pkgs, ... }:

{
  programs.wezterm.enable = true;

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  # xdg.configFile = {
  #   "nvim/queries".source = ./queries;
  #   "nvim/fnl".source = ./fnl;
  #   "nvim/fnl".onChange = ''
  #     rm -rf /home/kotokrad/.config/nvim/lua
  #     ${pkgs.neovim}/bin/nvim --headless -c "lua require(\"aniseed.env\").init()" -c "q"
  #   '';
  #   # "nvim/ftplugin".source = ./ftplugin;
  # };
}
