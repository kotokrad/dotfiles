{ lib, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # font = lib.mkForce "FantasqueSansM Nerd Font:size=10:antialias=true:autohint=true";
        font = lib.mkForce "Iosevka Nerd Font Mono:size=9.5:antialias=true:autohint=true";
        selection-target = "clipboard";
      };
      environment = {
        TIMG_PIXELATION = "sixel";
      };
      scrollback.lines = 999999;
      key-bindings.clipboard-copy = "XF86Copy";
      key-bindings.clipboard-paste = "Mod4+v XF86Paste";
      text-bindings."\\x1b[99;9u" = "Mod4+c";
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
