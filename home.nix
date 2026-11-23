{ pkgs, ... }:

{
  imports = [
    ./config/scripts
    ./config/fish.nix
    ./config/git.nix
    ./config/gammastep.nix
    ./config/stylix.nix
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
    packages = with pkgs; [
    # Applications
      brave
      telegram-desktop
      transmission_4-gtk
      vlc
      mate-calc
      mousepad
      xfce4-taskmanager
      prusa-slicer
      filezilla
      audacious
      rpi-imager

    # Utility
      ripgrep
      fd                          # "find" for files
      libnotify                   # notify-send command
      ncdu                        # disk space info (a better du)
      fastfetch                   # command-line system information
      nyancat                     # the famous rainbow cat!
      tealdeer                    # (tldr) summary of a man page
      jq
      ffmpeg
      lm_sensors
      nmap
      tcpdump
      powertop
      gh
      sshpass

    # Dev
      anyzig
      zls
      rustup
      go
      pgweb
      nodejs
      bun
      prettierd
      typescript-language-server
      emmet-ls

    # Embedded
      gcc-arm-embedded
      tio
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
    ];
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.udiskie = {
    enable = true;
    automount = false;
  };

  services.tailscale-systray = {
    enable = true;
    theme = "dark:nobg";
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
