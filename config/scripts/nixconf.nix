{ fetchurl, pkgs }:

with pkgs;

writeShellScriptBin "nixconf" ''
  rofi="${pkgs.rofi}/bin/rofi"
  git="${pkgs.git}/bin/git"
  nvr="${pkgs.neovim-remote}/bin/nvr"
  wezterm="${pkgs.wezterm}/bin/wezterm"

  cd ~/nixos-config
  configfile=$($git ls-files | rofi -dmenu -matching fuzzy)
  socketfile=/tmp/nvimsocket-nixconfig

  if [ -z $configfile ]; then
    exit 0
  fi

  if [ -S $socketfile ]; then
    $nvr --servername $socketfile $configfile
  else
    $wezterm start --class nixconf --cwd ~/nixos-config -- $nvr --servername $socketfile $configfile
  fi
''
