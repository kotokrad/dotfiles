{ config, ... }:

let
  c = config.lib.stylix.colors;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font Propo 10";
      modi = "drun,run";
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      matching = "fuzzy";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name}";
    };
    theme = {
      "*" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "#${c.base06}";
      };
      window = {
        width = mkLiteral "500px";
        padding = mkLiteral "8px";
        border = mkLiteral "1px";
        border-radius = mkLiteral "6px";
        border-color = mkLiteral "#${c.base02}";
        background-color = mkLiteral "#${c.base00}";
      };
      mainbox = {
        spacing = mkLiteral "8px";
        children = map mkLiteral [ "inputbar" "message" "listview" ];
      };
      inputbar = {
        padding = mkLiteral "6px 8px 10px";
        border = mkLiteral "0 0 1px";
        border-color = mkLiteral "#${c.base01}";
        children = map mkLiteral [ "entry" ];
      };
      entry = {
        placeholder = "Search";
        placeholder-color = mkLiteral "#${c.base03}";
        cursor-color = mkLiteral "#${c.base0D}";
      };
      listview = {
        lines = 8;
        fixed-height = true;
        scrollbar = false;
      };
      element = {
        padding = mkLiteral "6px 8px";
        spacing = mkLiteral "10px";
        border-radius = mkLiteral "4px";
      };
      "element selected" = {
        background-color = mkLiteral "#${c.base01}";
        text-color = mkLiteral "#${c.base0D}";
      };
      element-icon.size = mkLiteral "24px";
      element-text = {
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
      textbox.padding = mkLiteral "6px 8px";
    };
  };
}
