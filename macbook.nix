{ config, inputs, pkgs, ... }:

let
  packages = with pkgs; [
  # Applications
    orca-slicer

  # Utility
    wev

  # Embedded
    arduino-cli

  # Desktop
    noto-fonts
    noto-fonts-cjk-sans
];

  # Pause gammastep before running hyprpicker
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
    ./home.nix
  ];

  home = {
    stateVersion = "26.11";
    packages = packages ++ [ (pkgs.lib.hiPrio hyprpicker) ];
    shellAliases.nix-switch = "home-manager switch --flake '/home/kotokrad/nixos-config#macbook'";
  };

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

  programs.swayimg = {
    enable = true;
    initLua = ''
      swayimg.imagelist.adjacent = true
      swayimg.viewer.default_scale = "real"
      swayimg.viewer.on_key("0", function()
        swayimg.viewer.default_scale = "real"
        swayimg.viewer.reset()
      end)
      swayimg.viewer.on_key("equal", function()
        swayimg.viewer.default_scale = "optimal"
        swayimg.viewer.reset()
      end)
    '';
  };

  # The screen reaches up around the notch (appledrm.show_notch, see the top)
  quickshell.settings = {
    barHeight = 26;
    notch = { screen = "eDP-1"; width = 154; };
    lowVoltage = 10.4;
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
      monitor_rule = name:^eDP-1$,scale:2,x:0,y:0
      trackpad_scroll_factor = 1.0
      xkb_rules_options = grp:lalt_lshift_toggle,caps:escape,ctrl:ralt_rctrl
    '';
  };

  # Fedora's xdg-desktop-portal doesn't look in the Nix profile
  xdg.configFile."xdg-desktop-portal/mango-portals.conf".source =
    "${config.wayland.windowManager.mango.package}/share/xdg-desktop-portal/mango-portals.conf";

  # Nix commands for user services (hypridle, quickshell)
  systemd.user.sessionVariables.PATH = "${config.home.profileDirectory}/bin:$PATH";

  # Fedora's gcr-ssh-agent exports its socket only to systemd, which mango doesn't import
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
}
