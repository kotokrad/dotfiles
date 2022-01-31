(module dotfiles.init)

(require :dotfiles.core)
(require :dotfiles.mappings)

;; Plugins
(require :dotfiles.plugins.auto-pairs)
(require :dotfiles.plugins.colorizer)
(require :dotfiles.plugins.conjure)
(require :dotfiles.plugins.devicons)
(require :dotfiles.plugins.gitsigns)
(require :dotfiles.plugins.lspconfig)
(require :dotfiles.plugins.lualine)
(require :dotfiles.plugins.luasnip)
(require :dotfiles.plugins.neoscroll)
(require :dotfiles.plugins.neuron)
(require :dotfiles.plugins.numb)
(require :dotfiles.plugins.nvim-cmp)
(require :dotfiles.plugins.nvim-tree)
(require :dotfiles.plugins.telescope)
(require :dotfiles.plugins.toggleterm)
(require :dotfiles.plugins.treesitter)
(require :dotfiles.plugins.trouble)
(require :dotfiles.plugins.which-key)
; (require :dotfiles.plugins.neorg)

;; Non-lua plugin options
(require :dotfiles.plugins.misc)

;; Custom colors
(require :dotfiles.highlights)
