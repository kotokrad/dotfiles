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
    vesktop                   # discord
    gimp                      # gnu image manipulation program
    blender
    # krita                   # photoshop
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
    # scrot                       # screenshot tool
    # maim                        # screenshot tool
    nyancat                     # the famous rainbow cat!
    pavucontrol                 # pulseaudio volume control
    paprefs                     # pulseaudio preferences
    pasystray                   # pulseaudio systray
    pulsemixer                  # pulseaudio mixer
    alsa-utils                   # amixer etc
    tealdeer                    # (tldr) summary of a man page
    tree                        # display files in a tree view
    unzip
    wget
    nmap
    tcpdump
    vulkan-tools
    yt-dlp
    # docker-compose              # docker manager
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
    any-nix-shell               # fish support for nix shell
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
    audacious                 # simple music player

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
    ];
    # docker-compose talks to rootless podman (its user socket is on by default)
    sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake '/home/kotokrad/nixos-config#'";
      gs = "git status";
      gh = "git hist";
      lofi = "mpv --no-video --volume=50 https://youtu.be/jfKfPfyJRdk";
      sync-watch = "watch -d grep -e Dirty: -e Writeback: /proc/meminfo";
      # dump keystrokes https://web.archive.org/web/20191220190018/https://www.drbunsen.org/vim-croquet/
      # vim = ''nvim -w ~/.vimlog "$argv"'';
      ssh = ''TERM=xterm-256color ${pkgs.openssh}/bin/ssh'';
      mkdir = "mkdir -p";
    };
  };

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        any-nix-shell fish --info-right | source
        set -U fish_greeting ""
        set -g fish_transient_prompt 1
      '';
      generateCompletions = false;
    };

    git = {
      enable = true;
      settings.alias = {
        hist = "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short";
      };
      lfs.enable = true;
      lfs.skipSmudge = true;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options.syntax-theme = "gruvbox-dark";
    };
    lazygit = {
      enable = true;
      settings.git.diffRenderers = [{
        command ="${pkgs.delta}/bin/delta --dark --paging=never";
        colorArg = "always";
      }];
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f --follow";
    };

    # vscode.enable = true;
    # vscode.package = pkgs.vscode-fhs;

    # Chromium only uses the keyring on desktops it recognizes; under mango it falls
    # back to the plain-text "basic" store unless told otherwise
    chromium = {
      enable = true;
      commandLineArgs = [ "--password-store=gnome-libsecret" ];
    };
    brave = {
      enable = true;
      commandLineArgs = [ "--password-store=gnome-libsecret" ];
    };

    bat.enable = true;
    uv.enable = true;
  };

  xdg.configFile."fish/functions/fish_prompt.fish".source = ./config/fish_prompt.fish;

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
  services.trayscale.enable = true;
  services.hyprpolkitagent.enable = true;
  # services.opensnitch-ui.enable = true;
  # services.kdeconnect = {
  #   enable = true;
  #   indicator = true;
  # };

  systemd.user.services.gammastep = {
    Unit = {
      Description = "Gammastep colour temperature adjuster";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.gammastep}/bin/gammastep -c %h/.config/gammastep/config.ini";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

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
