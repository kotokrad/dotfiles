return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- Text editing
    require('mini.ai').setup()
    require('mini.align').setup()
    -- require('mini.comment').setup({
    --   options = {
    --     custom_commentstring = function()
    --       return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
    --     end,
    --   },
    -- })
    require('mini.keymap').setup()
    require('mini.move').setup({ mappings = {
      down = '',
      up = '',
      left = '',
      right = '',
      line_down = '',
      line_up = '',
      line_left = '',
      line_right = ''
    }})
    -- require('mini.pairs').setup()
    require('mini.splitjoin').setup()
    require('mini.surround').setup()

    -- General workflow
    require('mini.basics').setup({
      mappings = { basic = false }
    })

    -- Appearance
    require('mini.icons').setup()
    -- require('mini.statusline').setup()
    require('mini.tabline').setup({show_icons = false})
    require('mini.trailspace').setup()

    local hipatterns = require('mini.hipatterns')
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
        todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
        note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      }
    })
  end
}
