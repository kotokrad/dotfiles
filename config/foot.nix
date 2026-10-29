{ lib, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # font = lib.mkForce "FantasqueSansM Nerd Font:size=10:antialias=true:autohint=true";
        font = lib.mkForce "Iosevka Nerd Font Mono:size=10:antialias=true:autohint=true";
        selection-target = "clipboard";
      };
      environment = {
        TIMG_PIXELATION = "sixel";
      };
      scrollback.lines = 999999;
      url = {
        launch = "xdg-open \${url}";
        osc8-underline = "url-mode";
        regex = ''
          (([a-z][[:alnum:]-]+:(/{1,3}|[a-z0-9%])|www[:digit:]{0,3}[.])([^[:space:](){}<>]+|\(([^[:space:](){}<>]+|(\([^[:space:](){}<>]+\)))*\)|\[([^]\[[:space:](){}<>]+|(\[[^]\[[:space:](){}<>]+\]))*\])+(\(([^[:space:](){}<>]+|(\([^[:space:](){}<>]+\)))*\)|\[([^]\[[:space:](){}<>]+|(\[[^]\[[:space:](){}<>]+\]))*\]|[^]\[[:space:]`!(){};:'".,<>?«»“”‘’]))
        '';

      };
    };
  };
}
