(module dotfiles.plugins.nvim-tree
  {autoload {util dotfiles.util
             nvim aniseed.nvim
             tree nvim-tree}})

(set nvim.g.nvim_tree_git_hl 1)
(set nvim.g.nvim_tree_refresh_wait 300)

(tree.setup {:diagnostics {:enable true}
             :update_focused_file {:enable true}
             :view {:width 34
                    :mappings {:list [{:key "d" :action "trash"}
                                      {:key "D" :action "remove"}]}}
             :actions {:open_file {:resize_window true}}})

;; Toggle without focusing
(util.noremap :n :<c-b> ":lua require'nvim-tree'.toggle(false, true)<cr>")
