return {
  'nvim-telescope/telescope.nvim', 
  tag = '0.1.6',
  dependencies = { 
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim'
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    
    telescope.setup({
      defaults = {
        preview = { treesitter = true },
        color_devicons = true,
        sorting_strategy = "ascending",
        borderchars = {
          "", -- top
          "", -- right
          "", -- bottom
          "", -- left
          "", -- top-left
          "", -- top-right
          "", -- bottom-right
          "", -- bottom-left
        },
        path_display = { "smart" },
        layout_config = {
          height = 100,
          width = 400,
          prompt_position = "top",
          preview_cutoff = 40,
        },
        mappings = {
          i = {
            -- Navigation dans la liste
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.move_selection_next,
            ['<C-e>'] = actions.move_selection_previous,
            -- Scroll vertical dans la preview
            ['<C-u>'] = actions.preview_scrolling_up,
            ['<C-d>'] = actions.preview_scrolling_down,
          },
          n = {
            -- Navigation dans la liste
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            -- Scroll vertical dans la preview
            ['<C-u>'] = actions.preview_scrolling_up,
            ['<C-d>'] = actions.preview_scrolling_down,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {}
        }
      }
    })
    
    telescope.load_extension('ui-select')
    
    -- Keymap additionnel <C-p>
    vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, {
      noremap = true,
      silent = true,
      desc = "Find files"
    })
  end,
}
