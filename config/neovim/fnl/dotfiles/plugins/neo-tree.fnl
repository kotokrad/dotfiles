(module dotfiles.plugins.neo-tree
  {autoload {util dotfiles.util
             tree neo-tree}})

(tree.setup {:close_if_last_window false
             :popup_border_style "rounded"
             :enable_git_status true
             :enable_diagnostics true
             :open_files_do_not_replace_types ["terminal" "trouble" "qf"] ; when opening files, do not use windows containing these filetypes or buftypes
             :sort_case_insensitive false ; used when sorting files and directories in the tree
             :sort_function nil  ; use a custom function for sorting files and directories in the tree
             ; :sort_function (fn [a b]
             ;                 (if (== a.type b.type) (> a.path b.path) (> a.type b.type)))
             ; this sorts files and directories descendantly

             :default_component_configs {:container {:enable_character_fade true}
                                         :indent {:indent_size 2
                                                  :padding 1 ; extra padding on left hand side
                                                  ; :indent guides
                                                  :with_markers true
                                                  :indent_marker "│"
                                                  :last_indent_marker "└"
                                                  :highlight "NeoTreeIndentMarker"
                                                  ; expander config, needed for nesting files
                                                  :with_expanders nil ; if nil and file nesting is enabled, will enable expanders
                                                  :expander_collapsed ""
                                                  :expander_expanded ""
                                                  :expander_highlight "NeoTreeExpander"}

                                         :icon {:folder_closed ""
                                                :folder_open ""
                                                :folder_empty "󰜌"
                                                ; The next two settings are only a fallback,
                                                ; if you use nvim-web-devicons and configure default icons there
                                                ; then these will never be used.
                                                :default "*"
                                                :highlight "NeoTreeFileIcon"}
                                          :modified {:symbol "[+]"
                                                     :highlight "NeoTreeModified"}
                                          :name {:trailing_slash false
                                                 :use_git_status_colors true
                                                 :highlight "NeoTreeFileName"}
                                          :git_status {:symbols {
                                                                 ; Change type
                                                                 :added     "" ; or "✚" but this is redundant if you use git_status_colors
                                                                 :modified  "" ; or "" but this is redundant if you use git_status_colors
                                                                 :deleted   "✖"; this can only be used in the git_status source
                                                                 :renamed   "󰁕"; this can only be used in the git_status source
                                                                 ; Status type
                                                                 :untracked ""
                                                                 :ignored   ""
                                                                 :unstaged  "󰄱"
                                                                 :staged    ""
                                                                 :conflict  ""}}
                                          :type           {:enabled true :required_width 64}
                                          :file_size      {:enabled false :required_width 64}
                                          :last_modified  {:enabled false :required_width 88}
                                          :created        {:enabled false :required_width 110}
                                          :symlink_target {:enabled false}}

             ; A list of functions, each representing a global custom command
             ; that will be available in all sources (if not overridden in `opts[source_name].commands`)
             ; see `:h neo-tree-custom-commands-global`
             :commands {}

             :window {:position "left"
                      :width 40
                      ; disable `nowait` if you have existing combos starting with this char that you want to use
                      :mapping_options {:noremap true :nowait true}
                      :mappings {"<space>" {1 "toggle_node" :nowait true}
                                 "<2-LeftMouse>" "open"
                                 "<cr>" "open"
                                 "<esc>" "cancel" ; close preview or floating neo-tree window
                                 "P" {1 "toggle_preview" :config {:use_float true :use_image_nvim true}}
                                 ; Read `# Preview Mode` for more information
                                 "l" "focus_preview"
                                 "S" "open_split"
                                 "s" "open_vsplit"
                                 ; "S" "split_with_window_picker"
                                 ; "s" "vsplit_with_window_picker"
                                 "t" "open_tabnew"
                                 ; "<cr>" "open_drop"
                                 ; "t" "open_tab_drop"
                                 ; "w" "open_with_window_picker"
                                 ;"P" "toggle_preview" ; enter preview mode, which shows the current node without focusing
                                 "C" "close_node"
                                 ; 'C' 'close_all_subnodes'
                                 "z" "close_all_nodes"
                                 ;"Z" "expand_all_nodes"
                                 ; this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc).
                                 ; see `:h neo-tree-file-actions` for details
                                 ; some commands may take optional config options,
                                 ; see `:h neo-tree-mappings` for details
                                 "a" {1 "add" :config {:show_path "relative"}} ; "none" "relative" "absolute"
                                 "A" {1 "add_directory" :config {:show_path "relative"}}
                                 "d" "delete"
                                 "r" "rename"
                                 "y" "copy_to_clipboard"
                                 "x" "cut_to_clipboard"
                                 "p" "paste_from_clipboard"
                                 "c" {1 "copy" :config {:show_path "relative"}} ; takes text input for destination
                                 "m" {1 "move" :config {:show_path "relative"}} ; takes text input for destination
                                 "q" "close_window"
                                 "R" "refresh"
                                 "?" "show_help"
                                 "<" "prev_source"
                                 ">" "next_source"
                                 "i" "show_file_details"}}

             :nesting_rules {}

             :filesystem {:filtered_items {:visible true ; when true, they will just be displayed differently than normal items
                                           :hide_dotfiles true
                                           :hide_gitignored true
                                           :hide_hidden true}
                          :follow_current_file {:enabled true :leave_dirs_open false}
                          :group_empty_dirs false
                          :hijack_netrw_behavior "open_default"
                          :use_libuv_file_watcher false ; This will use the OS level file watchers to detect changes
                                                       ; instead of relying on nvim autocmd events.
                          :window {:mappings {"<bs>" "navigate_up"
                                              "." "set_root"
                                              "H" "toggle_hidden"
                                              "/" "fuzzy_finder"
                                              "D" "fuzzy_finder_directory"
                                              "#" "fuzzy_sorter" ; fuzzy sorting using the fzy algorithm
                                              ; "D" "fuzzy_sorter_directory"
                                              "f" "filter_on_submit"
                                              "<c-x>" "clear_filter"
                                              "g" "prev_git_modified"
                                              "g" "next_git_modified"
                                              "o"  {1 "show_help" :nowait false :config {:title "Order by" :prefix_key "o"}}
                                              "oc" {1 "order_by_created" :nowait false}
                                              "od" {1 "order_by_diagnostics" :nowait false}
                                              "og" {1 "order_by_git_status" :nowait false}
                                              "om" {1 "order_by_modified" :nowait false}
                                              "on" {1 "order_by_name" :nowait false}
                                              "os" {1 "order_by_size" :nowait false}
                                              "ot" {1 "order_by_type" :nowait false}}
                                              ; "<key>" (fn state ...)}
                                    :fuzzy_finder_mappings {"<down>" "move_cursor_down"
                                                            "<C-n>" "move_cursor_down"
                                                            "<up>" "move_cursor_up"
                                                            "<C-p>" "move_cursor_up"}}
                                                            ; "<key>" (fn state, scroll_padding ...)}
                          :commands {}} ; Add a custom command or override a global one using the same function name}

             :buffers {:follow_current_file {:enabled true :leave_dirs_open false}
                       :group_empty_dirs true
                       :show_unloaded true
                       :window {:mappings {"bd" "buffer_delete"
                                           "<bs>" "navigate_up"
                                           "." "set_root"
                                           "o" {1 "show_help" :nowait false :config {:title "Order by" :prefix_key "o"}}
                                           "oc" {1 "order_by_created" :nowait false}
                                           "od" {1 "order_by_diagnostics" :nowait false}
                                           "om" {1 "order_by_modified" :nowait false}
                                           "on" {1 "order_by_name" :nowait false}
                                           "os" {1 "order_by_size" :nowait false}
                                           "ot" {1 "order_by_type" :nowait false}}}}

             :git_status {:window {:position "float"
                                   :mappings {"A"  "git_add_all"
                                              "gu" "git_unstage_file"
                                              "ga" "git_add_file"
                                              "gr" "git_revert_file"
                                              "gc" "git_commit"
                                              "gp" "git_push"
                                              "gg" "git_commit_and_push"
                                              "o" {1 "show_help" :nowait false :config {:title "Order by" :prefix_key "o"}}
                                              "oc" {1 "order_by_created" :nowait false}
                                              "od" {1 "order_by_diagnostics" :nowait false}
                                              "om" {1 "order_by_modified" :nowait false}
                                              "on" {1 "order_by_name" :nowait false}
                                              "os" {1 "order_by_size" :nowait false}
                                              "ot" {1 "order_by_type" :nowait false}}}}})

; (util.noremap :n :<\> "<cmd>Neotree reveal<cr>")
; (util.noremap :n :<c-b> "<cmd>Neotree reveal<cr>")
(util.noremap :n :<Bslash> "<cmd>Neotree toggle show<cr>")
(util.noremap :n :<c-b> "<cmd>Neotree toggle show<cr>")

; ;; Open on startup
; ; NOTE: `open` doesn't support `focus` argument, hence using `toggle`
; (ac.autocmd [:VimEnter] {:callback #(api.tree.toggle {:focus false :find_file true})})
