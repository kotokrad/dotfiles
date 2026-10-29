{ pkgs, ... }:

let
  settings = import ./settings.nix;
in
{
  programs.qutebrowser = {
    enable = true;

    loadAutoconfig = true;

    aliases = {
      ytdl = ''spawn -v -m sh -c 'cd ~/video/youtube && yt-dlp \"$@\"' _ {url}'';
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

    settings = settings;

    extraConfig = ''
      c.content.headers.custom = {"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
    '';

  };
}
