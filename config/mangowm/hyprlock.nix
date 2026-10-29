{config, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          path = "/home/kotokrad/pictures/wallpapers/adrianfelipepera_traslasierra.jpg";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      image = [
        {
          path = "/home/kotokrad/pictures/Прочее/6ZU7PV67_400x400.jpg";
          size = 150;
          border_size = 4;
          border_color = "rgb(0C96F9)";
          rounding = -1; # Negative means circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "250, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(CFE6F4)";
          outer_color = "rgb(0C96F9)";
          inner_color = "rgb(${config.lib.stylix.colors.base00})";
          outline_thickness = 5;
          placeholder_text = "Have a nice day ^^";
          shadow_passes = 2;
        }
      ];
    };
  };
}
