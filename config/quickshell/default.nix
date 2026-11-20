{ config, lib, pkgs, ... }:

let
  json = pkgs.formats.json { };
  settingsFile = json.generate "quickshell-settings.json" config.quickshell.settings;
in
{
  imports = [ ./lock.nix ];

  # Per-machine values for dotfiles/Ui.qml
  options.quickshell.settings = lib.mkOption {
    type = json.type;
    default = { };
  };

  config = {
    programs.quickshell = {
      enable = true;
      systemd = {
        enable = true;
        target = "mango-session.target";
      };
    };

    home.packages = with pkgs; [
      qrencode                    # Wi-Fi password QR code in the network menu
      networkmanagerapplet        # nm-connection-editor
      pavucontrol
      nerd-fonts.jetbrains-mono
      papirus-icon-theme
    ];

    systemd.user.services.quickshell = {
      Unit = {
        PartOf = [ "mango-session.target" ]; # stop on logout
        X-Restart-Triggers = [ "${settingsFile}" ]; # new settings take a restart
      };
      Service.Environment = [ "QS_ICON_THEME=Papirus" ]; # monochrome Papirus panel icons in the tray
    };

    # Symlink out of the store: Quickshell reloads QML on save, no rebuild needed
    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "/home/kotokrad/nixos-config/config/quickshell/dotfiles";
    xdg.configFile."quickshell-settings.json".source = settingsFile;
  };
}
