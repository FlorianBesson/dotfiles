return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,        
    priority = 1000,      
    opts = {
      flavour = "latte",   
      background = { light = "latte", dark = "latte" },
      transparent_background = false,
      integrations = {
        treesitter = true,
        native_lsp = { enabled = true },
        cmp = true,
        telescope = true,
        nvimtree = true,
        gitsigns = true,
        which_key = true,
        lsp_trouble = true,
        illuminate = true,
        navic = { enabled = true },
        notify = true,
        mini = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.o.termguicolors = true
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
