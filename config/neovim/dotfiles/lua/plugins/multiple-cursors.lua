return { "brenton-leighton/multiple-cursors.nvim",
  version = "*",
  opts = {
    pre_hook = function()
      vim.opt.ignorecase = false
      vim.b.completion = false
      require('nvim-autopairs').disable()
    end,
    post_hook = function()
      vim.opt.ignorecase = true
      vim.b.completion = true
      require('nvim-autopairs').enable()
    end,
    custom_key_maps = {
      -- w
      {{"n", "x"}, "<localleader>w", function(_, count)
        if  count ~=0 and vim.api.nvim_get_mode().mode == "n" then
          vim.cmd("normal! " .. count)
        end
        require('spider').motion('w')
      end},

      -- e
      {{"n", "x"}, "<localleader>e", function(_, count)
        if  count ~=0 and vim.api.nvim_get_mode().mode == "n" then
          vim.cmd("normal! " .. count)
        end
        require('spider').motion('e')
      end},

      -- b
      {{"n", "x"}, "<localleader>b", function(_, count)
        if  count ~=0 and vim.api.nvim_get_mode().mode == "n" then
          vim.cmd("normal! " .. count)
        end
        require('spider').motion('b')
      end},
    },
  },
}
