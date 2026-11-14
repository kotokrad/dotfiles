{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      settings.alias = {
        hist = "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short";
      };
      lfs.enable = true;
      lfs.skipSmudge = true;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options.syntax-theme = "gruvbox-dark";
    };
    lazygit = {
      enable = true;
      settings.git.diffRenderers = [{
        command ="${pkgs.delta}/bin/delta --dark --paging=never";
        colorArg = "always";
      }];
    };
  };
}
