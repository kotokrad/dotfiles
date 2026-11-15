{ config, pkgs, ... }:

let
  lockQml = "${config.xdg.configHome}/quickshell/Lock.qml";

  # Starts the lock screen (dotfiles/Lock.qml) unless it's up, then waits until it covers every
  # screen. `quickshell-lock 5`: any input unlocks for the first 5 s (idle locks)
  quickshell-lock = pkgs.writeShellApplication {
    name = "quickshell-lock";
    runtimeInputs = [
      config.programs.quickshell.package
      config.wayland.windowManager.mango.package # mmsg, for the keyboard layout
      pkgs.coreutils
      pkgs.libnotify
    ];
    text = ''
      ipc() { quickshell ipc --path ${lockQml} call lock "$@" 2>/dev/null; }

      if systemctl --user --quiet is-active quickshell-lock; then
        # Locking again (the lid closed right after an idle lock) asks for the password
        ipc endGrace || true
      else
        # A transient unit, so a crashed lock screen restarts and takes over the lock mango keeps.
        # No restart limit: while it's down, mango shows the desktop (allow_lock_transparent).
        # It gets this PATH: the systemd manager's has no mmsg on the macbook
        systemd-run --user --quiet --collect --unit=quickshell-lock \
          --property=Restart=on-failure --property=RestartSec=200ms \
          --property=StartLimitIntervalSec=0 \
          --setenv=PATH="$PATH" --setenv=LOCK_GRACE_UNTIL=$(( $(date +%s) + ''${1:-0} )) \
          quickshell --path ${lockQml} || true
      fi

      for _ in $(seq 50); do
        [ "$(ipc secure)" = true ] && exit 0
        sleep 0.1
      done
      notify-send --urgency=critical "Lock screen didn't start" "journalctl --user -u quickshell-lock"
      exit 1
    '';
  };

  # Runs under a sleep delay lock: when logind announces sleep, locks and lets go once the lock
  # screen is up. The service starts it again after waking
  lock-before-sleep = pkgs.writeShellApplication {
    name = "lock-before-sleep";
    runtimeInputs = [ pkgs.glib quickshell-lock ];
    text = ''
      grep -q -m1 -F 'PrepareForSleep (true,)' < <(gdbus monitor --system \
        --dest org.freedesktop.login1 --object-path /org/freedesktop/login1)
      quickshell-lock || true
    '';
  };
in
{
  home.packages = [ quickshell-lock ];

  # hypridle can't wait for the lock screen before sleep (that takes Hyprland's lock-notify).
  # logind refuses new delay locks while sleep is pending, so one is held all the time
  systemd.user.services.lock-before-sleep = {
    Unit = {
      Description = "Lock the screen before sleep";
      PartOf = [ "mango-session.target" ];
      After = [ "mango-session.target" ];
      StartLimitIntervalSec = 0; # restarts fail until the system is actually asleep
    };
    Service = {
      ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --mode=delay --who=quickshell-lock "
        + "--why='Locking the screen' ${lock-before-sleep}/bin/lock-before-sleep";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "mango-session.target" ];
  };
}
