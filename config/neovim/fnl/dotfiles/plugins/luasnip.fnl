(module dotfiles.plugins.luasnip
  {autoload {nvim aniseed.nvim
             util dotfiles.util
             ls luasnip}})

;; Examples: https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

; Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
; Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty strin.
; This means they are not SELECTed like in other editors/Snippet engines.
(defn- snip [name trig body]
  (ls.parser.parse_snippet
    {:trig trig :name name}
    body))

(set ls.snippets {:javascript [(snip "Simple console.log"
                                     :log
                                     "console.log(${1:value})")
                               (snip "Debug console.log"
                                     :clo
                                     "console.log('${1:value} =>', ${1:value})")
                               (snip "Debug object with console.dir"
                                     :dir
                                     "console.dir(${1:value}, { depth: null })")
                               (snip "anonymous function"
                                     :f
                                     "() => ")
                               (snip "anonymous function with arguments"
                                     :fn
                                     "$1 => $2")]})

(ls.filetype_extend :typescript [:javascript])
(ls.filetype_extend :typescriptreact [:javascript])
