return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    local toggleterm = require('toggleterm')
    toggleterm.setup({
      highlights = {
        NormalFloat = {
          guibg = "#282828"
        }
      }
    })

    function _set_terminal_keymaps()
      vim.keymap.set('t', '<Tab>', [[<cmd>wincmd p<cr>]], { buffer = 0 })
      vim.keymap.set('t', '<M-j>', [[<cmd>wincmd j<cr>]], { buffer = 0 })
      vim.keymap.set('t', '<M-k>', [[<cmd>wincmd k<cr>]], { buffer = 0 })
      vim.keymap.set('t', '<M-h>', [[<cmd>wincmd h<cr>]], { buffer = 0 })
      vim.keymap.set('t', '<M-l>', [[<cmd>wincmd l<cr>]], { buffer = 0 })
    end

    vim.cmd('autocmd! TermOpen term://*toggleterm#* lua _set_terminal_keymaps()')


    local Terminal  = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, dir = "git_dir", direction = "float" })
    local wk = require('which-key')

    function _lazygit_toggle()
      lazygit:toggle()
    end

    wk.add({
      { "<leader>gg", "<cmd>lua _lazygit_toggle()<cr>", desc = "Lazygit" },
    })

  end
}
