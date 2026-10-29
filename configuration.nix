# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./spacenavd.nix
      # ./opensnitch.nix
    ];

  # boot.kernelParams = ["amdgpu.backlight=0" "acpi_backlight=none"];
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = false;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.extraModprobeConfig = ''
    # Function/media keys:
    #   0: Function keys only.
    #   1: Media keys by default.
    #   2: Function keys by default.
    options hid_apple fnmode=2
  '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "nixos";
  networking.extraHosts = ''
    127.0.0.1 local.test.com
    192.168.0.142 homeassistant.local
  '';
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups
  networking.firewall.checkReversePath = "loose";
  systemd.services.NetworkManager-wait-online.enable = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true;
  };

  environment.variables = {
    EDITOR = "nvim";

    # HiDPI
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "1"; # changed 0.5 to 1 to fix firefox in wayland
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    # XCURSOR_SIZE = "86"; # disabled for stylix
  };

  environment.systemPackages = with pkgs; [
    coreutils
    wget
    git
    ntfs3g
    brightnessctl
    spnavcfg
    android-tools
    docker-compose
  ];

  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };

  # [pipewire] rtkit is optional but recommended
  security.rtkit.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;
    gnome.gcr-ssh-agent.enable = false; # it conflicts with programs.ssh.startAgent
    upower.enable = true;
    power-profiles-daemon.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    tailscale.enable = true;
    usbmuxd.enable = true;
    mullvad-vpn.enable = true;
    flatpak.enable = true;
    playerctld.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        cnijfilter2
        hplipWithPlugin
      ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    logind.settings.Login.HandlePowerKey = "suspend";

    udev.extraRules = ''
      # Disable wakeup signals to avoid resume getting triggered
      # some time after suspend. Reboot required for this to take effect.
      SUBSYSTEM=="pci", KERNEL=="0000:00:08.1", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="pci", KERNEL=="0000:03:00.3", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="pci", KERNEL=="0000:03:00.4", ATTR{power/wakeup}="disabled"

      # QMK Vial
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # Wireshark usbmon
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"

      # ST-Link with Blackmagic FW
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", ACTION=="add", RUN+="${pkgs.stlink-tool}/bin/stlink-tool"
    '';

    libinput.enable = true;

    displayManager.regreet.enable = true;
    greetd.settings.initial_session = {
      user = "kotokrad";
      command = lib.getExe' config.programs.mango.package "mango";
    };

    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          main.rightalt = "layer(ralt)";
          "ralt:C" = {
            "4" = "3";
            r = "e";
            f = "d";
            v = "c";
          };
        };
      };
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 1;
          ReconnectIntervals = "1,2,4,8";
        };
      };
    };
    graphics.enable = true;
    keyboard.qmk.enable = true;

    # scanner
    sane.enable = true;
    sane.extraBackends = [ pkgs.hplipWithPlugin ];
  };

  nix = {
    package = pkgs.nixVersions.latest;
    settings.trusted-users = [ "root" "kotokrad" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
    font-awesome
    material-design-icons
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.iosevka
    # japanese fonts:
    ipafont
    kochi-substitute
    # chinese fonts:
    noto-fonts
    source-han-sans
    source-han-serif
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
      "Noto Sans Mono CJK SC"
      "Sarasa Mono SC"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
      "Noto Sans CJK SC"
      "Source Han Sans SC"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
      "Noto Serif CJK SC"
      "Source Han Serif SC"
    ];
  };

  # Users
  users.users.kotokrad = {
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "wheel"
      "networkmanager"
      "input"
      "audio"
      "adbusers"
      "scanner"
      "lp"
      "wireshark"
    ];
    shell = pkgs.fish;
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/kotokrad/nixos-config";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  programs.fish.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf.enable = true;
  programs.xfconf.enable = true;
  programs.seahorse.enable = true;
  programs.steam.enable = true;
  programs.pay-respects.enable = true;
  programs.wireshark.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-index-database.comma.enable = true;

  # CVE-2026-111497 stopgap, remove once brotli 1.2.1 is in nixos-unstable
  system.replaceDependencies.replacements =
    let
      fix = b: b.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (pkgs.fetchurl {
            url = "https://github.com/google/brotli/commit/0ed4268a4401abcb4472096340477cf4af7d1a2b.patch?full_index=1";
            hash = "sha256-1vliUJAAIj3vcGKVgim9CEV+XgMuftDR2U+3kLBUsfw=";
          })
        ];
      });
      new = fix pkgs.brotli;
      new32 = fix pkgs.pkgsi686Linux.brotli;
    in [
      { oldDependency = pkgs.brotli.out; newDependency = new.out; }
      { oldDependency = pkgs.brotli.lib; newDependency = new.lib; }
      { oldDependency = pkgs.pkgsi686Linux.brotli.lib; newDependency = new32.lib; }
    ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
