{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.wezterm}/bin/wezterm";
    theme = "gruvbox-dark";
    font = "FantasqueSansM Nerd Font Regular 28";
    extraConfig = {
      modi = "window,drun,run,ssh";
      sort = true;
      sorting-method = "fzf";
    };
  };
}
