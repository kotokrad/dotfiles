{ pkgs, config, inputs, ... }:


let
  defaultPkgs = with pkgs; [
  # Applications
    telegram-desktop
    transmission_4-gtk
    vlc
    mate-calc
    mousepad
    ristretto
    xfce4-taskmanager
    file-roller
    ranger
    zoom-us
    # slack
    # inkscape
    libreoffice
    foliate
    imagemagick
    wireshark
    qFlipper
    font-manager
    # mypaint
    filezilla
    prusa-slicer
    rpi-imager
    openscad-unstable
    mullvad-vpn
    pika-backup
    audacious                 # simple music player
    vesktop                   # discord
    gimp                      # gnu image manipulation program
    # blender
    # krita                     # photoshop
    kicad
    # gearlever                 # manage AppImages
    yazi
    pixelorama
    whatsie
    ghidra
    slack
    # naps2                     # FIXME: broken - scan documents to PDF
    simple-scan

  # Utility
    networkmanagerapplet        # nm-connection-editor for Quickshell's network menu (the nm-applet service doesn't put it on PATH)
    inetutils
    usbutils
    fd                          # "find" for files
    # silver-searcher
    ripgrep                     # fast grep
    # gnomecast                   # chromecast local files
    # catt                        # cast all the things
    killall                     # kill processes by name
    libnotify                   # notify-send command
    ncdu                        # disk space info (a better du)
    fastfetch                   # command-line system information
    nyancat                     # the famous rainbow cat!
    pavucontrol                 # pulseaudio volume control
    paprefs                     # pulseaudio preferences
    pasystray                   # pulseaudio systray
    pulsemixer                  # pulseaudio mixer
    alsa-utils                  # amixer etc
    tealdeer                    # (tldr) summary of a man page
    tree                        # display files in a tree view
    unzip
    wget
    nmap
    tcpdump
    vulkan-tools
    yt-dlp
    ps_mem                      # accurately report the in core memory usage for a program
    jq
    fzy                         # a better fuzzy finder
    rlwrap
    powertop                    # power comsumption
    ryzenadj                    # adjust power management settings
    ffmpeg
    lsof
    bash
    gnome-disk-utility
    gping
    file
    # ventoy                      # make bootable dvd-usb
    bind
    picocom
    minicom
    normcap                     # screen OCR
    burpsuite
    aria2
    radare2
    xxd
    cloc
    cloudflared
    bubblewrap
    socat
    pandoc
    xpdf
    gh
    sshpass

  # iOS
    # libimobiledevice
    # libplist
    # ifuse
    # ios-webkit-debug-proxy

  # Games
    # airshipper                  # Veloren
    # alsa-lib                    # for Veloren
    playonlinux
    (lutris.override {
      extraPkgs = pkgs: [
        wineWow64Packages.staging
        winetricks
      ];
    })
    protonup-ng

  # TEMP
  # programming languages course homework
  # https://www.coursera.org/learn/programming-languages
  # ---
  # 7 languages in 7 weeks book
    # ruby_2_6
    # ruby
    # rubyPackages.solargraph

  # Nix
    cachix                      # nix caching
    nix-doc                     # nix documentation search tool
    nix-tree                    # visualize nix dependencies

  # Dev
    devenv
    httpie
    gnumake
    gcc
    openssl
    pkg-config
    jadx
    python3
    rustup
    go
    lua
    pgweb                       # PostgreSQL client
    beamPackages.elixir
    elixir-ls
    anyzig
    zls
    # tree-sitter
    # godot3
    # godot_4

  # Embedded
    arduino
    gcc-arm-embedded
    tio
    nrfutil
    nrf-udev

  # node:
    nodejs
    yarn
    # nodePackages.typescript
    # nodePackages.typescript-language-server
    # nodePackages.prettier
    deno
    bun

  # Misc
    adwaita-icon-theme

  # QMK
    # qmk
    # qmk-udev-rules
    # vial
  ];

  fontPkgs = with pkgs; [
    font-awesome          # awesome fonts
    material-design-icons # fonts with glyphs
    open-sans
    vista-fonts           # consolas
  ];

in
{

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [];
  nixpkgs.config.segger-jlink.acceptLicense = true; # nrfutil

  imports = [
    ./config/scripts
    ./config/fish.nix
    ./config/git.nix
    ./config/gammastep.nix
    ./config/stylix.nix
    ./config/foot.nix
    ./config/mpv.nix
    ./config/firefox
    ./config/zen
    ./config/rofi
    ./config/neovim
    ./config/qutebrowser
    ./config/tmux
    ./config/mangowm
    ./config/quickshell
  ];

  home = {
    username = "kotokrad";
    homeDirectory = "/home/kotokrad";
    packages = defaultPkgs ++ fontPkgs;
    sessionPath = [
      "$HOME/.npm-packages/bin"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
      "$HOME/.bun/bin"
    ];
    # docker-compose talks to rootless podman (its user socket is on by default)
    sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    shellAliases.nix-switch = "sudo nixos-rebuild switch --flake '/home/kotokrad/nixos-config#'"; # rest in config/fish.nix
  };

  programs = {
    brave = {
      enable = true;
      commandLineArgs = [ "--password-store=gnome-libsecret" ];
    };

    uv.enable = true;

    # Fix colors on the Xiaomi projector (desktop only: it's an amdgpu problem)
    # amdgpu sends full-range RGB, projector's EDID can't signal range so it assumes 16-235
    mpv.profiles.projector = {
      profile-cond = "display_names and display_names[1] and io.open('/sys/class/drm/card1-' .. display_names[1] .. '/edid'):read('*a'):find('MJJGYY01FM', 1, true)";
      profile-restore = "copy";
      video-output-levels = "limited";
    };
  };

  fonts.fontconfig.enable = true;

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

  services.network-manager-applet.enable = true;
  # services.syncthing.enable = false;
  # services.syncthing.tray.enable = true;
  services.tailscale-systray = {
    enable = true;
    theme = "dark:nobg";
  };
  services.hyprpolkitagent.enable = true;
  # services.opensnitch-ui.enable = true;
  # services.kdeconnect = {
  #   enable = true;
  #   indicator = true;
  # };

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

  # xdg.mimeApps = {
  #   enable = true;
  #   defaultApplications = {
  #     "text/plain" = "org.xfce.mousepad.desktop";
  #     "image/jpeg" = "org.xfce.ristretto.desktop";
  #     "image/png" = "org.xfce.ristretto.desktop";
  #     "image/svg+xml" = ["org.inkscape.Inkscape.desktop" "org.qutebrowser.qutebrowser.desktop"];
  #     "x-scheme-handler/tg" = "telegramdesktop.desktop";
  #     "x-scheme-handler/magnet" = "transmission-gtk.desktop";
  #   };
  #   associations.added = {
  #     "video/mp4" = "vlc.desktop";
  #     "video/webm" = "vlc.desktop";
  #     "image/svg+xml" = "org.xfce.mousepad.desktop";
  #   };
  # };
  # xdg.configFile."mimeapps.list".force = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
