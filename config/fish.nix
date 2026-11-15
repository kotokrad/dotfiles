{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      any-nix-shell fish --info-right | source
      set -U fish_greeting ""
      set -g fish_transient_prompt 1
    '';
    generateCompletions = false;
  };

  programs.fzf = {
    enable = true;
    fileWidget.fish.command = "";      # disable Ctrl-T
    changeDirWidget.fish.command = ""; # disable Alt-C
  };

  home.shellAliases = {
    gs = "git status";
    gh = "git hist";
    lofi = "mpv --no-video --volume=50 https://youtu.be/jfKfPfyJRdk";
    sync-watch = "watch -d grep -e Dirty: -e Writeback: /proc/meminfo";
    # dump keystrokes https://web.archive.org/web/20191220190018/https://www.drbunsen.org/vim-croquet/
    # vim = ''nvim -w ~/.vimlog "$argv"'';
    mkdir = "mkdir -p";
  };

  home.packages = [ pkgs.any-nix-shell ]; # fish support for nix shell (like show package names from `nix-shell -p`)

  xdg.configFile."fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
}
