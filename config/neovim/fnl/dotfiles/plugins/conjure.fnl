(module dotfiles.plugins.conjure
  {autoload {nvim aniseed.nvim
             util dotfiles.util}})

(set nvim.g.conjure#eval#result_register "*")
(set nvim.g.conjure#log#botright true)
(set nvim.g.conjure#mapping#doc_word "gk")
(set nvim.g.conjure#extract#tree_sitter#enabled true)
