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
          lock_cmd = "quickshell-lock";
          inhibit_sleep = 0;
          after_sleep_cmd = "${wlopm} --on '*'";
          ignore_dbus_inhibit = false;
          };
        listener = [
          {
            timeout = 60;
            on-timeout = "brightnessctl -s set 10%";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 120;
            on-timeout = "quickshell-lock 5";
          }
          {
            timeout = 300;
            on-timeout = "${wlopm} --off '*'";
            on-resume = "${wlopm} --on '*'";
          }
          {
            # Only on battery
            timeout = 600;
            on-timeout = "${pkgs.systemd}/bin/systemd-ac-power || systemctl suspend";
          }
        ];
      };
    };
  };
}
