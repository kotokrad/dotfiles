{ pkgs, ... }:

{
  # Toggled from quickshell's quick settings; config.ini is not managed by Nix
  systemd.user.services.gammastep = {
    Unit = {
      Description = "Gammastep colour temperature adjuster";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.gammastep}/bin/gammastep -c %h/.config/gammastep/config.ini";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
