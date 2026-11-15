# Standalone home-manager for the macbook (Fedora Asahi Remix):
#   nix run home-manager -- switch --flake ~/nixos-config#macbook
#
# Fedora setup, outside home-manager
#
# Packages (dnf install)
#   nix nix-daemon                    # nix package manager
#   gcc make                          # treesitter parsers, blink.cmp, rust/cgo linking
#   tcpdump nmap                      # run with sudo, which doesn't search ~/.nix-profile
#   android-tools                     # adb's udev rules
#   gnome-disk-utility                # needs Fedora's udisks + polkit
#   brightnessctl pipewire-utils      # quickshell brightness OSD, audio profiles
#   bluez tuned-ppd                   # quickshell Bluetooth and Power tiles
#   thunar gvfs tumbler               # a Nix Thunar can't load Fedora's gvfs (trash, MTP)
#   thunar-archive-plugin file-roller # Thunar's Extract here / Create archive
#   mate-polkit                       # polkit agent (setuid helper), started below
#   gnome-keyring                     # unlocked at login through PAM
#   xdg-desktop-portal-wlr xdg-desktop-portal-gtk fish
#
# Packages from their own repos
#   mullvad-vpn tailscale
#
# Commands
#   sudo systemctl enable --now nix-daemon
#   sudo systemctl enable --now bluetooth
#   chsh -s /usr/bin/fish
#   sudo usermod -aG dialout $USER    # serial ports: tio, arduino-cli
#   sudo grubby --update-kernel=ALL --args=appledrm.show_notch=1  # screen around the notch
#
# Files
#   /etc/modprobe.d/hid_apple.conf    # swap ctrl/fn, proper F-keys; apply with `sudo dracut -f`
#     options hid_apple swap_fn_leftctrl=1 fnmode=2
#   /etc/tuned/profiles/battery-saver/tuned.conf  # powersave, P-cores capped at 1.97 GHz
#     [main]
#     include=powersave
#     [sysfs]
#     /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq=1968000
#   /etc/tuned/ppd.conf, [profiles]   # then sudo systemctl restart tuned tuned-ppd
#     power-saver=battery-saver
#   /etc/pam.d/quickshell-lock        # lock screen password check
#     auth include login
#   /usr/share/wayland-sessions/mango.desktop
#     [Desktop Entry]
#     Name=Mango
#     Comment=mango WM
#     DesktopNames=mango;wlroots
#     Exec=/home/kotokrad/.nix-profile/bin/mango
#     Type=Application
#
# After the first switch
#   run the sudo GPU setup command it prints
#   copy ~/.config/gammastep/config.ini and the wallpaper (~/pictures/wallpapers)
{ config, inputs, pkgs, ... }:

let
  packages = with pkgs; [
  # Applications
    telegram-desktop
    transmission_4-gtk
    vlc
    mate-calc
    mousepad
    imv                         # image viewer
    xfce4-taskmanager

  # Utility
    ripgrep
    libnotify                   # notify-send command
    ncdu                        # disk space info (a better du)
    fastfetch                   # command-line system information
    nyancat                     # the famous rainbow cat!
    tealdeer                    # (tldr) summary of a man page
    jq
    ffmpeg
    wev

  # Dev
    anyzig
    zls
    rustup
    go
    pgweb

  # Embedded
    arduino-cli
    gcc-arm-embedded
    tio

  # Desktop
    playerctl                   # media keys, quickshell
    pavucontrol                 # Super+M, quickshell
    networkmanagerapplet        # nm-connection-editor for the network menu
    nerd-fonts.iosevka          # foot
    nerd-fonts.jetbrains-mono   # rofi, quickshell
    papirus-icon-theme          # rofi, quickshell tray
];

  # Pause gammastep hyprpicker runs
  hyprpicker = pkgs.writeShellScriptBin "hyprpicker" ''
    if systemctl --user -q is-active gammastep; then
      systemctl --user kill -s KILL gammastep
      systemctl --user stop gammastep
      trap 'systemctl --user start gammastep' EXIT
      sleep 0.15
    fi
    ${pkgs.hyprpicker}/bin/hyprpicker "$@"
  '';
in
{
  imports = [
    ./stylix.nix
    ./config/stylix.nix
    ./config/scripts
    ./config/fish.nix
    ./config/git.nix
    ./config/gammastep.nix
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
    stateVersion = "26.11";
    packages = packages ++ [ (pkgs.lib.hiPrio hyprpicker) ];
    shellAliases.nix-switch = "home-manager switch --flake '/home/kotokrad/nixos-config#macbook'";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # Non-NixOS: Nix-built Mesa in /run/opengl-driver (activation prints the one-time
  # sudo command), XDG_DATA_DIRS, locales
  targets.genericLinux.enable = true;

  # nixpkgs' pam_unix runs NixOS's /run/wrappers/bin/unix_chkpwd; the lock screen's PAM runs
  # Fedora's instead. Quickshell and linux-pam build locally
  programs.quickshell.package = pkgs.quickshell.override {
    pam = pkgs.linux-pam.overrideAttrs (old: {
      postPatch = old.postPatch + ''
        substituteInPlace modules/module-meson.build \
          --replace-fail "'/run/wrappers/bin/unix_chkpwd'" "'/usr/sbin/unix_chkpwd'"
      '';
    });
  };

  # The screen reaches up around the notch (appledrm.show_notch, see the top)
  quickshell.settings = {
    barHeight = 26;
    notch = { screen = "eDP-1"; width = 154; }; # logical px
  };

  # apple-drm has no gamma LUT, and its CTM costs battery.
  # scenefx patched to apply gammastep's LUT on the GPU
  wayland.windowManager.mango = {
    package =
      let system = pkgs.stdenv.hostPlatform.system;
      in (inputs.mango.packages.${system}.mango.override {
        scenefx = inputs.mango.inputs.scenefx.packages.${system}.default.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./patches/scenefx-gamma-fallback.patch ];
        });
      }).overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/mango-raise-on-hover.patch ];
      });

    extraConfig = ''
      trackpad_scroll_factor = 1.0
    '';
  };


  # Fedora's xdg-desktop-portal doesn't look in the Nix profile
  xdg.configFile."xdg-desktop-portal/mango-portals.conf".source =
    "${config.wayland.windowManager.mango.package}/share/xdg-desktop-portal/mango-portals.conf";

  # Nix commands for user services (hypridle, quickshell)
  systemd.user.sessionVariables.PATH = "${config.home.profileDirectory}/bin:$PATH";

  # Fedora's mate-polkit; its autostart entry is MATE-only
  systemd.user.services.polkit-mate-agent = {
    Unit = {
      Description = "MATE polkit authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "/usr/libexec/polkit-mate-authentication-agent-1";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.playerctld.enable = true;

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
}
