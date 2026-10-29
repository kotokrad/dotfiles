{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    # sensibleOnTop = true;

    baseIndex = 1;
    escapeTime = 0;
    clock24 = true;
    mouse = true;
    focusEvents = true;
    historyLimit = 100000;
    keyMode = "vi";
    plugins = []; # TOTO
    prefix = "C-a";
    terminal = "screen-256color";

    # Session manager
    tmuxp.enable = true;

    extraConfig = ''
    '';
  };

}
