# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  xtrlock-pam-python3 = pkgs.xtrlock-pam.overrideAttrs (
    old: {
      buildInputs = with pkgs; [ python39 pam xorg.libX11 ];
    }
  );
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # boot.kernelParams = ["amdgpu.backlight=0" "acpi_backlight=none"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    # Function/media keys:
    #   0: Function keys only.
    #   1: Media keys by default.
    #   2: Function keys by default.
    options hid_apple fnmode=2
  '';

  # Dedicated file system for Docker to prevent btrfs corruption
  # https://gist.github.com/hopeseekr/cd2058e71d01deca5bae9f4e5a555440
  # cd /media
  # touch docker-volume.img
  # chattr +C docker-volume.img
  # fallocate -l 20G docker-volume.img
  # mkfs.ext4 docker-volume.img
  fileSystems."/var/lib/docker" = {
    device = "/media/docker-volume.img";
    fsType = "ext4";
    options = [ "loop" ];
  };

  #   powerManagement = {
  #     enable = true;
  #     resumeCommands = ''
  #       betterlockscreen -l
  #     '';
  #   };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;
  networking.nftables.enable = true;
  # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups
  networking.firewall.checkReversePath = "loose";
  systemd.services.NetworkManager-wait-online.enable = false;

  virtualisation.docker.enable = true;

  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true;
  };

  environment.variables = {
    EDITOR = "nvim";

    # HiDPI
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    XCURSOR_SIZE = "86";
  };

  environment.systemPackages = with pkgs; [
    coreutils
    wget
    git
    xtrlock-pam-python3
    ntfs3g
  ];

  location.provider = "geoclue2";

  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    blueman.enable = true;
    illum.enable = true; # brightness buttons
    gvfs.enable = true;
    tumbler.enable = true;
    # opensnitch.enable = true;
    tailscale.enable = true;
    usbmuxd.enable = true;
    avahi.enable = true;
    mullvad-vpn.enable = true;

    syncthing = {
      enable = false;
      dataDir = "/home/kotokrad";
      user = "kotokrad";
    };

    mpd.enable = true;
    mpd.musicDirectory = "/home/kotokrad/music";

    logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';

    udev.extraRules = ''
      # Disable wakeup signals to avoid resume getting triggered
      # some time after suspend. Reboot required for this to take effect.
      SUBSYSTEM=="pci", KERNEL=="0000:00:08.1", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="pci", KERNEL=="0000:03:00.3", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="pci", KERNEL=="0000:03:00.4", ATTR{power/wakeup}="disabled"

      # Access PS4 controller hid stream as non-root user
      SUBSYSTEM=="input", GROUP="input", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE:="666", GROUP="plugdev"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"

      SUBSYSTEM=="input", GROUP="input", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE:="666", GROUP="plugdev"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"

      SUBSYSTEM=="input", GROUP="input", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE:="666", GROUP="plugdev"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
    '';

    dbus.enable = true;
    dbus.packages = with pkgs; [
      gcr
      dconf
      xfce.xfconf
    ];

    #     tlp = {
    #       # advanced power management
    #       enable = true;
    #       settings = {
    #         # Do not suspend USB devices
    #         # USB_AUTOSUSPEND = 0;
    #         USB_EXCLUDE_BTUSB = 1;
    #         RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
    #       };
    #     };
    libinput.enable = true;

    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "kotokrad";
    displayManager.defaultSession = "none+fake";

    xserver = {
      enable = true;
      dpi = 180;
      xkb = {
        options = "caps:escape,grp:alt_shift_toggle";
        layout = "us,ru";
      };
      updateDbusEnvironment = true;

      displayManager.lightdm.enable = true;
      displayManager.session =
        let fakeSession = {
          manage = "window";
          name = "fake";
          start = "";
        };
        in [ fakeSession ];

      # xset r rate 250 55
      # 18 = 55
      # 17 = 58
      # 16 = 62
      # 10 = 100
      autoRepeatInterval = 18;
      autoRepeatDelay = 250;

      videoDrivers = [ "amdgpu" ];
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';

    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      extraPlugins = with pkgs.postgresql_14.pkgs; [ postgis ];
      enableTCPIP = false;
      identMap = ''
        postgres kotokrad postgres
      '';
      authentication = lib.mkForce ''
        # Generated file; do not edit!
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
    };

  };

  sound.enable = true;

  hardware = {
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

    bluetooth.enable = true;
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true; # Needed for steam
    opengl.extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    # opengl.extraPackages = with pkgs; [ amdvlk ];
    # opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
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
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "FantasqueSansMono" ]; })
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
      "docker"
      "adbusers"
      "lp"
      "syncthing"
    ];
    shell = pkgs.fish;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.fish.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.adb.enable = true;
  programs.thefuck.enable = true;
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${xtrlock-pam-python3}/bin/xtrlock-pam";
  programs.wireshark.enable = true;
  programs.nix-ld.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
