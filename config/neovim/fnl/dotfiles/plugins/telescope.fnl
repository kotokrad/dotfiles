(module dotfiles.plugin.telescope
  {autoload {nvim aniseed.nvim
             util dotfiles.util
             telescope telescope
             actions telescope.actions
             builtin telescope.builtin
             themes telescope.themes}})

(telescope.setup
  {:defaults {:mappings {:i {:<esc> actions.close
                             :<c-j> actions.move_selection_next
                             :<c-k> actions.move_selection_previous}}}
   :vimgrep_arguments ["rg" "--color=never" "--no-heading"
                       "--with-filename" "--line-number" "--column"
                       "--smart-case" "--hidden" "--follow"
                        "-g" "!.git/"
                        "-g" "!*.lock"]
   :extensions {:fzy_native {:override_generic_sorter true
                             :override_file_sorter true}}})

(telescope.load_extension "fzy_native")

(defn no-preview-theme []
  (themes.get_dropdown {:borderchars
                        {:prompt ["─" "│" " " "│" "┌" "┐" "│" "│"]
                         :results ["─" "│" "─" "│" "├" "┤" "┘" "└"]
                         :preview [ "─" "│" "─" "│" "┌" "┐" "┘" "└"]}
                        :width 0.8
                        :previewer false
                        :prompt_title false}))

(defn centered-theme []
  (themes.get_dropdown {:borderchars
                        {:prompt ["─" "│" " " "│" "┌" "┐" "│" "│"]
                         :results ["─" "│" "─" "│" "├" "┤" "┘" "└"]
                         :preview [ "─" "│" "─" "│" "┌" "┐" "┘" "└"]}
                        ; :layout_config {:mirror true}
                        ; :previewer false
                        :prompt_title false}))

(defn cursor-relative-theme []
  (themes.get_cursor {:borderchars
                        {:prompt ["─" "│" " " "│" "┌" "┐" "│" "│"]
                         :results ["─" "│" "─" "│" "├" "┤" "┘" "└"]
                         :preview [ "─" "│" "─" "│" "┌" "┐" "┘" "└"]}
                        :layout_config {:width 0.8
                                        :preview_width 0.5}
                        ; :previewer false
                        :prompt_title false}))

(defn code-actions-theme []
  (themes.get_cursor {:borderchars
                        {:prompt ["─" "│" " " "│" "┌" "┐" "│" "│"]
                         :results ["─" "│" "─" "│" "├" "┤" "┘" "└"]
                         :preview [ "─" "│" "─" "│" "┌" "┐" "┘" "└"]}
                        :layout_config {:width 0.2}
                        :previewer false
                        :prompt_title false}))


; (util.lnnoremap :ff "Telescope find_files hidden=true")
; (util.lnnoremap :f- "Telescope file_browser")
; (util.lnnoremap :fg "Telescope live_grep")
; (util.lnnoremap :* "Telescope grep_string")
; (util.lnnoremap :fb "Telescope buffers")
; (util.lnnoremap :fH "Telescope help_tags")
; (util.lnnoremap :fm "Telescope keymaps")
; (util.lnnoremap :fM "Telescope marks")
; (util.lnnoremap :fh "Telescope oldfiles")
; (util.lnnoremap :ft "Telescope filetypes")
; (util.lnnoremap :fc "Telescope commands")
; (util.lnnoremap :fC "Telescope command_history")
; (util.lnnoremap :fq "Telescope quickfix")
; (util.lnnoremap :fl "Telescope loclist")

(defn find-files []
  ; (builtin.find_files (themes.get_ivy {:previewer false})))
  (builtin.find_files (themes.get_ivy)))

(defn lsp-references []
  ; (builtin.lsp_references (cursor-relative-theme)))
  (builtin.lsp_references (centered-theme)))

(defn code-action []
  (builtin.lsp_code_actions (code-actions-theme)))

(util.noremap :n :<c-f> "<cmd>Telescope live_grep<cr>")
(util.noremap :n :<c-p> "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_ivy())<cr>")

(util.map-group {:mode :n}
                {:g {:r [lsp-references "Find References"]}})

(util.map-group {:prefix :<leader>}
                {:f {:name "file"
                     :f [find-files "Find"]
                     :r ["<cmd>Telescope oldfiles<cr>" "Recent"]
                     :g ["<cmd>Telescope live_grep<cr>" "Live Grep"]}
                 :l {:name "lsp"
                     :s ["<cmd>Telescope lsp_document_symbols<cr>" "Document symbols"]
                     :S ["<cmd>Telescope lsp_workspace_symbols<cr>" "Workspace symbols"]
                     :q ["<cmd>Telescope quickfix<cr>" "Quickfix"]}
                 :h {:name "help"
                     :m ["<cmd>Telescope keymaps<cr>" "Mappings"]
                     :c ["<cmd>Telescope commands<cr>" "Commands"]
                     :C ["<cmd>Telescope command_history<cr>" "Command history"]
                     :h ["<cmd>Telescope help_tags<cr>" "Help Tags"]
                     :H ["<cmd>Telescope highlights<cr>" "Highlights"]}})
