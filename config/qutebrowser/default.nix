{ pkgs, ... }:

let
  gruvboxTheme = import ./gruvbox.nix;
  settings = import ./settings.nix;
in
{
  programs.qutebrowser = {
    enable = true;

    loadAutoconfig = true;

    aliases = {
      ytdl = ''spawn -v -m zsh -c 'cd ~/video/youtube && youtube-dl \"$@\"' _ {url}'';
    };

    keyBindings = {
      normal = {
        J = "tab-prev";
        K = "tab-next";
        ",m" = "spawn umpv {url}";
        ",M" = "hint links spawn umpv {hint-url}";
        ";M" = "hint --rapid links spawn umpv {hint-url}";
      };
    };

    settings = settings // gruvboxTheme;

    extraConfig = ''
      c.content.headers.custom = {"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
    '';

  };
}
