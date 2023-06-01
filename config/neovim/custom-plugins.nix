{ pkgs, buildVimPlugin, vimUtils, fetchFromGitHub, rustPlatform }:

{
  vim-buftabline = buildVimPlugin {
    name = "vim-buftabline";
    src = fetchFromGitHub {
      owner  = "ap";
      repo   = "vim-buftabline";
      rev    = "73b9ef5";
      sha256 = "1vs4km7fb3di02p0771x42y2bsn1hi4q6iwlbrj0imacd9affv5y";
    };
  };

#   vim-better-sml = buildVimPlugin {
#     name = "vim-better-sml";
#     src = fetchFromGitHub {
#       owner  = "jez";
#       repo   = "vim-better-sml";
#       rev    = "1f36431";
#       sha256 = "0v5wbbjxz7k3ifpnl5l06zkwp3wfcs52bzwhs9i89f9g1wkkgq74";
#     };
#     nativeBuildInputs = [ pkgs.mlton ];
#   };

#   janet-vim = buildVimPlugin {
#     name = "janet-vim";
#     src = fetchFromGitHub {
#       owner  = "janet-lang";
#       repo   = "janet.vim";
#       rev    = "294538b";
#       sha256 = "sha256:1x81n4sdxza5hx3fg2pnzkj4f1sv87i7spldg8rsqpglx7da4clx";
#     };
#     nativeBuildInputs = [ pkgs.janet ];
#   };

  parinfer-rust = with pkgs;
  let
    parinfer-src = fetchFromGitHub {
      owner  = "eraserhd";
      repo   = "parinfer-rust";
      rev    = "189d261";
      sha256 = "sha256-b+bnWeoYNLOtB7RHN7asfaQoSoOzbxN1vlkNcYlvMIA=";
    };
    parinfer-rust-bin = rustPlatform.buildRustPackage rec {
      pname = "parinfer-rust";
      version = "189d261";
      src = parinfer-src;

      cargoSha256 = "sha256-OnUwWaybYxMzBBsBhN7vrMZ6LRHTNEk6YcWwTfLDdl8=";

      nativeBuildInputs = [ llvmPackages.clang ];
      buildInputs = [ llvmPackages.libclang ];
      LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    };
  in
  buildVimPlugin {
    name = "parinfer-rust";
    src = parinfer-src;
    buildPhase = ''
      mkdir -p ./target/release
      ln -s ${parinfer-rust-bin}/bin/parinfer-rust ./target/release/
      ln -s ${parinfer-rust-bin}/lib/libparinfer_rust.so ./target/release/
    '';
  };

  # aniseed = vimUtils.buildVimPluginFrom2Nix {
  #   pname = "aniseed";
  #   version = "v3.31.0";
  #   src = fetchFromGitHub {
  #     owner  = "Olical";
  #     repo   = "aniseed";
  #     rev    = "9892a40";
  #     sha256 = "sha256-f6YxGki6AEC5r4iAR4boX9Co5h2QuT1ucogtFdXacLU=";
  #   };
  # };

#   nvim-treesitter = buildVimPlugin {
#     pname = "nvim-treesitter";
#     version = "5e894bd";
#     src = fetchFromGitHub {
#       owner  = "nvim-treesitter";
#       repo   = "nvim-treesitter";
#       rev    = "5e894bd";
#       sha256 = "sha256-l4iZPzor/lwQGQ8ogR1mAzKZpp+KJfOYEWFyeE6+hiY=";
#     };
#   };

#   sniprun =
#   let
#     sniprun-bin = rustPlatform.buildRustPackage rec {
#       pname = "sniprun";
#       version = "v1.0.0";
#       src = fetchFromGitHub {
#         owner = "michaelb";
#         repo = pname;
#         rev = version;
#         sha256 = "sha256-ggGwn0aVc3aa0VC4oPrG+cMlAIhsWZoEYVhnKFXkh0Y=";
#       };
#       cargoSha256 = "sha256-8c3atAQxr04p9XUoqGqeVguKdwT9vVBidY6NlDjKITU=";
#       doCheck = false;
#     };
#   in buildVimPlugin {
#     name = "sniprun";
#     src = builtins.fetchTarball {
#       name   = "sniprun-a42fa2f";
#       url    = "https://github.com/michaelb/sniprun/archive/a42fa2f.tar.gz";
#       sha256 = "0q1jw6dh2rxl61zis1dlcjbydizz05kkg8cqhwyldhdryybxnc64";
#     };
#     buildPhase = ''
#       mkdir -p target/release
#       ln -s ${sniprun-bin}/bin/sniprun target/release/sniprun
#     '';
#   };

}
