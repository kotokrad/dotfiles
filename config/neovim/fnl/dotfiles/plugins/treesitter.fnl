(module dotfiles.plugins.treesitter
  {autoload {treesitter nvim-treesitter.configs
             parsers nvim-treesitter.parsers}})

; (set parsers.list.norg
;      {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg"
;                      :files [ "src/parser.c" "src/scanner.cc"]
;                      :branch "main"}})

; (set parsers.list.markdown
;      {:install_info {:url "https://github.com/ikatyang/tree-sitter-markdown"
;                      :files [ "src/parser.c" "src/scanner.cc"]}
;       :filetype "markdown"})

; (set parsers.list.janet
;      {:install_info {:url "https://github.com/GrayJack/tree-sitter-janet"
;                      :files [ "src/parser.c" "src/scanner.c"]}
;       :filetype "janet"})

(treesitter.setup
  {:ensure_installed :all
   :parser_install_dir "~/.local/share/nvim/site"
   :ignore_install ["agda" "blueprint" "gitattributes" "gitignore" "hlsl" "jsonnet" "menhir" "meson" "racket" "sxhkdrc" "twig"]
   :highlight {:enable true
               :additional_vim_regex_highlighting false}
   :indent {:enable true}
   :textobjects {:select {:enable true
                          ;; Automatically jump forward to textobj, similar to targets.vim
                          :lookahead true
                          :keymaps {:af "@function.outer"
                                    :if "@function.inner"}}}})
