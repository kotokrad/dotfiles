{ pkgs, ... }:

{
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      iwSupport = true;
      # githubSupport = true;
    };
    script = "polybar &";
    # settings = {
    # };
    # config = ./polybar/config.ini;
    extraConfig = ''
      [deps]
        xmonad-dbus = ${pkgs.haskellPackages.xmonad-dbus}/bin/xmonad-dbus
      [section/base]
        ; debug mode
        include-file=/home/kotokrad/nixos-config/config/polybar/config.ini
        include-file=/home/kotokrad/nixos-config/config/polybar/modules.ini
    '';
  };

}
