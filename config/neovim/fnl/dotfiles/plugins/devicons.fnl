(module dotfiles.plugins.nvim-web-devicons
  {autoload {devicons nvim-web-devicons}})

(devicons.setup
  {:override {"spec.ts" {:icon ""
                         :color "#928374"
                         :name "SpecTs"}}})
