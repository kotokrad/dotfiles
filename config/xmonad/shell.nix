with import <nixpkgs> {};

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
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];
    dbus = pkgs.dbus;
}
