(module dotfiles.plugins.lspconfig
  {autoload {nvim aniseed.nvim
             util dotfiles.util
             cmp-nvim-lsp cmp_nvim_lsp
             lsputil-ca lsputil.codeAction
             null-ls null-ls
             nlb null-ls.builtins}})

(null-ls.setup
  {:sources [; (nlb.formatting.fixjson.with {:filetypes ["json" "jsonc"]})
             ; (nlb.diagnostics.shellcheck)
             (nlb.formatting.prettierd.with {:filetypes ["javascript"
                                                         "javascriptreact"
                                                         "typescript"
                                                         "typescriptreact"
                                                         "vue"
                                                         "svelte"
                                                         "css"
                                                         "scss"
                                                         "html"
                                                         "json"
                                                         "jsonc"]})]})

(let [lsp (require :lspconfig)
      capabilities (cmp-nvim-lsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))
      attach-handler (fn [client]
                       (util.noremap :n :K "<cmd>lua vim.lsp.buf.hover({ focusable = false })<cr>")
                       (util.noremap :n :<c-s> "<cmd>lua vim.lsp.buf.formatting()<cr>")
                       (util.noremap :n :<localleader>a "<cmd>lua vim.lsp.buf.code_action()<cr>"))]
                       ;; Use "CursorHold,CursorHoldI" for input mode
                       ; (nvim.ex.autocmd "CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })"))]
                       ; (util.noremap :n :<localleader>r "<cmd>lua vim.lsp.buf.rename()<cr>"))]
  (when lsp
    (lsp.clojure_lsp.setup {:capabilities capabilities
                            :on_attach attach-handler})
    (lsp.tsserver.setup {:capabilities capabilities
                         :on_attach (fn [client]
                                      (attach-handler client)
                                      (set client.resolved_capabilities.document_formatting false))})
    (lsp.hls.setup {:capabilities capabilities
                    :on_attach attach-handler})
    (lsp.rnix.setup {:capabilities capabilities
                     :on_attach attach-handler})
    (lsp.rust_analyzer.setup {:capabilities capabilities
                              :on_attach attach-handler})
    ; (lsp.elixirls.setup {:capabilities capabilities
    ;                      :on_attach attach-handler
    ;                      :cmd ["elixir-ls"]})

    (set vim.lsp.handlers.textDocument/publishDiagnostics
         (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                       {:underline true
                        :update_in_insert false
                        :virtual_text {:spacing 2
                                       :prefix "●"}
                        :severity_sort true
                        :signs true}))

    (set vim.lsp.handlers.textDocument/codeAction lsputil-ca.code_action_handler)

    (let [signs {:Error " "
                 :Warn " "
                 :Hint " "
                 :Info " "}]
      (each [diag-type icon (pairs signs)]
        (let [hl (.. "DiagnosticSign" diag-type)]
          (nvim.fn.sign_define hl
                               {:text icon
                                :texthl hl
                                :numhl ""}))))))

(util.map-group {:prefix :<leader>}
                {:l {:name "lsp"
                     :e ["<cmd> lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })<cr>" "Expand Line Error"]
                     :f ["<cmd>lua vim.lsp.buf.formatting()<cr>" "Format"]
                     :r ["<cmd>lua vim.lsp.buf.rename()<cr>" "Rename"]}})

(util.map-group {:mode :n}
                {:g {:d ["<cmd>lua vim.lsp.buf.definition()<cr>" "Go to Definition"]}})
