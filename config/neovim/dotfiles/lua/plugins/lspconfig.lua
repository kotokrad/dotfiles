return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Useful status updates for LSP.
    { "j-hui/fidget.nvim", opts = {} },
    -- Completion capabilities
    { 'saghen/blink.cmp' },
    -- "hrsh7th/cmp-nvim-lsp",
    -- Better UI for code actions and locations
    -- "nvimdev/lsputil",
    -- Null-ls successor for formatters/linters
    "nvimtools/none-ls.nvim",
  },
  config = function()
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities(lsp_capabilities)
    -- capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local null_ls = require("null-ls")

    -- -- Setup none-ls (null-ls)
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.mix,
      },
    })


    -- On attach handler
    local function on_attach(client, bufnr)
      -- Keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, silent = true, desc = "LSP hover" })
      vim.keymap.set("n", "]f", function()
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
      end, { buffer = bufnr, silent = true, desc = "Next error" })
      vim.keymap.set("n", "[f", function()
        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end, { buffer = bufnr, silent = true, desc = "Previous error" })
    end

    -- vim.lsp.config('ts_ls', {
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    -- })

    vim.lsp.config('*', {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config('ts_ls', {
      -- capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        -- Disable formatting, use null-ls instead
        client.server_capabilities.documentFormattingProvider = false
      end,
    })

    vim.lsp.config('rust_analyzer', {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config('zls', {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config('elixirls', {
      cmd = { "elixir-ls" },
    })

    vim.lsp.config('emmet_ls', {
      filetypes = { "css", "html", "javascript", "javascriptreact", "typescriptreact" },
    })

    -- Configure diagnostic display
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 2,
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "💡",
          [vim.diagnostic.severity.INFO] = " ",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticSign",
          [vim.diagnostic.severity.WARN] = "DiagnosticSign",
          [vim.diagnostic.severity.HINT] = "DiagnosticSign",
          [vim.diagnostic.severity.INFO] = "DiagnosticSign",
        }
      },
      float = {
        focusable = false,
      },
    })

    -- Setup lsputil handlers
    -- vim.lsp.handlers["textDocument/codeAction"] = require("lsputil.codeAction").code_action_handler
    -- vim.lsp.handlers["textDocument/definition"] = require("lsputil.locations").definition_handler
    -- vim.lsp.handlers["textDocument/references"] = require("lsputil.locations").references_handler

    -- Custom diagnostic signs
    local signs = {
      Error = " ",
      Warn = " ",
      Hint = "💡",
      Info = " ",
    }

    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, {
        text = icon,
        texthl = hl,
        numhl = "",
      })
    end

    -- LSP notifications (instead of fidget.nvim)
    -- vim.api.nvim_create_autocmd('LspProgress', {
    --   callback = function(ev)
    --     local value = ev.data.params.value
    --     vim.api.nvim_echo({ { value.message or 'done' } }, false, {
    --       id = 'lsp.' .. ev.data.client_id,
    --       kind = 'progress',
    --       source = 'vim.lsp',
    --       title = value.title,
    --       status = value.kind ~= 'end' and 'running' or 'success',
    --       percent = value.percentage,
    --     })
    --   end,
    -- })


    vim.lsp.enable('ts_ls')
    vim.lsp.enable('elixirls')
    vim.lsp.enable('emmet_ls')
    vim.lsp.enable('rust_analyzer')
    vim.lsp.enable('zls')
  end,
}
