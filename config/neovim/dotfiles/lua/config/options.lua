-- New options
require('vim._core.ui2').enable({
  enable = true
})

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.hidden = true
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.textwidth = 0 -- disable autowrap
vim.opt.wrap = true
vim.opt.hls = true
vim.opt.showmatch = false
vim.opt.showmode = false
vim.opt.joinspaces = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showbreak = "↳  "
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.expandtab = true
vim.opt.indentexpr = "off"
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.updatetime = 100
vim.opt.timeoutlen = 500
vim.opt.mouse = "a"
vim.opt.cmdheight = 1
vim.opt.wildmode = "longest,list,full"
vim.opt.sessionoptions = "blank,curdir,folds,help,tabpages,winsize"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.modeline = false
vim.opt.fileencoding = "utf-8"
vim.opt.syntax = "on"
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.foldlevel = 99

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

-- Command options
vim.cmd("set clipboard-=unnamedplus")
vim.cmd("set shortmess+=c") -- avoid showing extra message when using completion
vim.cmd("set path+=**")
vim.cmd("set formatoptions-=c formatoptions-=r formatoptions-=o")
vim.cmd("filetype plugin indent on")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "lua MiniTrailspace.trim()",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "silent! %s/\\n\\+\\%$//e",
})

function shell_prompt(opts)
  local opts = opts or {}
  local prompt = opts.prompt or "λ "
  local hlgroup = opts.hlgroup or "Title"
  vim.cmd("echohl " .. hlgroup)
  local input = vim.fn.input({
    prompt = prompt,
    completion = "shellcmdline",
    highlight = function(input)
      local ok, parser = pcall(vim.treesitter.get_string_parser, input, "bash")
      if not ok then return {} end
      local tree = parser:parse()[1]
      local query = vim.treesitter.query.get("bash", "highlights")
      if not query then return {} end
      local highlights = {}
      for id, node in query:iter_captures(tree:root(), input) do
        local r1, c1, r2, c2 = node:range()
        if r1 == 0 and r2 == 0 then
          table.insert(highlights, { c1, c2, "@" .. query.captures[id] })
        end
      end
      return highlights
    end,
  })
  vim.cmd("echohl None")
  return input
end
