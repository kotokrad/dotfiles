{ pkgs, ... }:

let
  wlopm = "${pkgs.wlopm}/bin/wlopm";
in
{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "${wlopm} --on '*'";
          ignore_dbus_inhibit = false;
          };
        listener = [
          {
            timeout = 120;
            on-timeout = "pidof hyprlock || hyprlock --grace 5";
          }
          {
            timeout = 300;
            on-timeout = "${wlopm} --off '*'";
            on-resume = "${wlopm} --on '*'";
          }
        ];
      };
    };
  };
}
