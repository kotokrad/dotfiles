{ pkgs, ... }:

{
  services.dunst = {
    enable = true;
    iconTheme = {
      # name = "Adwaita";
      # package = pkgs.gnome.adwaita-icon-theme;
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size = "16x16";
    };
    settings = {
      global = {
        monitor = 0;
        geometry = "600x50-50+65";
        shrink = "yes";
        transparency = 10;
        padding = 16;
        horizontal_padding = 16;
        font = "JetBrainsMono Nerd Font 10";
        # font = "FantasqueSansMono Nerd Font 10";
        line_height = 4;
        format = ''<b>%s</b>\n%b'';
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu";
        mouse_left_click = "close_current";
        mouse_right_click = "do_action";
        mouse_middle_click = "context";
      };
    };
  };
}
