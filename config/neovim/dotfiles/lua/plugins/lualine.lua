return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local codedark = require('lualine.themes.codedark');

    codedark.normal.c.fg = "#608B4E"
    codedark.visual.c = { fg = "#C586C0" }
    codedark.replace.c.fg = "#D16969"
    codedark.insert.c.fg = "#569CD6"

    require('lualine').setup {
      options = {
        theme = codedark,
        section_separators = "",
        component_separators = "",
      }
    }
  end
}
