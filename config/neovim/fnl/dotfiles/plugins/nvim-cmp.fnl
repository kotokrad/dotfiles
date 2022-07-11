(module dotfiles.plugins.nvim-cmp
  {autoload {a aniseed.core
             nvim aniseed.nvim
             cmp cmp
             luasnip luasnip
             autopairs-cmp nvim-autopairs.completion.cmp}})

(local lspkind-icons
  {:Text ""
   :Method ""
   :Function ""
   :Constructor ""
   :Field "ﰠ"
   :Variable ""
   :Class "ﴯ"
   :Interface ""
   :Module ""
   :Property "ﰠ"
   :Unit "塞"
   :Value ""
   :Enum ""
   :Keyword ""
   :Snippet ""
   :Color ""
   :File ""
   :Reference ""
   :Folder ""
   :EnumMember ""
   :Constant ""
   :Struct "פּ"
   :Event ""
   :Operator ""
   :TypeParameter ""})

(cmp.setup {:snippet {:expand (fn [args] (luasnip.lsp_expand args.body))}
            :mapping {:<Tab> (fn [fallback]
                               (if (cmp.visible)
                                   (cmp.select_next_item)
                                   (and (luasnip.in_snippet) (luasnip.jumpable 1))
                                   (luasnip.jump 1)
                                   (fallback)))
                      :<s-tab> (fn [fallback]
                                 (if (cmp.visible)
                                     (cmp.select_prev_item)
                                     (and (luasnip.in_snippet) (luasnip.jumpable -1))
                                     (luasnip.jump -1)
                                     (fallback)))
                      :<c-space> (fn []
                                   (if (luasnip.expandable)
                                       (luasnip.expand)
                                       (cmp.mapping.complete)))
                      :<cr> (cmp.mapping.confirm {:select true})
                      :<c-c> (cmp.mapping.abort)}
            :sources [{:name "nvim_lsp"}
                      {:name "luasnip"}
                      {:name "buffer"}
                      {:name "path"}
                      {:name "conjure"}]
            :formatting {:format (fn [entry item]
                                   (set item.kind (string.format "%s %s" (a.get lspkind-icons item.kind) item.kind))
                                   (set item.menu (a.get {:nvim_lsp "[LSP]"
                                                          :nvim_lua "[Lua]"
                                                          :buffer "[BUF]"
                                                          :luasnip "[Snip]"}
                                                         entry.source.name))
                                   item)}})
