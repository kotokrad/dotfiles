{ pkgs, config, inputs, ... }:


let
  defaultPkgs = with pkgs; [
  # Applications
    ristretto
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
    openscad-unstable
    mullvad-vpn
    pika-backup
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
    inetutils
    usbutils
    glib                        # `gio trash` for neo-tree
    # silver-searcher
    # gnomecast                   # chromecast local files
    # catt                        # cast all the things
    killall                     # kill processes by name
    paprefs                     # pulseaudio preferences
    pasystray                   # pulseaudio systray
    pulsemixer                  # pulseaudio mixer
    alsa-utils                  # amixer etc
    tree                        # display files in a tree view
    unzip
    wget
    vulkan-tools
    yt-dlp
    ps_mem                      # accurately report the in core memory usage for a program
    fzy                         # a better fuzzy finder
    rlwrap
    ryzenadj                    # adjust power management settings
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
    lua
    beamPackages.elixir
    elixir-ls
    # tree-sitter
    # godot3
    # godot_4

  # Embedded
    arduino
    # nrfutil
    # nrf-udev

  # node:
    yarn
    # nodePackages.typescript
    # nodePackages.typescript-language-server
    # nodePackages.prettier
    deno

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

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.segger-jlink.acceptLicense = true; # nrfutil

  imports = [
    ./home.nix
    ./config/zen
    ./config/qutebrowser
  ];

  wayland.windowManager.mango.extraConfig = ''
    monitor_rule = name:^eDP-1$,scale:2,x:560,y:1440
    monitor_rule = make:Dell Inc.,model:DELL U3223QE,scale:1.5,x:0,y:0
  '';

  home = {
    packages = defaultPkgs ++ fontPkgs;
    sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    shellAliases.nix-switch = "sudo nixos-rebuild switch --flake '/home/kotokrad/nixos-config#'";
  };

  programs = {
    uv.enable = true;

    mpv.config = {
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";
      vo = "gpu";
    };

    # Fix colors on the Xiaomi projector (desktop only: it's an amdgpu problem)
    # amdgpu sends full-range RGB, projector's EDID can't signal range so it assumes 16-235
    mpv.profiles.projector = {
      profile-cond = "display_names and display_names[1] and io.open('/sys/class/drm/card1-' .. display_names[1] .. '/edid'):read('*a'):find('MJJGYY01FM', 1, true)";
      profile-restore = "copy";
      video-output-levels = "limited";
    };
  };

  services.network-manager-applet.enable = true;

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
