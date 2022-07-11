(module dotfiles.plugins.toggleterm
  {autoload {util dotfiles.util
             toggleterm toggleterm
             terminal toggleterm.terminal}})

(toggleterm.setup {:highlights {:NormalFloat {:guibg "Normal"}}})

(local lazygit (terminal.Terminal:new {:cmd "lazygit"
                                       :hidden true
                                       :dir "git_dir"
                                       :direction "float"}))

(defn lazygit_toggle []
  (lazygit:toggle))

(util.map-group {:prefix :<leader>}
                {:g {:name "+git"
                     :g ["<cmd>lua require('dotfiles.plugins.toggleterm').lazygit_toggle()<cr>" "Lazygit"]}})
