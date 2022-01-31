(module dotfiles.plugins.toggleterm
  {autoload {util dotfiles.util
             toggleterm toggleterm
             terminal toggleterm.terminal}})

(local lazygit (terminal.Terminal:new {:cmd "lazygit"
                                       :hidden true
                                       :dir "git_dir"
                                       :direction "float"}))
                                       ; :float_opts {:border "double"}}))


(defn lazygit_toggle []
  (lazygit:toggle))


(util.map-group {:prefix :<leader>}
                {:g {:name "+git"
                     :g ["<cmd>lua require('dotfiles.plugins.toggleterm').lazygit_toggle()<cr>" "Lazygit"]}})
