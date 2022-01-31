{ pkgs }:

pkgs.neovim-unwrapped.overrideAttrs (
  old: {
    name    = "neovim-v0.7.0-dev+839-g09d270bce";
    version = "09d270b";

    src = pkgs.fetchFromGitHub {
      owner  = "neovim";
      repo   = "neovim";
      rev    = "09d270bcea5f81a0772e387244cc841e280a5339";
      sha256 = "sha256-jUt4yGclE0627CxsaSlgGr8LH+Ek9dSpCHACv917N5c=";
    };

    buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
  }
)
