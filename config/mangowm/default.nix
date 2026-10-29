{ config, inputs, pkgs, ... }: let
  terminal = "foot";

  # Browser extension popups
  extension-popups = pkgs.writeShellApplication {
    name = "mango-extension-popups";
    runtimeInputs = [ config.wayland.windowManager.mango.package pkgs.jq ];
    text = ''
      declare -A popups=()
      sloppy=1
      mmsg dispatch setoption,sloppy_focus,1
      mmsg watch all-clients | while read -r event; do
        ids=" $(jq -r '[.clients[].id] | join(" ")' <<<"$event") "
        for id in "''${!popups[@]}"; do
          [[ $ids == *" $id "* ]] || unset "popups[$id]"
        done

        while read -r id floating; do
          [ -n "''${popups[$id]:-}" ] && continue
          popups[$id]=1
          if [ "$floating" = false ]; then
            mmsg dispatch togglefloating client,"$id"
            mmsg dispatch resizewin,500,800 client,"$id"
            mmsg dispatch centerwin client,"$id"
          fi
        done < <(jq -r '.clients[] | select(.title | test("^(Extension:|_crx_)")) | "\(.id) \(.is_floating)"' <<<"$event")

        want=$(( ''${#popups[@]} == 0 ))
        if [ "$want" != "$sloppy" ]; then
          mmsg dispatch setoption,sloppy_focus,"$want"
          sloppy=$want
        fi
      done
    '';
  };

  # Meta+Tab on a maximized or fullscreen window hands that state to the next window, like monocle,
  # instead of focusing a window hidden behind it
  focus-stack = pkgs.writeShellApplication {
    name = "mango-focus-stack";
    runtimeInputs = [ config.wayland.windowManager.mango.package pkgs.jq ];
    text = ''
      state=$(mmsg get focusing-client | jq -r 'if .is_fullscreen then "togglefullscreen" elif .is_maximized then "togglemaximizescreen" else "" end')
      if [ -z "$state" ]; then
        exec mmsg dispatch focusstack,"$1"
      fi
      mmsg dispatch setoption,animations,0 # an instant swap, like monocle
      mmsg dispatch "$state"
      mmsg dispatch focusstack,"$1"
      mmsg dispatch "$state"
      mmsg dispatch setoption,animations,1
    '';
  };
in {
  systemd.user.services.mango-extension-popups = {
    Unit = {
      Description = "Float browser extension popups";
      PartOf = [ "mango-session.target" ];
      After = [ "mango-session.target" ];
    };
    Service = {
      ExecStart = "${extension-popups}/bin/mango-extension-popups";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "mango-session.target" ];
  };

  imports = [
    inputs.mango.hmModules.mango
    ./hypridle.nix
    ./hyprlock.nix
  ];

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    hyprpicker
  ];

  services.awww.enable = true;

  # Battery notification
  services.batsignal = {
    enable = true;
    extraArgs = ["-w 30" "-c 15" "-d 5"];
  };

  wayland.windowManager.mango = {
    enable = true;
    systemd.variables = ["--all"];

    autostart_sh = ''
      (sleep 1.5 && awww img /home/kotokrad/pictures/wallpapers/adrianfelipepera_traslasierra.jpg) &
    '';

    settings = {
      env = [
        "GDK_SCALE,2"
        "NIXOS_OZONE_WL,1"
        "NIXPKGS_ALLOW_UNFREE,1"
        "XDG_CURRENT_DESKTOP,mango"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,mango"
        "GDK_BACKEND,wayland,x11,*"
        "CLUTTER_BACKEND,wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "SDL_VIDEODRIVER,x11"
        "MOZ_ENABLE_WAYLAND,1"
      ];

      monitor_rule = [
        "name:^eDP-1$,scale:2,x:560,y:1440"
        "make:Dell Inc.,model:DELL U3223QE,scale:1.5,x:0,y:0"
      ];

      # Input
      xkb_rules_layout = "us,ru,ua";
      xkb_rules_options = "grp:alt_shift_toggle,caps:escape";
      numlock_on = 1;
      repeat_delay = 200;
      repeat_rate = 35;
      trackpad_scroll_factor = 0.3;
      device_rule = [
        "name:Kensington Expert Mouse,scroll_method:4,scroll_button:274"
        "name:Bluetooth Ergonomic Mouse,accel_speed:-0.6"
      ];

      # Look
      border_px = 0;
      border_radius = 4;
      gap_inner_horizontal = 2;
      gap_inner_vertical = 2;
      gap_outer_horizontal = 4;
      gap_outer_vertical = 4;
      blur = 1;
      blur_params_radius = 5;
      blur_params_num_passes = 3;
      animation_duration_open = 300;
      animation_duration_close = 200;
      animation_duration_move = 200;
      animation_duration_tag = 500;
      cursor_theme = config.stylix.cursor.name;
      cursor_size = config.stylix.cursor.size;

      # Layouts
      new_is_master = 1;
      default_master_factor = 0.5;
      tag_rule = [
        "id:1,layout_name:monocle"
        "id:5,layout_name:monocle"
      ];
      circle_layout = "tile,monocle";
      monocle_tab_mode = 0;

      # Misc
      focus_cross_monitor = 1;
      exchange_cross_monitor = 1;
      idle_inhibit_when_fullscreen = 1;
      xwayland_ignore_scale = 1;
      cursor_hide_on_keypress = 1;
      cursor_hide_timeout = 1;

      bind = [
        "SUPER,Return,spawn,${terminal}"
        "SUPER,w,spawn,rofi-launcher"
        "SUPER,r,spawn,rofi -show run -no-show-icons"
        "SUPER+SHIFT,w,spawn,web-search"
        "SUPER,s,spawn_shell,grim -l 9 -t png -g \"$(slurp)\" - | wl-copy -t image/png"
        "SUPER+SHIFT,s,spawn_shell,grim -l 9 -t png -g \"$(slurp)\" ~/screenshot-$(date +%F_%H-%M-%S).png"
        "SUPER,c,spawn,hyprpicker -a"
        "SUPER,e,spawn,thunar"
        "SUPER,n,toggle_named_scratchpad,notes,none,${terminal} --app-id=notes --working-directory=/home/kotokrad/notes nvim scratchpad.md"
        "SUPER,m,spawn,pavucontrol"
        "SUPER,p,spawn,qs ipc call vpn toggle"
        "SUPER,q,killclient"
        "SUPER,f,togglemaximizescreen"
        "SUPER+SHIFT,f,togglefullscreen"
        "SUPER,t,togglefloating"
        "SUPER,o,tagmon,next"
        "SUPER,grave,focusmon,next"
        "SUPER+SHIFT,q,quit"
        "SUPER+SHIFT,Return,zoom"
        "SUPER+CTRL,space,switch_layout"
        "SUPER,h,focusdir,left"
        "SUPER,l,focusdir,right"
        "SUPER,k,focusdir,up"
        "SUPER,j,focusdir,down"
        "SUPER,Left,focusdir,left"
        "SUPER,Right,focusdir,right"
        "SUPER,Up,focusdir,up"
        "SUPER,Down,focusdir,down"
        "SUPER+SHIFT,h,move_client,left"
        "SUPER+SHIFT,l,move_client,right"
        "SUPER+SHIFT,k,move_client,up"
        "SUPER+SHIFT,j,move_client,down"
        "SUPER+SHIFT,Left,move_client,left"
        "SUPER+SHIFT,Right,move_client,right"
        "SUPER+SHIFT,Up,move_client,up"
        "SUPER+SHIFT,Down,move_client,down"
        "SUPER,Tab,spawn,${focus-stack}/bin/mango-focus-stack next"
        "SUPER+SHIFT,Tab,spawn,${focus-stack}/bin/mango-focus-stack prev"
        "SUPER,Escape,view,-1"
        "SUPER,space,toggle_special_tag"
        "SUPER+SHIFT,space,tag_special_tag"
        "SUPER,1,view,1"
        "SUPER,2,view,2"
        "SUPER,3,view,3"
        "SUPER,4,view,4"
        "SUPER,5,view,5"
        "SUPER,6,view,6"
        "SUPER,7,view,7"
        "SUPER,8,view,8"
        "SUPER,9,view,9"
        "SUPER+SHIFT,1,tag,1"
        "SUPER+SHIFT,2,tag,2"
        "SUPER+SHIFT,3,tag,3"
        "SUPER+SHIFT,4,tag,4"
        "SUPER+SHIFT,5,tag,5"
        "SUPER+SHIFT,6,tag,6"
        "SUPER+SHIFT,7,tag,7"
        "SUPER+SHIFT,8,tag,8"
        "SUPER+SHIFT,9,tag,9"
        "SUPER+CTRL,Right,viewtoright_have_client"
        "SUPER+CTRL,Left,viewtoleft_have_client"
        "NONE,XF86AudioRaiseVolume,spawn,qs ipc call volume up"
        "NONE,XF86AudioLowerVolume,spawn,qs ipc call volume down"
        "NONE,XF86AudioMute,spawn,qs ipc call volume mute"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86AudioPrev,spawn,playerctl previous"
        "NONE,XF86MonBrightnessDown,spawn,qs ipc call brightness down"
        "NONE,XF86MonBrightnessUp,spawn,qs ipc call brightness up"
      ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];

      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
      ];

      switchbind = [
        "fold,spawn,loginctl lock-session"
      ];

      # Rules only match at map time; dialogs with a parent window float on their own
      window_rule = [
        # Workspaces
        "tags:1,app_id:^(Brave-browser(-beta|-dev|-unstable)?|[Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Gg]oogle-chrome(-beta|-dev|-unstable)?|[Tt]horium-browser|[Cc]achy-browser)$"
        "tags:2,focused_opacity:0.99,unfocused_opacity:0.95,app_id:^(foot|Alacritty|kitty|wezterm|com.mitchellh.ghostty)$"
        "tags:3,focused_opacity:0.99,unfocused_opacity:0.95,app_id:^(codium|codium-url-handler|VSCodium|VSCode|code-url-handler)$"
        "tags:4,focused_opacity:0.9,unfocused_opacity:0.8,app_id:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tags:5,focused_opacity:0.94,unfocused_opacity:0.86,app_id:^([Dd]iscord|[Ww]ebCord|[Vv]esktop|[Ww]hatsapp-for-linux|org.telegram.desktop|io.github.tdesktop_x64.TDesktop|teams-for-linux)$"

        # Settings and dialogs: float centered over the current tag
        # (rule values are capped at 255 bytes, hence two lines)
        "is_floating:1,width:0.7,height:0.7,focused_opacity:0.9,unfocused_opacity:0.8,app_id:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol|nm-applet|nm-connection-editor|blueman-manager|dev.deedles.Trayscale|wihotspot(-gui)?)$"
        "is_floating:1,width:0.7,height:0.7,focused_opacity:0.9,unfocused_opacity:0.8,app_id:^(gnome-disks|file-roller|org.gnome.FileRoller|xfce4-taskmanager|nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "is_floating:1,width:0.7,height:0.6,app_id:^xdg-desktop-portal-gtk$"
        "is_floating:1,width:0.7,height:0.6,title:^(Open Files|Save File|Add Folder to Workspace)$"
        "is_floating:1,width:0.6,height:0.5,title:wants to save"
        "is_floating:1,title:^(Authentication Required|File Operation Progress|Rename .*)$"
        "is_floating:1,app_id:^opensnitch_ui$,title:^(?!OpenSnitch Network Statistics)"
        "width:0.3,height:0.4,app_id:^opensnitch_ui$,title:^OpenSnitch v"
        "is_floating:1,width:0.6,height:0.7,app_id:^[Ff]erdium$"
        "is_floating:1,width:500,height:800,title:^_crx_" # Chromium extension popups, see extension-popups
        "is_floating:1,app_id:^(mpv|com.github.rafostar.Clapper)$"
        "is_floating:1,app_id:^[Ss]team$,title:^(?![Ss]team$)"
        "is_floating:1,app_id:^steam_app_default$"

        # Media
        "is_floating:1,is_global:1,offset_x:80,offset_y:-80,focused_opacity:0.95,unfocused_opacity:0.75,title:^Picture-in-Picture$"
        # Telegram media viewer fix
        "is_floating:1,no_animation:1,width:0.99,height:0.96,title:^Media viewer$"

        # Games (title:.+ skips wine's untitled helper window)
        "is_fullscreen:1,no_blur:1,app_id:^gamescope$"
        "is_fullscreen:1,no_blur:1,app_id:^steam_app_[0-9]+$,title:.+"

        # Opacity
        "focused_opacity:0.9,unfocused_opacity:0.8,app_id:^(gedit|org.gnome.TextEditor|mousepad|seahorse)$"

        # Scratchpads
        "is_named_scratchpad:1,width:0.5,height:0.6,app_id:^notes$"
      ];

      # Keep slurp's selection overlay out of screenshots
      layer_rule = [
        "no_animation:1,no_blur:1,layer_name:selection"
      ];
    };
  };
}
