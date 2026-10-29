{ config, pkgs, ... }:

{
  # Bar, quick settings, VPN switcher, OSD and notifications for mango
  programs.quickshell = {
    enable = true;
    systemd = {
      enable = true;
      target = "mango-session.target";
    };
  };

  home.packages = [ pkgs.qrencode ]; # Wi-Fi password QR code in the network menu

  systemd.user.services.quickshell = {
    Unit.PartOf = [ "mango-session.target" ]; # stop on logout
    Service.Environment = [ "QS_ICON_THEME=Papirus" ]; # monochrome Papirus panel icons in the tray
  };

  # Symlink out of the store: Quickshell reloads QML on save, no rebuild needed
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "/home/kotokrad/nixos-config/config/quickshell/dotfiles";
}
