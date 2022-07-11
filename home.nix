{ config, pkgs, ... }:


let
  defaultPkgs = with pkgs; [
  # Applications
    chromium
    wezterm
    tdesktop                    # telegram messaging client
    transmission-gtk
    vlc                         # media player
    simplescreenrecorder
    arandr                      # simple GUI for xrandr
    asciinema                   # record the terminal
    # insomnia                    # rest client with graphql support
    postman                     # rest client
    # pcmanfm
    simplescreenrecorder
    lxappearance
    mate.mate-calc
    gnome.file-roller
    # mate.engrampa
    # neuron-notes
    ranger
    zoom-us
    discord
    inkscape
    slack
    libreoffice-fresh
    fbreader
    imagemagick
    wireshark
    opensnitch-ui
    obsidian

  # Utility
    fd                          # "find" for files
    silver-searcher
    ripgrep                     # fast grep
    # gnomecast                   # chromecast local files
    killall                     # kill processes by name
    libnotify                   # notify-send command
    # betterlockscreen
    xtrlock-pam                 # PAM based X11 screen locker
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
    trash-cli

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
    rnix-lsp                    # nix lsp
    # nix-tree                    # visualize nix dependencies

  # Dev
    gnumake
    # gcc
    binutils-unwrapped          # NOTE: fixes the `ar` error required by cabal
    openssl
    pkgconfig
    tree-sitter
    python3
    rustup
    pgweb                       # PostgreSQL client
    elixir
    elixir_ls

  # node:
    nodejs
    yarn
    # nodePackages.typescript                 # NOTE: v4.4.4 installed globally for now.
    # nodePackages.typescript-language-server # NOTE: v0.8.1 installed globally for now
    nodePackages.prettier
    deno                        # deno lsp; used as prettier alternative

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
    gnome3.adwaita-icon-theme
    qmk-udev-rules              # for QMK flashing
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
    # gimp                      # gnu image manipulation program
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
  ];

  xmonadPkgs = with pkgs; [
    # networkmanager_dmenu   # networkmanager on dmenu
    # networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
    xorg.xev
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
      switch = "sudo nixos-rebuild switch --flake '/home/kotokrad/nixos-config#'";
      gs = "git status";
      gh = "git hist";
      ww = "vim -c VimwikiIndex";
      lofi = "mpv --no-video --volume=50 https://youtu.be/5qap5aO4i9A";
      # dump keystrokes https://web.archive.org/web/20191220190018/https://www.drbunsen.org/vim-croquet/
      vim = ''nvim -w ~/.vimlog "$@"'';
      ssh = ''TERM=xterm-256color ssh'';
      mkdir = "mkdir -p";
    };
  };

  programs = {
    zsh.enable = true;
    zsh.initExtra = ''
      any-nix-shell zsh --info-right | source /dev/stdin
      bindkey -v
      bindkey '^R' history-incremental-search-backward
      bindkey '^[[7~' beginning-of-line
      bindkey '^[[8~' end-of-line
      eval "$RUN"
    '';
    zsh.enableSyntaxHighlighting = true;
    zsh.defaultKeymap = "viins";

    git.enable = true;
    git.aliases = {
      hist = "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short";
    };

    fzf = {
      enable = true;
      enableZshIntegration = false;
      defaultCommand = ''
        ag --follow -g \"\"
      '';
    };

    starship = {
      enable = true;

      settings = {
        character = {
          success_symbol = "[λ](bold green)";
          error_symbol = "[λ](bold red)";
          vicmd_symbol = "[λ](bold yellow)";
        };
      };
    };

    vscode.enable = true;
    vscode.package = pkgs.vscode-fhs;

    bat.enable = true;
    bat.config.theme = "gruvbox-dark";

    lazygit.enable = true;
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
  services.udiskie.enable = true;
  services.udiskie.automount = false;
  services.unclutter.enable = true;
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
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
        command = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
      }
      {
        delay = 300;
        command = "systemctl suspend";
      }
    ];
  };

  xdg.configFile."wezterm/".source = ./config/wezterm;
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
      "x-scheme-handler/tg" = "telegramdesktop.desktop";
      "x-scheme-handler/magnet" = "transmission-gtk.desktop";
      "x-scheme-handler/postman" = "Postman.desktop";
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
