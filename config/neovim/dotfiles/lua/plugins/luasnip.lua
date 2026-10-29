return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")
    local vscode = require("luasnip.loaders.from_vscode")

    -- Helper function to create snippets
    local function snip(name, trig, body)
      return ls.parser.parse_snippet({ trig = trig, name = name }, body)
    end

    -- Load friendly-snippets
    vscode.lazy_load({
      default_priority = 500,
      override_priority = 500,
    })

    -- Fix duplications
    ls.config.setup({
      region_check_events = "CursorHold,InsertLeave",
      delete_check_events = "TextChanged,InsertEnter",
    })

    -- Add JavaScript snippets
    ls.add_snippets("javascript", {
      snip("Filename", "fn", "${TM_FILENAME_BASE}"),
      snip("Simple console.log", "log", 'console.log("🤓", "${1:value}")'),
      snip("Debug console.log", "clo", 'console.log("🤓", "${1:value} =>", ${1:value})'),
      snip("Debug object with console.dir", "dir", "console.dir(${1:value}, { depth: null })"),
      snip("anonymous function", "f", "() => "),
      snip("anonymous function with arguments", "F", "($1) => $2"),
      snip("export", "e", "export "),
      snip("export default", "ed", "export default "),
      snip("export * from <filename>", "ef", 'export * from "./${TM_DIRECTORY}"'),
      snip("useState()", "us", "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState(${2:initialState});"),
      snip("useState<Type>()", "uS", "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState<${2:string}>(${3:initialState});"),
      snip("className", "cn", 'className="$1"'),
      snip("className ternary", "cnt", '${$1 ? "$2" : "$3"}'),
      snip("useEffect()", "ue", "useEffect(() => {\n\t$1\n}, [$3]);"),
      snip("useAccount()", "ua", "const { address } = useAccount();"),
      snip("React component", "fc", "const $1: React.FC = () => "),
      snip("React component (with filename)", "Fc", "export const ${TM_FILENAME_BASE}: React.FC = () => "),
      snip(
        "React component with props",
        "fp",
        "interface $1Props {\n  $2\n}\n\nconst $1: React.FC<$1Props> = ({ $3 }) => "
      ),
      snip(
        "React component with props (with filename)",
        "Fp",
        "interface ${TM_FILENAME_BASE}Props {\n  $1\n}\n\nexport const ${TM_FILENAME_BASE}: React.FC<${TM_FILENAME_BASE}Props> = ({ $2 }) => "
      ),
      snip(
        "React component with props and children",
        "fpc",
        "interface $1Props {\n  $2\n}\n\nconst $1: React.FC<React.PropsWithChildren<$1Props>> = ({ $3, children }) => "
      ),
      snip(
        "React component with props and children",
        "Fpc",
        "interface ${TM_FILENAME_BASE}Props {\n  $1\n}\n\nexport const ${TM_FILENAME_BASE}: React.FC<React.PropsWithChildren<${TM_FILENAME_BASE}Props>> = ({ $2, children }) => "
      ),
      snip("[TW] flex.flex-col", "col", '<div className="flex flex-col$1">$2</div>'),
      snip("[TW] grid.grid-cols-", "grid", '<div className="grid grid-cols-$1">$2</div>'),
    })

    -- Extend filetypes to use JavaScript snippets
    ls.filetype_extend("typescript", { "javascript" })
    ls.filetype_extend("typescriptreact", { "javascript" })
  end,
}
