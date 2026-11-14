# Standalone home-manager for the macbook (Fedora Asahi Remix):
#   nix run home-manager -- switch --flake ~/nixos-config#macbook
#
# TODO on Fedora (system side, outside home-manager):
#   sudo dnf install
#     gcc make                          # nvim-treesitter parsers, blink.cmp build, rust/cgo linking
#     tcpdump nmap                      # used with sudo, which doesn't search ~/.nix-profile
#     android-tools                     # ships the udev rules adb needs
#     gnome-disk-utility                # talks to Fedora's udisks + polkit
#     brightnessctl                     # quickshell brightness OSD
#     thunar gvfs tumbler               # Super+E; a Nix Thunar can't load Fedora's gvfs (trash, MTP)
#     thunar-archive-plugin file-roller # Thunar's Extract here / Create archive
#     mate-polkit                       # polkit agent (needs a setuid helper), start
#                                       #   /usr/libexec/polkit-mate-authentication-agent-1 with the session
#     gnome-keyring                     # unlocked at login through PAM
#     hyprlock                          # PAM again; its config comes from here
#     xdg-desktop-portal-wlr xdg-desktop-portal-gtk
#     fish && chsh -s /usr/bin/fish
#   mullvad-vpn, tailscale from their repos            # quickshell VPN widget
#   sudo usermod -aG dialout $USER                     # serial ports: tio, arduino-cli
#   /usr/share/wayland-sessions/mango.desktop          # Exec=/home/kotokrad/.nix-profile/bin/mango
#   after the first switch: run the `sudo ...` GPU setup command it prints
#   copy ~/.config/gammastep/config.ini, wallpaper + hyprlock avatar under ~/pictures
{ config, pkgs, ... }:

let
  packages = with pkgs; [
  # Applications
    telegram-desktop
    transmission_4-gtk
    vlc
    mate-calc
    mousepad
    imv                         # image viewer

  # Utility
    ripgrep
    libnotify                   # notify-send command
    ncdu                        # disk space info (a better du)
    fastfetch                   # command-line system information
    nyancat                     # the famous rainbow cat!
    tealdeer                    # (tldr) summary of a man page
    jq
    ffmpeg

  # Dev
    anyzig
    zls
    rustup
    go
    pgweb

  # Embedded
    arduino-cli
    gcc-arm-embedded
    tio

  # Desktop
    playerctl                   # media keys, quickshell
    pavucontrol                 # Super+M, quickshell
    networkmanagerapplet        # nm-connection-editor for the network menu
    nerd-fonts.iosevka          # foot
    nerd-fonts.jetbrains-mono   # rofi, quickshell
    papirus-icon-theme          # rofi, quickshell tray
];
in
{
  imports = [
    ./stylix.nix
    ./config/stylix.nix
    ./config/scripts
    ./config/fish.nix
    ./config/git.nix
    ./config/gammastep.nix
    ./config/foot.nix
    ./config/mpv.nix
    ./config/firefox
    ./config/rofi
    ./config/neovim
    ./config/tmux
    ./config/mangowm
    ./config/quickshell
  ];

  home = {
    username = "kotokrad";
    homeDirectory = "/home/kotokrad";
    stateVersion = "26.11";
    packages = packages;
    shellAliases.nix-switch = "home-manager switch --flake '/home/kotokrad/nixos-config#macbook'";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # Non-NixOS: Nix-built Mesa in /run/opengl-driver (activation prints the one-time
  # sudo command), XDG_DATA_DIRS, locales
  targets.genericLinux.enable = true;

  # A Nix-built hyprlock can't authenticate through Fedora's PAM; hyprlock comes from dnf,
  # its config still comes from here
  programs.hyprlock.package = null;

  # Fedora's xdg-desktop-portal doesn't look in the Nix profile
  xdg.configFile."xdg-desktop-portal/mango-portals.conf".source =
    "${config.wayland.windowManager.mango.package}/share/xdg-desktop-portal/mango-portals.conf";

  services.playerctld.enable = true;

  services.udiskie = {
    enable = true;
    automount = false;
  };

  xdg.userDirs = {
    enable = true;
    desktop     = "$HOME/desktop";
    documents   = "$HOME/documents";
    pictures    = "$HOME/pictures";
    music       = "$HOME/music";
    videos      = "$HOME/video";
    download    = "$HOME/downloads";
    publicShare = "$HOME/public";
    setSessionVariables = false;
  };
}
