# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.kernelParams = ["amdgpu.backlight=0" "acpi_backlight=none"];
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
  fileSystems."/var/lib/docker" =
    { device = "/media/docker-volume.img";
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

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

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
    xtrlock-pam
  ];

  location.provider = "manual";
  location.latitude = 9.7486;
  location.longitude = 100.0206;

  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    blueman.enable = true;
    redshift.enable = true;
    illum.enable = true;                 # brightness buttons
    greenclip.enable = true;             # clipboard manager to be integrated with rofi
    gvfs.enable = true;
    tumbler.enable = true;

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
    '';

    dbus.enable = true;

    tlp = {
      # advanced power management
      enable = true;
      settings = {
        # Do not suspend USB devices
        # USB_AUTOSUSPEND = 0;
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
      };
    };

    xserver = {
      enable = true;
      dpi = 180;
      layout = "us,ru";
      xkbOptions = "caps:escape,grp:alt_shift_toggle";
      libinput.enable = true;
      updateDbusEnvironment = true;

      displayManager.lightdm.enable = true;
      displayManager.autoLogin.enable = true;
      displayManager.autoLogin.user = "kotokrad";
      displayManager.defaultSession = "none+fake";
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
    bluetooth.enable = true;
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true; # Needed for steam
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    video.hidpi.enable = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Fonts
  fonts.fonts = with pkgs; [
    corefonts
    font-awesome-ttf
    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "FantasqueSansMono" ]; })
    # japanese fonts:
    ipafont
    kochi-substitute
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  # Users
  users.users.kotokrad = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "audio"
      "docker"
      "adbusers"
      "lp"
    ];
    shell = pkgs.zsh;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.adb.enable = true;
  programs.thefuck.enable = true;
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
