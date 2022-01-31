{ config, pkgs, ... }:


let
  # workaround to open a URL in a new tab in the specific firefox profile
  # work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
  # Applications
    firefox
    wezterm
    tdesktop             # telegram messaging client
    transmission-gtk
    vlc                  # media player
    simplescreenrecorder
    arandr               # simple GUI for xrandr
    asciinema            # record the terminal
    insomnia             # rest client with graphql support
    # feh
    # pcmanfm
    simplescreenrecorder
    lxappearance
    mate.mate-calc
    gnome.file-roller
    # mate.engrampa
    neuron-notes

  # Utility
    fd                   # "find" for files
    silver-searcher
    ripgrep              # fast grep
    # gnomecast            # chromecast local files
    killall              # kill processes by name
    libnotify            # notify-send command
    betterlockscreen
    ncdu                 # disk space info (a better du)
    neofetch             # command-line system information
    scrot
    nyancat              # the famous rainbow cat!
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pulsemixer           # pulseaudio mixer
    tldr                 # summary of a man page
    tree                 # display files in a tree view
    maim                        # screenshot tool
    unzip
    wget
    xclip                # clipboard support (also for neovim)
    nmap
    vulkan-tools
    recoll
    yt-dlp
    docker-compose       # docker manager

  # TEMP
  # needed for course homework
  # https://www.coursera.org/learn/programming-languages
    ruby_2_6
    rubyPackages.solargraph

  # Nix
    any-nix-shell        # fish support for nix shell
    cachix               # nix caching
    nix-doc              # nix documentation search tool
    nix-index            # files database for nixpkgs
    rnix-lsp             # nix lsp server

  # Dev
    gcc
    openssl
    pkgconfig
    tree-sitter
    racket
    rustup
    fennel               # Fennel lang (for neovim config)
    janet
    clojure-lsp
    nodejs
    yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    deno
    haskellPackages.haskell-language-server
    pgweb                # PostgreSQL client

    # other haskell packages:
    # brittany             # code formatter
    # cabal2nix            # convert cabal projects to nix
    # cabal-install        # package manager
    # ghc                  # compiler
    # hoogle               # documentation
    # nix-tree             # visualize nix dependencies

  # Misc
    gnome3.adwaita-icon-theme
    # audacious            # simple music player
    # bitwarden-cli        # command-line client for the password manager
    # bottom               # alternative to htop & ytop
    # calibre              # e-book reader
    # dconf2nix            # dconf (gnome) files to nix converter
    # discord              # chat client for dev stuff
    # dmenu                # application launcher
    # dive                 # explore docker layers
    # duf                  # disk usage/free utility
    # element-desktop      # a feature-rich client for Matrix.org
    # exa                  # a better `ls`
    # gimp                 # gnu image manipulation program
    # hyperfine            # command-line benchmarking tool
    # libreoffice          # office suite
    # ngrok-2              # secure tunneling to localhost
    # nixos-generators     # nix tool to generate isos
    # manix                # documentation searcher for nix
    # pgcli                # modern postgres client
    # playerctl            # music player controller
    # prettyping           # a nicer ping
    # slack                # messaging client
    # spotify              # music source
    # terminator           # great terminal multiplexer
    # tex2nix              # texlive expressions for documents
    # yad                  # yet another dialog - fork of zenity

    # fixes the `ar` error required by cabal
    # binutils-unwrapped
  ];

  xfcePkgs = with pkgs.xfce; [
    thunar
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
    mousepad
    ristretto
    xfce4-taskmanager
  ];

  fontPkgs = with pkgs; [
    font-awesome-ttf      # awesome fonts
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

  scripts = [
    (import ./config/scripts/remaps.nix)
  ];

in
{

  programs.home-manager.enable = true;

  imports = [
    ./config/dunst
    ./config/picom
    ./config/rofi
    ./config/xmonad
    ./config/neovim
    ./config/qutebrowser
    ./config/mpv
  ];

  home = {
    username = "kotokrad";
    homeDirectory = "/home/kotokrad";
    packages = defaultPkgs ++ xfcePkgs ++ fontPkgs ++ xmonadPkgs;
  };

  programs = {
    zsh.enable = true;
    zsh.initExtra = ''
      export PATH="$PATH":"$HOME/.npm-packages/bin"
      export JANET_PATH="$HOME/.janet"
      export KEYTIMEOUT=1
      any-nix-shell zsh --info-right | source /dev/stdin
      bindkey -v
      bindkey '^R' history-incremental-search-backward
      bindkey '^[[7~' beginning-of-line
      bindkey '^[[8~' end-of-line
    '';
    zsh.enableSyntaxHighlighting = true;
    zsh.defaultKeymap = "viins";
    zsh.shellAliases = {
      gs = "git status";
      ww = "vim -c VimwikiIndex";
      jr = ''janet -e "(import spork/netrepl) (netrepl/server)"'';
      # dump keystrokes https://web.archive.org/web/20191220190018/https://www.drbunsen.org/vim-croquet/
      vim = ''nvim -w ~/.vimlog "$@"'';
    };

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
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "gruvbox-dark-gtk";
      package = pkgs.gruvbox-dark-gtk;
    };

  };

  services.network-manager-applet.enable = true;
  services.udiskie.enable = true;
  services.unclutter.enable = true;


  xdg.configFile."wezterm/".source = ./config/wezterm;
  home.file.".local/bin".source = ./config/scripts;
  # home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";


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
