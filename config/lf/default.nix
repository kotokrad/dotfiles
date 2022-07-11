{ pkgs, ... }:

let
  scope = pkgs.callPackage ./scope.nix { };
  cleaner = pkgs.callPackage ./cleaner.nix { };
  lfub = pkgs.callPackage ./lfub.nix { };
in
{
  programs.lf = {
    enable = true;

    # cmdKeyBindings = {};

    # commands = {};

    # keybindings = {};

    previewer.source = "${scope}/bin/scope";

    settings = {
      icons = true;
    };

    extraConfig = ''
      set cleaner ${cleaner}/bin/cleaner
    '';
  };

  home.shellAliases.lf = "${lfub}/bin/lfub";

  home.sessionVariables = {
    LF_ICONS = ''
      di=📁:\
      fi=📃:\
      tw=🤝:\
      ow=📂:\
      ln=⛓:\
      or=❌:\
      ex=🎯:\
      *.txt=📝:\
      *.mom=📝:\
      *.me=📝:\
      *.ms=📝:\
      *.png=🖼:\
      *.webp=🖼:\
      *.ico=🖼:\
      *.jpg=📸:\
      *.jpe=📸:\
      *.jpeg=📸:\
      *.gif=🖼:\
      *.svg=🗺:\
      *.tif=🖼:\
      *.tiff=🖼:\
      *.xcf=🖌:\
      *.html=🌎:\
      *.xml=📰:\
      *.gpg=🔒:\
      *.css=🎨:\
      *.pdf=📚:\
      *.djvu=📚:\
      *.epub=📚:\
      *.csv=📓:\
      *.xlsx=📓:\
      *.tex=📜:\
      *.md=📘:\
      *.r=📊:\
      *.R=📊:\
      *.rmd=📊:\
      *.Rmd=📊:\
      *.m=📊:\
      *.mp3=🎵:\
      *.opus=🎵:\
      *.ogg=🎵:\
      *.m4a=🎵:\
      *.flac=🎼:\
      *.wav=🎼:\
      *.mkv=🎥:\
      *.mp4=🎥:\
      *.webm=🎥:\
      *.mpeg=🎥:\
      *.avi=🎥:\
      *.mov=🎥:\
      *.mpg=🎥:\
      *.wmv=🎥:\
      *.m4b=🎥:\
      *.flv=🎥:\
      *.zip=📦:\
      *.rar=📦:\
      *.7z=📦:\
      *.tar.gz=📦:\
      *.z64=🎮:\
      *.v64=🎮:\
      *.n64=🎮:\
      *.gba=🎮:\
      *.nes=🎮:\
      *.gdi=🎮:\
      *.1=ℹ:\
      *.nfo=ℹ:\
      *.info=ℹ:\
      *.log=📙:\
      *.iso=📀:\
      *.img=📀:\
      *.bib=🎓:\
      *.ged=👪:\
      *.part=💔:\
      *.torrent=🔽:\
      *.jar=♨:\
      *.java=♨:\
    '';
  };
}
