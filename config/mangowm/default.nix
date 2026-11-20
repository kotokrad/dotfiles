{ config, inputs, lib, pkgs, ... }: {
  imports = [
    inputs.mango.hmModules.mango
    ./hypridle.nix
  ];

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    hyprpicker
    playerctl
    pavucontrol
  ];

  services.awww.enable = true;
  services.playerctld.enable = true;

  wayland.windowManager.mango = {
    enable = true;
    # Hover raises the window as well as focusing it, like Hyprland
    package = lib.mkDefault (inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../../patches/mango-raise-on-hover.patch ];
    }));
    systemd.variables = ["--all"];

    autostart_sh = ''
      (sleep 1.5 && awww img /home/kotokrad/pictures/wallpapers/adrianfelipepera_traslasierra.jpg) &
    '';

    # Everything else lives in mango.conf so edits reload live without a switch. _optional because
    # the build-time `mango -p` check runs in a sandbox that can't see the repo.
    settings = {
      cursor_theme = config.stylix.cursor.name;
      cursor_size = config.stylix.cursor.size;
      source_optional = "~/nixos-config/config/mangowm/mango.conf";
    };
  };
}
