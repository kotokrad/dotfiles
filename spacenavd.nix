{ config, pkgs, ... }:

let
  spacenav-ws = pkgs.python3Packages.buildPythonPackage rec {
    name = "spacenav-ws";
    pname = "spacenav_ws";
    version = "0.1.5";

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-T47MPOmN9bhACatshb49OGJg1rxbqQN7CmhsBHaSTGk=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      websockets
      fastapi
      numpy
      scipy
      typer
      uvicorn
    ];

    doCheck = false;
    pyproject = true;
    build-system = [ pkgs.python3Packages.hatchling ];
  };
in
{
  hardware.spacenavd.enable = true;

  systemd.user.services.spacenav-ws = {
    description = "SpaceNavigator WebSocket Server";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${spacenav-ws}/bin/spacenav-ws serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
