{ config, pkgs, ... }:


let
  xtrlock-pam-python3 = pkgs.xtrlock-pam.overrideAttrs (
    old: {
      buildInputs = with pkgs; [ python39 pam xorg.libX11 ];
    }
  );
  defaultPkgs = with pkgs; [
  # Applications
    chromium
    brave
    tdesktop                    # telegram messaging client
    transmission-gtk
    vlc                         # media player
    simplescreenrecorder
    arandr                      # simple GUI for xrandr
    asciinema                   # record the terminal
    simplescreenrecorder
    lxappearance
    mate.mate-calc
    gnome.file-roller
    ranger
    zoom-us
    discord
    inkscape
    slack
    libreoffice-fresh
    foliate                     # e-book reader
    imagemagick
    wireshark
    # opensnitch-ui
    obsidian
    font-manager
    prusa-slicer
    orca-slicer
    arduino
    openscad-unstable
    upscayl
    mullvad-vpn
    rpi-imager

  # Games
    # cemu
    playonlinux
    wineWowPackages.staging
    winetricks

  # Utility
    fd                          # "find" for files
    silver-searcher
    ripgrep                     # fast grep
    # gnomecast                   # chromecast local files
    killall                     # kill processes by name
    libnotify                   # notify-send command
    xtrlock-pam-python3         # PAM based X11 screen locker
    ncdu                        # disk space info (a better du)
    neofetch                    # command-line system information
    scrot                       # screenshot tool
    maim                        # screenshot tool
    nyancat                     # the famous rainbow cat!
    pavucontrol                 # pulseaudio volume control
    paprefs                     # pulseaudio preferences
    pasystray                   # pulseaudio systray
    pulsemixer                  # pulseaudio mixer
    tealdeer                    # (tldr) summary of a man page
    tree                        # display files in a tree view
    unzip
    wget
    xclip                       # clipboard support (also for neovim)
    nmap
    vulkan-tools
    yt-dlp
    docker-compose              # docker manager
    ps_mem                      # accurately report the in core memory usage for a program
    jq
    fzy                         # a better fuzzy finder
    rlwrap
    powertop                    # power comsumption
    ryzenadj                    # adjust power management settings
    xdotool
    ffmpeg
    xcolor                      # color picker
    lsof
    bash
    gnome.gnome-disk-utility
    gping
    file
    ventoy                      # make bootable dvd-usb
    xsel
    bind

  # TEMP
  # programming languages course homework
  # https://www.coursera.org/learn/programming-languages
  # ---
  # 7 languages in 7 weeks book
    # ruby_2_6
    ruby
    rubyPackages.solargraph
    io

  # Nix
    any-nix-shell               # fish support for nix shell
    cachix                      # nix caching
    nix-doc                     # nix documentation search tool
    nix-index                   # files database for nixpkgs
    # nix-tree                    # visualize nix dependencies

  # Dev
    gnumake
    gcc
    # binutils-unwrapped          # NOTE: fixes the `ar` error required by cabal
    openssl
    pkg-config
    tree-sitter
    python3
    # python310Packages.pip
    rustup
    pgweb                       # PostgreSQL client
    elixir
    elixir_ls
    godot3
    # godot_4
    pixelorama

  # node:
    nodejs
    yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    deno
    bun

  # lisp:
    racket
    fennel                      # fennel lang (for neovim config)
    # janet
    clojure-lsp
    babashka

  # haskell:
    ghc                         # compiler
    cabal-install               # package manager
    haskellPackages.haskell-language-server
    cabal2nix                   # convert cabal projects to nix
    # brittany                    # code formatter
    # hoogle                      # documentation

  # Misc
    gnome.adwaita-icon-theme
    qmk-udev-rules              # for QMK flashing
    libusb1
    # audacious                 # simple music player
    # bottom                    # alternative to htop & ytop
    # calibre                   # e-book reader
    # dconf2nix                 # dconf (gnome) files to nix converter
    # discord                   # chat client for dev stuff
    # dmenu                     # application launcher
    # dive                      # explore docker layers
    # duf                       # disk usage/free utility
    # element-desktop           # a feature-rich client for Matrix.org
    # exa                       # a better `ls`
    gimp                      # gnu image manipulation program
    # hyperfine                 # command-line benchmarking tool
    # libreoffice               # office suite
    # ngrok-2                   # secure tunneling to localhost
    # nixos-generators          # nix tool to generate isos
    # manix                     # documentation searcher for nix
    # pgcli                     # modern postgres client
    # playerctl                 # music player controller
    # prettyping                # a nicer ping
    # slack                     # messaging client
    # spotify                   # music source
    # terminator                # great terminal multiplexer
    # tex2nix                   # texlive expressions for documents
    # yad                       # yet another dialog - fork of zenity
  ];

  xfcePkgs = with pkgs.xfce; [
    (thunar.override {
      thunarPlugins = [
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    })
    thunar-volman
    mousepad
    ristretto
    xfce4-taskmanager
    xfconf
  ];

  fontPkgs = with pkgs; [
    font-awesome          # awesome fonts
    material-design-icons # fonts with glyphs
    open-sans
    vistafonts            # consolas
  ];

  xmonadPkgs = with pkgs; [
    # networkmanager_dmenu   # networkmanager on dmenu
    networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
    xorg.xev
    gtk-engine-murrine
    gtk_engines
  ];

  overrides = with pkgs; [
    # WARNING: SECRET
    (polymc.override { msaClientID = "00000000-0000-0000-0000-000000000000"; })
  ];

  scripts = [
    (pkgs.callPackage ./config/scripts/remaps.nix { })
    (pkgs.callPackage ./config/scripts/nixconf.nix { })
  ];

in
{

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    ./config/wezterm
    ./config/firefox
    ./config/dunst
    ./config/picom
    ./config/rofi
    ./config/xmonad
    ./config/polybar
    ./config/neovim
    ./config/qutebrowser
    ./config/mpv
    ./config/lf
    ./config/autorandr
  ];

  home = {
    username = "kotokrad";
    homeDirectory = "/home/kotokrad";
    packages = defaultPkgs ++ xfcePkgs ++ fontPkgs ++ xmonadPkgs ++ scripts ++ overrides;
    keyboard.layout = "en,ru";
    keyboard.options = [
      "caps:escape"
      "grp:alt_shift_toggle"
    ];
    sessionPath = ["$HOME/.npm-packages/bin"];
    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      KEYTIMEOUT = 1;
    };
    shellAliases = {
      nix-switch = ''
        rm -f ~/.config/mimeapps.list || true
        sudo nixos-rebuild switch --flake '/home/kotokrad/nixos-config#'
        ${pkgs.neovim}/bin/nvim --headless -c "lua require(\"aniseed.env\").init()" -c q
        '';
      gs = "git status";
      gh = "git hist";
      lofi = "mpv --no-video --volume=50 https://youtu.be/jfKfPfyJRdk";
      sync-watch = "watch -d grep -e Dirty: -e Writeback: /proc/meminfo";
      # dump keystrokes https://web.archive.org/web/20191220190018/https://www.drbunsen.org/vim-croquet/
      vim = ''nvim -w ~/.vimlog "$argv"'';
      ssh = ''TERM=xterm-256color ${pkgs.openssh}/bin/ssh'';
      mkdir = "mkdir -p";
    };
  };

  programs = {
    fish.enable = true;
    fish.interactiveShellInit = ''
      any-nix-shell fish --info-right | source
      set -U fish_greeting ""
    '';

    git.enable = true;
    git.aliases = {
      hist = "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short";
    };
    git.delta.enable = true;
    git.delta.options.syntax-theme = "gruvbox-dark";
    git.lfs.enable = true;
    git.lfs.skipSmudge = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = ''
        ag --follow -g \"\"
      '';
    };

    starship = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        scan_timeout = 10;
        command_timeout = 100;
        character = {
          success_symbol = "[λ](bold green)";
          error_symbol = "[λ](bold red)";
          vicmd_symbol = "[λ](bold yellow)";
        };

        # format = ''
        #   $username$hostname$directory$git_branch$cmd_duration$line_break$character
        # '';
        directory.style = "blue";
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };
        git_state = {
          format = "\([$state( $progress_current/$progress_total)]($style)\) ";
          style = "bright-black";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
      };
    };

    # vscode.enable = true;
    # vscode.package = pkgs.vscode-fhs;

    bat.enable = true;
    bat.config.theme = "gruvbox-dark";

    lazygit.enable = true;
    lazygit.settings.git.paging = {
      colorArg = "always";
      pager = "${pkgs.delta}/bin/delta --dark --paging=never";
    };
    ncmpcpp.enable = true;
    feh.enable = true;
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-gtk;
    };

  };

  services.network-manager-applet.enable = true;
  services.unclutter.enable = true;
  services.syncthing.enable = false;
  # services.syncthing.tray.enable = true;
  services.gammastep = {
    enable = true;
    tray = true;
    provider = "geoclue2";
  };
  services.udiskie = {
    enable = true;
    automount = false;
    settings = {
      device_config = [{
        loop_file = "/media/docker-volume.img";
        ignore = true;
      }];
    };
  };
  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    not-when-fullscreen = true;
    timers = [
      # {
      #   delay = 20;
      #   command = "xrandr --output \"$(xrandr | awk '/ primary/{print $1}')\" --brightness .1";
      #   canceller = "xrandr --output \"$(xrandr | awk '/ primary/{print $1}')\" --brightness 1";
      # }
      {
        delay = 120;
        command = "${xtrlock-pam-python3}/bin/xtrlock-pam";
      }
      {
        delay = 300;
        command = "systemctl suspend";
      }
    ];
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
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "org.xfce.mousepad.desktop";
      "image/jpeg" = "org.xfce.ristretto.desktop";
      "image/png" = "org.xfce.ristretto.desktop";
      "image/svg+xml" = ["org.inkscape.Inkscape.desktop" "org.qutebrowser.qutebrowser.desktop"];
      # "font/otf" = "org.gnome.FontViewer.desktop";
      "x-scheme-handler/tg" = "telegramdesktop.desktop";
      "x-scheme-handler/magnet" = "transmission-gtk.desktop";
    };
    associations.added = {
      "video/mp4" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "image/svg+xml" = "org.xfce.mousepad.desktop";
    };
  };

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
