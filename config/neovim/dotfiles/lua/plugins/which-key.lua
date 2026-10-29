return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },

    -- Replace mappings
    { "<leader>r", ":%s//g<left><left>", desc = "Replace", silent = false },
    { "<leader>r", ":s//g<left><left>", desc = "Replace", mode = "v", silent = false },

    -- Undo tree
    { "<leader>u", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", desc = "Undotree" },

    -- Buffer management
    { "<leader>b", group = "buffer" },
    { "<leader>bo", function()
        -- Delete all hidden buffers
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) == 1 then
            local wins = vim.fn.win_findbuf(buf)
            if #wins == 0 then
              vim.api.nvim_buf_delete(buf, {})
            end
          end
        end
      end, desc = "Only (delete hidden buffers)" },
    { "<leader>bO", function()
        -- Force delete all hidden buffers
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) == 1 then
            local wins = vim.fn.win_findbuf(buf)
            if #wins == 0 then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        end
      end, desc = "Only! (force delete hidden buffers)" },

    -- Terminal
    -- { "<leader>t", group = "terminal" },
    -- { "<leader>tt", ":TermExec size=16 cmd=''<left>", desc = "Terminal", silent = false },

    -- Git (normal mode)
    { "<leader>g", group = "git" },
    { "<leader>gB", "<cmd>lua require'gitsigns'.blame_line{full=true}<cr>", desc = "Blame line (full)" },
    { "<leader>gR", "<cmd>lua require'gitsigns'.reset_buffer()<cr>", desc = "Reset buffer" },
    { "<leader>gS", "<cmd>lua require'gitsigns'.stage_buffer()<cr>", desc = "Stage buffer" },
    { "<leader>gU", "<cmd>lua require'gitsigns'.reset_buffer_index()<cr>", desc = "Reset buffer index" },
    { "<leader>gb", "<cmd>lua require'gitsigns'.blame_line{full=false}<cr>", desc = "Blame line" },
    { "<leader>gp", "<cmd>lua require'gitsigns'.preview_hunk()<cr>", desc = "Preview hunk" },
    { "<leader>gr", "<cmd>lua require'gitsigns'.reset_hunk()<cr>", desc = "Reset hunk" },
    { "<leader>gs", "<cmd>lua require'gitsigns'.stage_hunk()<cr>", desc = "Stage hunk" },
    { "<leader>gt", "<cmd>lua require'gitsigns'.toggle_current_line_blame()<cr>", desc = "Toggle line blame" },
    { "<leader>gu", "<cmd>lua require'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo staging" },
    { "<leader>gg", "<cmd>lua require('dotfiles.plugins.toggleterm').lazygit_toggle()<cr>", desc = "Lazygit" },

    -- Git (visual mode)
    { "<leader>g", group = "git", mode = "v" },
    { "<leader>gr", "<cmd>lua require'gitsigns'.reset_hunk({vim.fn.line('.'), vim.fn.line('v')})<cr>", desc = "Reset", mode = "v" },
    { "<leader>gs", "<cmd>lua require'gitsigns'.stage_hunk({vim.fn.line('.'), vim.fn.line('v')})<cr>", desc = "Stage", mode = "v" },

    -- LSP
    { "<leader>l", group = "lsp" },
    { "<leader>le", "<cmd> lua vim.diagnostic.open_float({ focusable = false })<cr>", desc = "Expand Line Error" },
    -- { "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", desc = "Format" },
    { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<leader>ll", "<cmd>TroubleToggle<cr>", desc = "List Toggle [Trouble]" },
    -- { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    { "<leader>lq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix" },
    -- { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },

    -- LSP non-prefixed
    { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to Definition" },
    { "gr", function()
        require("telescope.builtin").lsp_references()
      end, desc = "Find References" },

    -- Files
    { "<leader>F", "<cmd>Oil<cr>", desc = "Files" },
    { "<leader>f", "<cmd>split +Oil | lua vim.w.is_oil_split = true<cr>", desc = "Files (split)" },

    -- Compile mode
    { "<localleader>r", "<cmd>Recompile<cr>", desc = "Recompile" },
    { "<localleader>c", function()
        local command = shell_prompt({ prompt = "comp " })
        if command ~= "" then
          if vim.w.is_oil_split then
            local current_dir = require("oil").get_current_dir()
            vim.g.compilation_directory = current_dir
          end
          vim.cmd("Compile " .. command)
          vim.g.compilation_directory = nil
        end
      end, desc = "Compile" },

    -- Terminal
    { "<leader>t", function()
        local command = shell_prompt()
        if command ~= "" then

          -- local current_dir = require("oil").get_current_dir()

          local Terminal  = require('toggleterm.terminal').Terminal
          local term = Terminal:new({
            -- cmd = command,
            dir = nil,
            hidden = false,
            close_on_exit = true,
            direction = "horizontal",
            size = 15,
          })

          _G.term = Terminal:new({
            -- cmd = command,
            dir = nil,
            hidden = false,
            close_on_exit = false,
            direction = "horizontal",
            size = 15,
          })


          term:toggle()
          term:send(command)

        end
      end, desc = "Terminal" },

    -- File/Telescope
    -- { "<leader>f", group = "file" },
    -- { "<leader>ff", function()
    --     require("telescope.builtin").find_files()
    --   end, desc = "Find" },
    -- { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    -- { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },

    -- Help/Telescope
    -- { "<leader>h", group = "help" },
    -- { "<leader>hC", "<cmd>Telescope command_history<cr>", desc = "Command history" },
    -- { "<leader>hH", "<cmd>Telescope highlights<cr>", desc = "Highlights" },
    -- { "<leader>hc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    -- { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    -- { "<leader>h", "<cmd>Telescope keymaps<cr>", desc = "Help (keymaps)" },
  },
}
