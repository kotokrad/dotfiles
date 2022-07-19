{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    bindings = {
      "WHEEL_UP"    = "add volume 2";
      "WHEEL_DOWN"  = "add volume -2";
      "UP"          = "add volume 5";
      "DOWN"        = "add volume -5";
      "RIGHT"       = "no-osd seek  2 exact";
      "LEFT"        = "no-osd seek -2 exact";
      "Alt+LEFT"    = "seek -15 exact";
      "Alt+RIGHT"   = "seek 15 exact";
      "Ctrl+LEFT"   = "seek -60";
      "Ctrl+RIGHT"  = "seek 60";
      "Shift+LEFT"  = "no-osd sub-seek -1";
      "Shift+RIGHT" = "no-osd sub-seek  1";
      "["           = "add speed -0.25";
      "]"           = "add speed 0.25";
      "{"           = "add speed -1";
      "}"           = "add speed 1";

      # Fix-sub-timing
      "Ctrl+z"      = "sub-step -1";
      "Ctrl+x"      = "sub-step  1";
    };

    profiles = {
      big-cache = {
        cache = "yes";
        demuxer-seekable-cache = "yes";
        demuxer-max-back-bytes = "512MiB";
        demuxer-readahead-secs = 600;
        hls-bitrate = "min";
      };
      "1080p" = {
        ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      };
    };

    config = {
      # HQ
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      # Clearer downmixing to stereo speakers/headphones
      audio-channels = 2;

      sub-file-paths = "**";
      audio-file-paths="**";

      sub-auto = "fuzzy";
      audio-file-auto = "fuzzy";

      term-status-msg = "Time: \${time-pos}";
      osd-font-size = 16;
      script-opts-append = "ytdl_hook-ytdl_path=yt-dlp"; # using yt-dlp instead of youtube-dl
    };
  };

  xdg.mimeApps.defaultApplications = {
    "video/x-matroska" = "mpv.desktop";
  };

  home.packages = [
    # (import ./umpv.nix)
  ];
}
