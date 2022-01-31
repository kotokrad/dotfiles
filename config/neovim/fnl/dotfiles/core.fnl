(module dotfiles.core
  {autoload {nvim aniseed.nvim
             nu aniseed.nvim.util
             util dotfiles.util}})

;; Generic Neovim configuration.

;: global
(set nvim.o.hidden true)
(set nvim.o.termguicolors true)
(set nvim.o.splitbelow true)
(set nvim.o.splitright true)
(set nvim.o.textwidth 0) ; disable autowrap!
(set nvim.o.hls true)
(set nvim.o.showmatch false)
(set nvim.o.showmode false)
(set nvim.o.joinspaces false)
(set nvim.o.backup false)
(set nvim.o.writebackup false)
(set nvim.o.swapfile false)
(set nvim.o.completeopt "menuone,noinsert,noselect")
(set nvim.o.showbreak "↳  ")
(set nvim.o.expandtab true)
(set nvim.o.indentexpr "off")
(set nvim.o.smartindent true)
(set nvim.o.tabstop 2)
(set nvim.o.softtabstop 2)
(set nvim.o.shiftwidth 2)
(set nvim.o.updatetime 100)
(set nvim.o.timeoutlen 500)
(set nvim.o.mouse "a")
(set nvim.o.cmdheight 1)
(set nvim.o.wildmode "longest,list,full")
(set nvim.o.sessionoptions "blank,curdir,folds,help,tabpages,winsize")

;; buffer options
(set nvim.bo.modeline false)
(set nvim.bo.fileencoding "utf-8")
(set nvim.bo.syntax "on")
(set nvim.bo.autoindent true)

;; window options
(set nvim.wo.number true)
(set nvim.wo.relativenumber true)
(set nvim.wo.cursorline true)
(set nvim.wo.signcolumn "yes")
(set nvim.wo.foldlevel 99)

;; command options
(nvim.ex.set "clipboard-=unnamedplus")
(nvim.ex.set "shortmess+=c") ; avoid showing extra message when using completion
(nvim.ex.set "path+=**")
(nvim.ex.set "formatoptions-=c formatoptions-=r formatoptions-=o")
(nvim.ex.filetype "plugin indent on")

;; enable undercurl in wezterm
(nvim.ex.let "&t_Cs = '\\e[4:3m'")
(nvim.ex.let "&t_Ce = '\\e[4:0m'")

;; theme
(set nvim.o.background :dark)
(set nvim.g.gruvbox_contrast_dark :hard)
(nvim.ex.colorscheme :gruvbox)
; (nvim.ex.colorscheme :kanagawa)

;; autocmds
; (nvim.ex.autocmd "FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o")
(nvim.ex.autocmd "BufWritePre * %s/\\s\\+$//e")
(nvim.ex.autocmd "BufWritepre * %s/\\n\\+\\%$//e")

(nu.fn-bridge
  :SaveSession
  :dotfiles.core :save-session)

(defn save-session []
  (if (not= "" nvim.v.this_session)
    (nvim.ex.mksession_ nvim.v.this_session)))

(nvim.ex.autocmd "VimLeave * :call SaveSession()")
(nvim.ex.autocmd "BufWritePost * :call SaveSession()")
