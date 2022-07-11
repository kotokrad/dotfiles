{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) { } }:

with pkgs;

stdenv.mkDerivation {
  name = "xmonad-config";
  buildInputs = [
    zlib
    xorg.libX11
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXext
    xorg.libXft
  ];
  nativeBuildInputs = [
    pkg-config
  ];
  dbus = dbus;
}
