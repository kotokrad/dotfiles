local wezterm = require "wezterm"

function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("trigger-copy", function(window,pane)
  local title = basename(pane:get_foreground_process_name())
  if title == "nvim" then
    window:perform_action(wezterm.action{SendKey={key="c", mods="ALT"}}, pane)
  else
    window:perform_action(wezterm.action{CopyTo="ClipboardAndPrimarySelection"}, pane)
  end
end)

return {
    -- default_prog = {"/run/current-system/sw/bin/tmux"},
    font = wezterm.font("FantasqueSansM Nerd Font", {weight = "Regular", italic = false}),
    font_size = 11.0,
    enable_tab_bar = false,
    color_scheme = "Gruvbox dark, hard (base16)",
    -- color_scheme = "tokyonight_night",
    -- color_schemes = {
    --     tokyonight_storm = require("./tokyonight").storm,
    --     tokyonight_night = require "./tokyonight".night
    -- },
    disable_default_key_bindings = true,
    adjust_window_size_when_changing_font_size = false,
    keys = {
      { key="c", mods="SUPER", action=wezterm.action{EmitEvent="trigger-copy"} },
      { key="v", mods="SUPER", action=wezterm.action{PasteFrom="Clipboard"} },
      { key="raw:141", action=wezterm.action{EmitEvent="trigger-copy"} },
      { key="raw:143", action=wezterm.action{PasteFrom="Clipboard"} },
      { key="Insert", mods="SHIFT", action=wezterm.action{PasteFrom="Clipboard"} },
      { key="a", mods="CTRL", action="QuickSelect" },
      { key="=", mods="CTRL", action="IncreaseFontSize" },
      { key="-", mods="CTRL", action="DecreaseFontSize" },
      { key="0", mods="CTRL", action="ResetFontSize" },
      { key="z", mods="CTRL", action="ShowDebugOverlay" },
    },
    debug_key_events = true,
    check_for_updates = false,
    show_update_window = false,
    term = "wezterm"
}
