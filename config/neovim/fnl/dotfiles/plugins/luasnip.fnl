(module dotfiles.plugins.luasnip
  {autoload {nvim aniseed.nvim
             util dotfiles.util
             ls luasnip
             vscode luasnip.loaders.from_vscode}})

(defn- snip [name trig body]
  (ls.parser.parse_snippet
    {:trig trig :name name}
    body))

;; Load `friendly-snippets`
(vscode.lazy_load {:default_priority 500
                   :override_priority 500})

;; Fix duplications
(ls.config.setup {:region_check_events "CursorHold,InsertLeave"
                  :delete_check_events "TextChanged,InsertEnter"})

(ls.add_snippets :javascript [(snip "Simple console.log"
                                    :log
                                    "console.log(\"👾\", \"${1:value}\")")
                              (snip "Debug console.log"
                                    :clo
                                    "console.log(\"👾\", \"${1:value} =>\", ${1:value})")
                              (snip "Debug object with console.dir"
                                    :dir
                                    "console.dir(${1:value}, { depth: null })")
                              (snip "anonymous function"
                                    :f
                                    "() => ")
                              (snip "anonymous function with arguments"
                                    :F
                                    "($1) => $2")
                              (snip "anonymous function with body"
                                    :fn
                                    "($1) => {$2}")
                              (snip "default export"
                                    :e
                                    "export ")
                              (snip "default export"
                                    :ed
                                    "export default ")
                              (snip "useState()"
                                    :us
                                    "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState(${2:initialState});")
                              (snip "useState<Type>()"
                                    :uS
                                    "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState<${2:string}>(${3:initialState});")
                              (snip "useEffect()"
                                    :ue
                                    "useEffect(() => {\n\t$1\n}, [$3]);")])

(ls.filetype_extend :typescript [:javascript])
(ls.filetype_extend :typescriptreact [:javascript])
