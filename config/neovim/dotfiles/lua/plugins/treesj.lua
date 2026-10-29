return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({ use_default_keymaps = false })
    local wk = require('which-key')
    wk.add({
      { "<localleader>s", "<cmd>lua require('treesj').toggle()<cr>", desc = "Toggle split/join" },
    })
  end,
}
