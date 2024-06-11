{ config, lib, pkgs, ... }:

let
  customPlugins = pkgs.callPackage ./custom-plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
  };

  plugins = pkgs.vimPlugins // customPlugins;

  myVimPlugins = with plugins; [
  # UI
    gruvbox-nvim
    kanagawa-nvim
    lualine-nvim
    lush-nvim
    neoscroll-nvim
    nvim-colorizer-lua
    nvim-web-devicons
    vim-buftabline
    vim-devicons
    dressing-nvim                    # improve default UI
    # material-nvim
    # srcery-vim
    # tokyonight-nvim

  # UTILITY
    aniseed                          # write configs in Fennel!
    bclose-vim                       # Bclose
    camelcasemotion                  # camelCase motions
    editorconfig-vim
    lightspeed-nvim                  # highlights keys to move quickly
    neo-tree-nvim
    plenary-nvim                     # lua utils
    tabular                          # align code verically (haskell etc)
    telescope-fzy-native-nvim        # FZY style sorter that is compiled
    telescope-nvim
    toggleterm-nvim                  # floating termial; used only for lazygit for now
    undotree
    vim-commentary                   # comment some code
    vim-repeat                       # repeat plugin commands with (.)
    vim-sensible                     # sensible defaults
    vim-signature                    # display marks as signs
    nvim-surround                    # add/change/delete surrounding delimiter pairs with ease. Written with ❤️ in Lua.
    which-key-nvim                   # spacemacs-like menu and key bindings
    # impatient-nvim                   # speed up loading lua modules
    # nvim-notify                      # used with `sniprun`

  # DEV
    cmp-buffer
    cmp-conjure
    cmp-nvim-lsp
    cmp-path
    cmp_luasnip
    conjure                          # interactive lisp development
    formatter-nvim
    gitsigns-nvim
    haskell-vim
    lsp-colors-nvim                  # add missing LSP highlight groups for unsupported color schemes
    luasnip
    friendly-snippets                # collection of snippets for different languages
    numb-nvim                        # peek line number
    nvim-autopairs
    nvim-cmp
    nvim-lspconfig
    nvim-lsputils                    # used for code actions
    # nvim-treesitter.withAllGrammars
    nvim-treesitter
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring    # commenting tsx
    parinfer-rust
    playground                       # tree-sitter playground
    purescript-vim
    trouble-nvim                     # diagnostic list
    vim-css-color                    # preview css colors
    vim-easy-align
    vim-jsx-pretty
    vim-nix                          # nix support (highlighting, etc)
    null-ls-nvim                     # lsp
    # nvim-spectre
    # sniprun                          # evaluate code snippets
    # symbols-outline-nvim             # TODO: use `aerial.nvim` instead
    todo-comments-nvim               # highlight, list and search todo comments

  # MISC
    vimwiki                          # notes

  # TODO: check out
    # indent-blankline-nvim
    # nvim-ts-rainbow
    # barbar-nvim
    # sidebar-nvim
    # ctrlsf-vim                     # edit file in place after searching with ripgrep
    # dhall-vim                      # Syntax highlighting for Dhall lang
    # fzf-hoogle                     # search hoogle with fzf
    # ghcid                          # ghcid for Haskell
    # multiple-cursors               # Multiple cursors selection, etc
    # neomake                        # run programs asynchronously and highlight errors
    # nerdcommenter                  # code commenter
    # quickfix-reflector-vim         # make modifications right in the quickfix window
    # tender-vim                     # a clean dark theme
    # vim-airline                    # bottom status bar
    # vim-airline-themes
    # vim-easy-align                 # alignment plugin
    # vim-fish                       # fish shell highlighting
    # vim-fugitive                   # git plugin
    # vim-gtfo                       # go to terminal or file manager
    # vim-mergetool                  # git mergetool for nvim
    # vim-tmux                       # syntax highlighting for tmux conf file and more

  # TEMP
    # vim-better-sml                   # SML plugin; NOTE: only for course
  ];

  # neovim-nightly = pkgs.callPackage ./nightly.nix {};
in
{
  programs.neovim = {
    enable       = true;
    extraConfig  = builtins.readFile ./init.vim;
    # package      = neovim-nightly;
    plugins      = myVimPlugins;
    vimAlias     = false;
    vimdiffAlias = true;
    withNodeJs   = true;
    withPython3  = false;
    withRuby     = false;
    extraLuaPackages = ps: [ ps.jsregexp ]; # used in `luasnip` snippets
  };

  home.packages = with pkgs; [
    neovim-remote
    glib                    # nvim-tree uses `gio trash`
  ];

  xdg.configFile = {
    "nvim/queries".source = ./queries;
    "nvim/fnl".source = ./fnl;
    "nvim/fnl".onChange = ''
      rm -rf /home/kotokrad/.config/nvim/lua
      ${pkgs.neovim}/bin/nvim --headless -c "lua require(\"aniseed.env\").init()" -c "q"
    '';
    # "nvim/ftplugin".source = ./ftplugin;
  };
}
