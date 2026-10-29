return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring"
  },
  config = function ()
    require('ts_context_commentstring').setup({
      enable_autocmd = false,
    })

    require('nvim-treesitter').install { 'all' }

    -- local configs = require("nvim-treesitter.configs")
    -- configs.setup({
    --   ensure_installed = "all",
    --   -- ensure_installed = {
    --   --   "javascript",
    --   --   "typescript",
    --   --   "jsx",
    --   --   "tsx",
    --   --   "html",
    --   --   "css",
    --   --   "lua",
    --   --   "bash",
    --   --   "elixir",
    --   -- },
    --   ignore_install = { "ipkg" }, -- failing
    --   auto_install = true,
    --   sync_install = false,
    --   highlight = { enable = true },
    --   indent = { enable = true },
    --
    --   incremental_selection = {
    --     enable = true,
    --     keymaps = {
    --       init_selection = "<Enter>", -- set to `false` to disable one of the mappings
    --       node_incremental = "<Enter>",
    --       scope_incremental = false,
    --       node_decremental = "<Backspace>",
    --     },
    --   },
    -- })
  end
}
