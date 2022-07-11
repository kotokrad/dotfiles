{ pkgs }:

with pkgs;

let
  file = "${pkgs.file}/bin/file";
  ueberzug = "${pkgs.ueberzug}/bin/ueberzug";
  ffmpegthumbnailer = "${pkgs.ffmpegthumbnailer}/bin/ffmpegthumbnailer";
  pdftoppm = "${pkgs.poppler_utils}/bin/pdftoppm";
  atool = "${pkgs.atool}/bin/atool";
  lynx = "${pkgs.lynx}/bin/lynx";
in
writeShellScriptBin "scope" ''
  # Luke Smith's file preview handler for lf.
  # https://github.com/LukeSmithxyz/voidrice

  set -C -f
  IFS="$(printf '%b_' '\n')"; IFS="''${IFS%_}"

  image() {
    if [ -n "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && command -V ${ueberzug} >/dev/null 2>&1; then
      printf '{"action": "add", "identifier": "PREVIEW", "x": "%s", "y": "%s", "width": "%s", "height": "%s", "scaler": "contain", "path": "%s"}\n' "$4" "$5" "$(($2-1))" "$(($3-1))" "$1" > "$FIFO_UEBERZUG"
    else
      mediainfo "$1"
    fi
  }

  ifub() {
    [ -n "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && command -V ${ueberzug} >/dev/null 2>&1
  }

  # Note that the cache file name is a function of file information, meaning if
  # an image appears in multiple places across the machine, it will not have to
  # be regenerated once seen.

  case "$(${file} --dereference --brief --mime-type -- "$1")" in
    image/*) image "$1" "$2" "$3" "$4" "$5" ;;
    text/html) ${lynx} -width="$4" -display_charset=utf-8 -dump "$1"  ;;
    text/troff) man ./ "$1" | col -b ;;
    text/* | */xml | application/json) bat --terminal-width "$4" -f "$1" ;;
    application/zip) ${atool} --list -- "$1" ;;
          audio/* | application/octet-stream) mediainfo "$1" || exit 1;;
    video/* )
      CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/lf/thumb.$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f "$1")" | sha256sum | awk '{print $1}')"
      [ ! -f "$CACHE" ] && ${ffmpegthumbnailer} -i "$1" -o "$CACHE" -s 0
      image "$CACHE" "$2" "$3" "$4" "$5"
      ;;
          */pdf)
      CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/lf/thumb.$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f "$1")" | sha256sum | awk '{print $1}')"
      [ ! -f "$CACHE.jpg" ] && ${pdftoppm} -jpeg -f 1 -singlefile "$1" "$CACHE"
      image "$CACHE.jpg" "$2" "$3" "$4" "$5"
      ;;
          *opendocument*) odt2txt "$1" ;;
    application/pgp-encrypted) gpg -d -- "$1" ;;
  esac
  exit 1
''
