(module dotfiles.plugins.gitsigns
  {autoload {gitsigns gitsigns
             util dotfiles.util}})

(gitsigns.setup
  {:keymaps {}})


;; Navigation
(util.noremap :n "]h" "<cmd>lua require'gitsigns'.next_hunk()<cr>")
(util.noremap :n "[h" "<cmd>lua require'gitsigns'.prev_hunk()<cr>")

;; Normal mode
(util.map-group {:prefix :<leader>}
                {:g {:name "git"
                     :s ["<cmd>lua require'gitsigns'.stage_hunk()<cr>" "Stage hunk"]
                     :u ["<cmd>lua require'gitsigns'.undo_stage_hunk()<cr>" "Undo staging"]
                     :r ["<cmd>lua require'gitsigns'.reset_hunk()<cr>" "Reset hunk"]
                     :R ["<cmd>lua require'gitsigns'.reset_buffer()<cr>" "Reset buffer"]
                     :p ["<cmd>lua require'gitsigns'.preview_hunk()<cr>" "Preview hunk"]
                     :b ["<cmd>lua require'gitsigns'.blame_line{full=false}<cr>" "Blame line"]
                     :B ["<cmd>lua require'gitsigns'.blame_line{full=true}<cr>" "Blame line (full)"]
                     :t ["<cmd>lua require'gitsigns'.toggle_current_line_blame()<cr>" "Toggle line blame"]
                     :S ["<cmd>lua require'gitsigns'.stage_buffer()<cr>" "Stage buffer"]
                     :U ["<cmd>lua require'gitsigns'.reset_buffer_index()<cr>" "Reset buffer index"]}})

;; Visual mode
(util.map-group {:mode :v
                 :prefix :<leader>}
                {:g {:name "git"
                     :s ["<cmd>lua require'gitsigns'.stage_hunk({vim.fn.line('.'), vim.fn.line('v')})<cr>" "Stage"]
                     :r ["<cmd>lua require'gitsigns'.reset_hunk({vim.fn.line('.'), vim.fn.line('v')})<cr>" "Reset"]}})
