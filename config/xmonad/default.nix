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

  programs.xmobar = {
    enable = true;
    extraConfig = builtins.readFile ./xmobarrc.hs;
  };

  services.trayer = {
    enable = true;
    # settings = {
    #   edge = "top";
    #   padding = 6;
    #   SetDockType = true;
    #   tint = "0x282c34";
    # };
    settings = {
      edge = "top";
      align = "right";
      widthtype = "request";
      distancefrom = "top";
      distance = 2;
      height = 28;
      alpha = 0;
      transparent = true;
      iconspacing = 1;
      expand = true;
      tint = "0x282c34";
    };
  };

  xdg.configFile."xmonad/xmobarrc.hs".source = ./xmobarrc.hs;
  xdg.configFile."xmonad/padding-icon.sh".source = ./padding-icon.sh;

  xsession = {
    enable = true;

    windowManager.xmonad = {
      enable = true;
      config = ./xmonad.hs;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib_0_17_0
        haskellPackages.xmonad-extras_0_17_0
      ];
    };

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
  };

}
