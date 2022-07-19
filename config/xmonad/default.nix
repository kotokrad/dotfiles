{ pkgs, ... }:

# let
#   startupOpts = ''
#     ${pkgs.xorg.xset}/bin/xset r rate 250 50
#     ${pkgs.nitrogen}/bin/nitrogen --restore &
#     ${pkgs.blueman}/bin/blueman-applet &
#     ${pkgs.gnome3.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator &
#   '';
#     # ${pkgs.xorg.xset}/bin/xset s off
#     # ${pkgs.xcape}/bin/xcape -e "Hyper_L=Tab;Hyper_R=backslash"
#     # ${pkgs.util-linux}/bin/setterm -blank 0 -powersave off -powerdown 0
#     # ${pkgs.pasystray}/bin/pasystray &
#     # ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-0 --mode 3840x2160 --rate 30.00
# in
{
  xresources.properties = {
    "Xft.dpi" = 180;
    "Xft.autohint" = 0;
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
    "Xft.font" = "FantasqueSansMono Nerd Font 14";
  };

  xsession = {
    enable = true;

    windowManager.xmonad = {
      enable = true;
      config = ./xmonad.hs;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad-dbus
      ];
    };

    initExtra = "${pkgs.nitrogen}/bin/nitrogen --restore &";

  };

  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
    gtk.enable = true;
  };

}
