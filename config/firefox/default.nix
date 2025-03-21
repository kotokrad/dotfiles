{ pkgs, ... }:

let
  librewolf = pkgs.librewolf.overrideAttrs (finalAttrs: previousAttrs: {
    desktopItem = previousAttrs.desktopItem.override { desktopName = "Firefox"; };
  });
  firefox-work = pkgs.firefox.overrideAttrs (finalAttrs: previousAttrs: {
    desktopItem = previousAttrs.desktopItem.override { desktopName = "Firefox Work"; };
  });
  userChrome = builtins.readFile ./userChrome.css;
in
{
  programs.firefox = {
    enable = true;
    package = firefox-work;
    profiles.default.userChrome = userChrome;
  };

  programs.librewolf = {
    enable = true;
    package = librewolf;
    profiles.default.userChrome = userChrome;
  };

  home.packages = [ librewolf ];

  xdg.desktopEntries = {
    librewolf-private = {
      name = "Firefox Private";
      genericName = "Web Browser";
      exec = "librewolf --private-window %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };

  # Open links in private window by default
  xdg.mimeApps.defaultApplications =
    let
      privateBrowser = "librewolf-private.desktop";
      mimeTypes = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/chrome"
        "x-scheme-handler/unknown"
        "application/pdf"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/xhtml+xml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
      ];
    in
    builtins.foldl' (acc: mime: acc // { "${mime}" = privateBrowser; }) { } mimeTypes;
}
