local map_multistep = require('mini.keymap').map_multistep

map_multistep('i', '<Tab>',     { 'blink_next', 'luasnip_next' })
map_multistep('i', '<S-Tab>',   { 'blink_prev', 'luasnip_prev' })
map_multistep('i', '<C-j>',     { 'blink_next' })
map_multistep('i', '<C-k>',     { 'blink_prev' })
map_multistep('i', '<CR>',      { 'blink_accept', 'nvimautopairs_cr' })
map_multistep('i', '<BS>',      { 'nvimautopairs_bs' })
map_multistep('i', '<C-Space>', { 'luasnip_expand' })

vim.keymap.set("n", "<esc>", "<cmd>let @/ = ''<CR>", { desc = "Remove last search highlight" })

vim.keymap.set("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })

vim.keymap.set("n", "<C-s>", "<cmd>lua vim.lsp.buf.format({async = true})<CR>",
  { desc = "Format current file" })

vim.keymap.set("n", "<leader>d", "<cmd>Bclose<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>D", "<cmd>Bclose!<CR>", { desc = "Delete buffer (discard changes)" })

-- Buffer cycling
vim.keymap.set("n", "<C-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-h>", "<cmd>bprev<CR>", { desc = "Previous buffer" })

-- Line swap
vim.keymap.set("n", "<C-j>", "<cmd>m .+1<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<C-k>", "<cmd>m .-2<CR>", { desc = "Move line up" })
vim.keymap.set("v", "<C-j>", "<cmd>m .+1<CR>", { desc = "Move line down" })
vim.keymap.set("v", "<C-k>", "<cmd>m .-2<CR>", { desc = "Move line up" })

-- Window nabigation
-- vim.keymap.set("n", "<M-j>", "<cmd>wincmd j<CR>", { desc = "Focus window below" })
-- vim.keymap.set("n", "<M-k>", "<cmd>wincmd k<CR>", { desc = "Focus window above" })
-- vim.keymap.set("n", "<M-h>", "<cmd>wincmd h<CR>", { desc = "Focus window to the left" })
-- vim.keymap.set("n", "<M-l>", "<cmd>wincmd l<CR>", { desc = "Focus window to the right" })

-- Easy clipboard access
vim.keymap.set("v", "<M-c>", "\"+y", { desc = "Copy into system buffer" })
vim.keymap.set("i", "<M-c>", "<nop>" )
vim.keymap.set("n", "<M-c>", "V\"+y" )

-- Subword motions
vim.keymap.set({ "n", "o", "x" }, "<localleader>w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Subword motion w"})
vim.keymap.set({ "n", "o", "x" }, "<localleader>e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Subword motion e"})
vim.keymap.set({ "n", "o", "x" }, "<localleader>b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Subword motion b"})
vim.keymap.set({ "n", "o", "x" }, "<localleader>ge", "<cmd>lua require('spider').motion('ge')<CR>", { desc = "Subword motion ge"})
vim.keymap.set({ "o", "x" }, "as", '<cmd>lua require("various-textobjs").subword("outer")<CR>')
vim.keymap.set({ "o", "x" }, "is", '<cmd>lua require("various-textobjs").subword("inner")<CR>')

vim.keymap.set("n", "<localleader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })
vim.keymap.set("n", "<localleader>A", "<cmd>lua vim.lsp.buf.code_action({context={only={'source'}}})<cr>", { desc = "Code action (local)" })

-- Multiple cursors
vim.keymap.set({ "n", "x" }, "<M-k>", "<cmd>MultipleCursorsAddUp<CR>", { desc = "Add cursor and move up"})
vim.keymap.set({ "n", "x" }, "<M-j>", "<cmd>MultipleCursorsAddDown<CR>", { desc = "Add cursor and move down"})
vim.keymap.set({ "n", "x" }, "<localleader>m", "<cmd>MultipleCursorsAddVisualArea<CR>", { desc = "Add cursors to the lines of the visual area"})
vim.keymap.set({ "n", "x" }, "<localleader>d", "<cmd>MultipleCursorsAddJumpNextMatch<CR>", { desc = "Add cursor and jump to next cword"})
vim.keymap.set("n", "<C-8>", function()
  local col = vim.fn.col(".")
  local line = vim.fn.getline(".")
  if col > 1 and vim.fn.match(line:sub(col - 1, col - 1), "\\k") >= 0 then
    vim.cmd("norm! b")
  end
  vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>")
  vim.opt.hlsearch = true
  vim.cmd("MultipleCursorsAddJumpNextMatch")
end, { desc = "Add cursor and jump to next cword (with hlsearch)" })

-- LSP operations
vim.keymap.set("n", "<leader>le", function()
  vim.diagnostic.open_float({ focusable = false })
end, { desc = "Expand line error" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format" })
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })

-- Telescope
vim.keymap.set("n", "<c-f>", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())<CR>", { desc = "Find files" })

-- LSP references with telescope
vim.keymap.set("n", "gr", function()
  _G.telescope_lsp_references()
end, { desc = "Find References" })

-- Neo-tree
vim.keymap.set("n", "\\", "<cmd>Neotree reveal<CR>", { desc = "Reveal file in Neo-tree" })
vim.keymap.set("n", "<c-b>", "<cmd>Neotree toggle show<CR>", { desc = "Toggle Neo-tree" })
