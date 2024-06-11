{ pkgs }:

with pkgs;

writeShellScriptBin "remaps" ''
  # swap right and back button then swap middle and back button
  ${pkgs.xorg.xinput}/bin/xinput set-button-map 'Kensington Expert Mouse' 1 2 2 4 5 6 7 3 9
  # enable natural scrolling
  # ${pkgs.xorg.xinput}/bin/xinput set-prop 'Kensington Expert Mouse' 'libinput Natural Scrolling Enabled' 1
  # disable acceliration for the ball
  # ${pkgs.xorg.xinput}/bin/xinput set-prop 'Kensington Expert Mouse' 'libinput Accel Profile Enabled' 0, 1

  ${pkgs.xorg.xinput}/bin/xinput set-prop 'Kensington Expert Mouse' 'libinput Scroll Method Enabled' 0, 0, 1
  ${pkgs.xorg.xinput}/bin/xinput set-prop 'Kensington Expert Mouse' 'libinput Button Scrolling Button' 3
''
