(module dotfiles.plugins.misc
  {autoload {nvim aniseed.nvim
             todo-comments todo-comments}})

;; todo-comments.nvim
(todo-comments.setup)

;; JSX plugin (syntax highlight)
(set nvim.g.vim_jsx_pretty_highlight_close_tag 1)
(set nvim.g.vim_jsx_pretty_colorful_config 1)

;; Vimwiki
(set nvim.g.vimwiki_global_ext 0)
(set nvim.g.vimwiki_table_mappings 0)
(set nvim.g.vimwiki_folding :expr)
(set nvim.g.vimwiki_list [{:path "~/notes/"
                           :syntax "markdown"
                           :ext ".md"
                           :bullet_types ["-" "*"]
                           :cycle_bullets 1}])

;; Markdown fenced languages
(set nvim.g.markdown_fenced_languages
     [:sh
      :css
      :javascript
      :js=javascript
      :typescript
      :ts=typescript
      :json=javascript
      :ruby
      :sass
      :xml
      :html
      :haskell
      :rust])

;; Bclose (disable default binding)
(set nvim.g.bclose_no_plugin_maps 1)
