(module dotfiles.mappings
  {autoload {nvim aniseed.nvim
             nu aniseed.nvim.util
             core aniseed.core
             util dotfiles.util}
   require-macros [dotfiles.macros]})

;; Generic mapping configuration.
(util.noremap :n :<space> :<nop>)
(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader ",")

;; Delete hidden buffers.
; (util.noremap :n :<leader>bo ":call DeleteHiddenBuffers()<cr>")

;; Select mode trick
;; NOTE: Normal mapping: enters select mode with the word nearest the cursor selected.
;; NOTE: You can then type your replacement for the selected word and use the:
;; NOTE: Insert mapping: Jumps to the next match and enters selection mode.
;; NOTE: You can then either type a new replacement or press . to use the:
;; NOTE: Select mapping: re-enters the last-inserted text — essentially, repeats the last insertion.
;; NOTE: https://www.reddit.com/r/vim/comments/5u99rh/select_mode/ddshdj4/
; (util.noremap :n :§ "*``gn<c-g>")
; (util.noremap :i :§ "<c-o>gn<c-g>")
; (util.noremap :s :. "@." {:expr true})


;; Easy Buffer Navigation and manipulation
(util.noremap :n :<leader>d "<cmd>Bclose<cr>")
(util.noremap :n :<leader>D "<cmd>Bclose!<cr>")

;; Buffer cycling
(util.noremap :n :<c-l> "<cmd>bnext<cr>")
(util.noremap :n :<c-h> "<cmd>bprev<cr>")

;; Line swap
(util.noremap :n :<c-j> "<cmd>m .+1<cr>")
(util.noremap :n :<c-k> "<cmd>m .-2<cr>")
(util.noremap :v :<c-j> "<cmd>m .+1<cr>")
(util.noremap :v :<c-k> "<cmd>m .-2<cr>")

;; Easy clipboard access
(util.noremap :n :+ "\"+")
(util.noremap :v :<M-c> "\"+y")
(util.noremap :i :<M-c> "<nop>")
(util.noremap :n :<M-c> "<nop>")

;; Remove last search highlight
(util.noremap :n :<c-c> "<cmd>let @/ = ''<cr>")

;; CamelCase Motions
(nvim.set_keymap :n :<localleader>w "<Plug>CamelCaseMotion_w" {:silent true})
(nvim.set_keymap :o :<localleader>w "<Plug>CamelCaseMotion_w" {:silent true})
(nvim.set_keymap :x :<localleader>w "<Plug>CamelCaseMotion_w" {:silent true})

(nvim.set_keymap :n :<localleader>b "<Plug>CamelCaseMotion_b" {:silent true})
(nvim.set_keymap :o :<localleader>b "<Plug>CamelCaseMotion_b" {:silent true})
(nvim.set_keymap :x :<localleader>b "<Plug>CamelCaseMotion_b" {:silent true})

;; Add semicolon at the line and from input-mode
(util.noremap :i :<c-s> "<esc>mmA;<esc>`m:delm m<cr>a")

;; Tabularize
; (nvim.set_keymap :n :<leader>t= ":Tabularize /=<cr>" {})
; (nvim.set_keymap :v :<leader>t= ":Tabularize /=<cr>" {})
; (nvim.set_keymap :n :<leader>t: ":Tabularize /:\\zs<cr>" {})
; (nvim.set_keymap :v :<leader>t: ":Tabularize /:\\zs<cr>" {})
; (nvim.set_keymap :n :<leader>t<bar> ":Tabularize /<bar><cr>" {})
; (nvim.set_keymap :v :<leader>t<bar> ":Tabularize /<bar><cr>" {})

;; Replace (Normal)
(util.map-group {:prefix :<leader>}
                {:r (util.tassign [":%s//g<left><left>" "Replace"] {:silent false})})

;; Replace (Visual)
(util.map-group {:prefix :<leader>
                 :mode :v}
                {:r (util.tassign [":s//g<left><left>" "Replace"] {:silent false})})

;; Undotree
(util.map-group {:prefix :<leader>}
                {:u {:name "undo"
                     :u [(.. (util.cmd-fmt "UndotreeShow")
                             (util.cmd-fmt "UndotreeFocus"))
                         "Focus undotree"]
                     :t [(.. (util.cmd-fmt "UndotreeToggle")
                             (util.cmd-fmt "UndotreeFocus"))
                         "Toggle undotree"]}})

;; Delete hidden buffers
(defn delete-hidden-buffers [force]
  (let [wipeout (if force
                  nvim.ex.bwipeout_
                  nvim.ex.bwipeout)
        visible-bufs (->> (nvim.fn.range 1 (nvim.fn.tabpagenr :$))
                          (core.map nvim.fn.tabpagebuflist)
                          (unpack)
                          (core.concat))]
    (->> (nvim.fn.range 1 (nvim.fn.bufnr :$))
         (core.filter
           (fn [bufnr]
             (and (nvim.fn.bufexists bufnr)
                  (= -1 (nvim.fn.index visible-bufs bufnr)))))
         (#(wipeout (unpack $1))))))

(defn delete-hidden-buffers! []
  (delete-hidden-buffers true))

(util.map-group {:prefix :<leader>}
                {:b {:name "buffer"
                     :o [delete-hidden-buffers "Only (delete hidden buffers) "]
                     :O [delete-hidden-buffers! "Only! (force delete hidden buffers) "]}})

(util.map-group {:prefix :<leader>}
                {:t {:name "terminal"
                     :t (util.tassign [":TermExec size=16 cmd=''<left>" "Terminal"] {:silent false})}})


;; Save file as sudo on files that require root permission
; map('c', 'w!!', 'execute \'silent! write !sudo tee % >/dev/null\' <bar> edit!', opts)

;; read escape in terminal .. double tap to go back to insert mode
(util.noremap :t :<esc><esc> "<c-\\><c-n>")
