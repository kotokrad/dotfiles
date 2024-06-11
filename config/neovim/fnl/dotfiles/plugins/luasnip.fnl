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
                                    "console.log(\"🤓\", \"${1:value}\")")
                              (snip "Debug console.log"
                                    :clo
                                    "console.log(\"🤓\", \"${1:value} =>\", ${1:value})")
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
                              (snip "className"
                                    :cn
                                    "className=\"$1\"")
                              (snip "useEffect()"
                                    :ue
                                    "useEffect(() => {\n\t$1\n}, [$3]);")
                              (snip "React component"
                                    :fc
                                    "const $1: React.FC = () => ")
                              (snip "React component (with filename)"
                                    :Fc
                                    "export const ${TM_FILENAME_BASE}: React.FC = () => ")
                              (snip "React component with props"
                                    :fp
                                    "interface $1Props {\n  $2\n}\n\nconst $1: React.FC<$1Props> = ({ $3 }) => ")
                              (snip "React component with props (with filename)"
                                    :Fp
                                    "interface ${TM_FILENAME_BASE}Props {\n  $1\n}\n\nexport const ${TM_FILENAME_BASE}: React.FC<${TM_FILENAME_BASE}Props> = ({ $2 }) => ")
                              (snip "React component with props and children"
                                    :fpc
                                    "interface $1Props {\n  $2\n}\n\nconst $1: React.FC<React.PropsWithChildren<$1Props>> = ({ $3, children }) => ")
                              (snip "React component with props and children"
                                    :Fpc
                                    "interface ${TM_FILENAME_BASE}Props {\n  $1\n}\n\nexport const ${TM_FILENAME_BASE}: React.FC<React.PropsWithChildren<${TM_FILENAME_BASE}Props>> = ({ $2, children }) => ")])

(ls.filetype_extend :typescript [:javascript])
(ls.filetype_extend :typescriptreact [:javascript])
