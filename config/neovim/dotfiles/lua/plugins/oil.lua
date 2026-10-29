return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = false,
    constrain_cursor = "name",
    skip_confirm_for_simple_edits = true,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<C-p>"] = false,
      ["R"] = "actions.refresh",
      ["<Backspace>"] = "actions.parent",
      ["H"] = "actions.parent",
      ["L"] = "actions.select",
      ["<Tab>"] = "actions.preview",
      ["J"] = "actions.preview_scroll_down",
      ["K"] = "actions.preview_scroll_up",
      ["q"] = {
        callback = function()
          vim.g.compilation_directory = nil
          require("oil").close()
          if vim.w.is_oil_split then
            vim.cmd("close")
          end
        end
      },
      ["!"] = {
        callback = function()
          local current_dir = require("oil").get_current_dir()
          vim.g.compilation_directory = current_dir
          vim.api.nvim_feedkeys(":Compile ", "n", false)
        end
      },
    },
    view_options = {
      show_hidden = true,
    },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
