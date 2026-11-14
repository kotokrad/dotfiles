{ config, inputs, pkgs, ... }: let
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
    focus-stack
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

    # Everything else lives in mango.conf so edits reload live without a switch. _optional because
    # the build-time `mango -p` check runs in a sandbox that can't see the repo.
    settings = {
      cursor_theme = config.stylix.cursor.name;
      cursor_size = config.stylix.cursor.size;
      source_optional = "~/nixos-config/config/mangowm/mango.conf";
    };
  };
}
