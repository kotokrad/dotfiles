return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzy-native.nvim',
    'stevearc/dressing.nvim',
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local builtin = require('telescope.builtin')
    local themes = require('telescope.themes')

    -- Telescope setup
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
            ["<c-j>"] = actions.move_selection_next,
            ["<c-k>"] = actions.move_selection_previous,
            -- Open results in Trouble (if available)
            ["<c-t>"] = function(...)
              local ok, trouble = pcall(require, 'trouble.sources.telescope')
              if ok then
                trouble.open(...)
              end
            end,
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--follow",
          "-g",
          "!.git/",
          "-g",
          "!*.lock",
        },
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = true,
          override_file_sorter = true,
        },
      },
    })

    -- Load extensions
    telescope.load_extension('fzy_native')

    -- Theme functions
    local function no_preview_theme()
      return themes.get_dropdown({
        borderchars = {
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        width = 0.8,
        previewer = false,
        prompt_title = false,
      })
    end

    local function centered_theme()
      return themes.get_dropdown({
        borderchars = {
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        prompt_title = false,
      })
    end

    local function cursor_relative_theme()
      return themes.get_cursor({
        borderchars = {
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        layout_config = {
          width = 0.8,
          preview_width = 0.5,
        },
        prompt_title = false,
      })
    end

    -- Setup dressing.nvim
    require('dressing').setup({
      select = {
        telescope = centered_theme(),
      },
    })

    -- Custom functions
    _G.telescope_find_files = function()
      builtin.find_files(themes.get_ivy())
    end

    _G.telescope_lsp_references = function()
      builtin.lsp_references(centered_theme())
    end
  end,
}
