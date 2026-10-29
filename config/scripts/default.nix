{pkgs, ...}: {
  home.packages = [
    (import ./squirtle.nix { inherit pkgs; })
    (import ./web-search.nix { inherit pkgs; })
    (import ./rofi-launcher.nix { inherit pkgs; })
  ];
}
