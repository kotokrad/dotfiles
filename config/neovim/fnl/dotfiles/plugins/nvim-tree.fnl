(module dotfiles.plugins.nvim-tree
  {autoload {util dotfiles.util
             nvim aniseed.nvim
             tree nvim-tree}})

(set nvim.g.nvim_tree_git_hl 1)
(set nvim.g.nvim_tree_refresh_wait 300)

(tree.setup {:auto_close true
             :diagnostics {:enable true}
             :update_focused_file {:enable true}
             :view {:width 34
                    :auto_resize true}})


(util.noremap :n :<c-b> ":NvimTreeToggle<cr>")
