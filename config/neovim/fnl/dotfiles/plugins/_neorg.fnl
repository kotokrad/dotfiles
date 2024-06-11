(module dotfiles.plugins.neorg
  {autoload {neorg neorg}})

(neorg.setup
  {:load {:core.defaults {}
          :core.keybinds {:config {:default_keybinds true}}
                                      ; :neorg_leader "<leader>O"}} ; default
          :core.norg.concealer {}
          :core.norg.completion {:config {:engine "nvim-cmp"}}
          :core.norg.dirman {:config {:workspaces {:notes "~/notes"}
                                      :autodetect true
                                      :autochdir true}}}})
