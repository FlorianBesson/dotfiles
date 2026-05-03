vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" },
        sections = {
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
        },
      })
    end,
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = { "css", "javascript", "html", "lua", "conf" },
        user_default_options = {
          RGB = true, RRGGBB = true, names = true, RRGGBBAA = true,
          rgb_fn = true, hsl_fn = true, css = true, css_fn = true,
          mode = "background",
        },
      })
    end,
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "echasnovski/mini.icons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = { "icon" },
        view_options = { show_hidden = true },
        float = { max_width = 0.3, max_height = 0.6, border = "rounded" },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "LinArcX/telescope-env.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          preview = { treesitter = true },
          color_devicons = true,
          sorting_strategy = "ascending",
          path_display = { "smart" },
          layout_config = {
            height = 0.9, width = 0.9,
            prompt_position = "top",
            preview_cutoff = 40,
          },
        },
      })
      telescope.load_extension("env")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", lazy = false, opts = {} },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "html", "cssls", "emmet_ls",
          "tailwindcss", "ts_ls", "intelephense",
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      vim.lsp.config.lua_ls = {
        cmd = { mason_bin .. "/lua-language-server" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      }
      vim.lsp.config.html        = { cmd = { mason_bin .. "/vscode-html-language-server", "--stdio" }, capabilities = capabilities }
      vim.lsp.config.cssls       = { cmd = { mason_bin .. "/vscode-css-language-server", "--stdio" }, capabilities = capabilities }
      vim.lsp.config.emmet_ls    = { cmd = { mason_bin .. "/emmet-ls", "--stdio" }, capabilities = capabilities }
      vim.lsp.config.tailwindcss = { cmd = { mason_bin .. "/tailwindcss-language-server", "--stdio" }, capabilities = capabilities }
      vim.lsp.config.ts_ls       = { cmd = { mason_bin .. "/typescript-language-server", "--stdio" }, capabilities = capabilities }
      vim.lsp.config.intelephense = { cmd = { mason_bin .. "/intelephense", "--stdio" }, capabilities = capabilities }

      vim.lsp.enable({ "lua_ls", "html", "cssls", "emmet_ls", "tailwindcss", "ts_ls", "intelephense" })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "rust", "cpp", "javascript", "typescript", "tsx", "html", "css", "php" },
        sync_install = false,
        highlight = { enable = true },
        indent = {
          enable = true,
          disable = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        },
      })
    end,
  },



  {
    "stevearc/conform.nvim",
    keys = {
      { "<leader>p", function()
        require("conform").format({ async = true, timeout_ms = 3000, lsp_format = "never" })
      end, mode = { "n", "v" }, desc = "Format with Prettier" },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" }, typescript = { "prettier" },
        javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
        css = { "prettier" }, scss = { "prettier" },
        html = { "prettier" }, json = { "prettier" }, jsonc = { "prettier" },
        yaml = { "prettier" }, markdown = { "prettier" }, vue = { "prettier" },
      },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } },
    keys = {
      { "<leader>l", mode = { "n", "x", "o" }, function()
        require("flash").jump({
          action = function(match, state)
            state:hide()
            vim.api.nvim_win_set_cursor(match.win, match.pos)
            vim.cmd("normal! zz")
          end,
        })
      end, desc = "Flash jump" },
      { "<leader>L", mode = { "n", "x", "o" }, function()
        require("flash").treesitter({
          action = function(match, state)
            state:hide()
            vim.api.nvim_win_set_cursor(match.win, match.pos)
            vim.cmd("normal! zz")
          end,
        })
      end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup({
        builtin_marks = { "<", ">", "^" },
        cyclic = true,
        force_write_shada = false,
        refresh_interval = 250,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        mappings = {
          set_next = "m,",
          next = "m]",
          prev = "m[",
          delete_line = "dm-",
          delete_buf = "dm<space>",
        },
      })
      vim.keymap.set("n", "m]", function() require("marks").next(); vim.cmd("normal! zz") end)
      vim.keymap.set("n", "m[", function() require("marks").prev(); vim.cmd("normal! zz") end)
      for _, key in ipairs({ "'", "`" }) do
        vim.keymap.set("n", key, function()
          local char = vim.fn.getcharstr()
          pcall(vim.cmd, "normal! " .. key .. char)
          vim.cmd("normal! zz")
        end, { noremap = true, silent = true })
      end
    end,
  },

  {
    "aznhe21/actions-preview.nvim",
    config = function()
      require("actions-preview").setup({})
    end,
  },

  "tpope/vim-repeat",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "romainl/vim-qf",

  {
    "echasnovski/mini.pairs",
    version = false,
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup()
    end,
  },
})

vim.o.background      = "light"
pcall(vim.cmd, "colorscheme gruvbox")

vim.opt.clipboard      = "unnamedplus"
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.swapfile       = false
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.o.autowrite        = true
vim.o.winborder        = "rounded"
vim.opt.showtabline    = 2
vim.opt.signcolumn     = "yes"
vim.opt.wrap           = false
vim.opt.cursorline     = true
vim.opt.cursorcolumn   = false
vim.opt.ignorecase     = true
vim.opt.autoindent     = true
vim.opt.smartindent    = true
vim.opt.termguicolors  = true
vim.opt.undofile       = true
vim.opt.completeopt    = { "menu", "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_config", { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method("textDocument/completion") then
      local chars = {}; for i = 33, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "K",    vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd",   vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD",   vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi",   vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "go",   vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gr",   vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gs",   vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "x" }, "<F3>", vim.lsp.buf.format, opts)
    vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)
  end,
})

local ls = require("luasnip")
ls.setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/snippets/" })

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
  elseif ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
  end
end, { silent = true, expr = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if ls.jumpable(-1) then ls.jump(-1)
  else vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false) end
end, { silent = true })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
    vim.opt_local.indentexpr = ""
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal makeprg=python3\\ %",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
    vim.opt_local.cindent = false
  end,
})

local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Escape" })
map("n", "<leader>w", "<Cmd>update<CR>",       { desc = "Write" })
map("n", "<leader>q", "<Cmd>quit<CR>",          { desc = "Quit" })
map("n", "<leader>Q", "<Cmd>wqa<CR>",           { desc = "Write all + quit all" })
map("n", "<leader>cd", "<Cmd>cd %:p:h<CR>", { desc = "cd to current file dir" })
map("n", "<leader>a", ":edit #<CR>",            { desc = "Alternate buffer" })
map("n", "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit vimrc" })
map("n", "<leader>r", ":update<CR> :make<CR>",  { desc = "Save + make" })
map("n", "-",         "<Cmd>Oil<CR>",           { desc = "Open Oil" })
map({ "n", "x" }, "<leader>y", '"+y',           { desc = "Yank to system clipboard" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<M-n>", "<cmd>resize +2<CR>")
map("n", "<M-e>", "<cmd>resize -2<CR>")
map("n", "<M-i>", "<cmd>vertical resize +5<CR>")
map("n", "<M-m>", "<cmd>vertical resize -5<CR>")
map({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>",   { desc = "New tab" })
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>", { desc = "Close tab" })
for i = 1, 8 do
  map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>", { desc = "Tab " .. i })
end
map("t", "<Esc>", "<C-\\><C-n>",                { desc = "Exit terminal mode" })
map({ "n", "v", "x" }, ";", ":",                { desc = "Command mode" })
map({ "n", "v", "x" }, ":", ";",                { desc = "Repeat f/t" })
map({ "n", "v", "x" }, "<leader>n", ":norm ",   { desc = "Normal cmd on selection" })
map({ "v", "x" }, "<C-s>", [[:s/\V]],           { desc = "Substitute in selection" })
map("n", "<leader>m", "`",                       { desc = "Jump to mark" })
map("n", "<leader>d", function()
  vim.diagnostic.open_float(nil, {
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    border = "rounded", source = "always", prefix = " ", scope = "cursor",
  })
end, { desc = "Show diagnostic float" })
map("n", "<C-q>", ":copen<CR>", { silent = true })
map("n", "<leader>c", "1z=")

local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files,                { desc = "Find files" })
map("n", "<leader>fo", builtin.oldfiles,                  { desc = "Old files" })
map("n", "<leader>fb", builtin.buffers,                   { desc = "Buffers" })
map("n", "<leader>fG", builtin.git_files,                 { desc = "Git files" })
map("n", "<leader>fg", builtin.live_grep,                 { desc = "Live grep" })
map("n", "<leader>fi", builtin.grep_string,               { desc = "Grep string" })
map("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Buffer fuzzy" })
map("n", "<leader>fr", builtin.lsp_references,            { desc = "LSP references" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",  { desc = "LSP doc symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "LSP ws symbols" })
map("n", "<leader>ft", builtin.lsp_type_definitions,      { desc = "LSP type defs" })
map("n", "<leader>fw", builtin.diagnostics,               { desc = "Diagnostics" })
map("n", "<leader>fh", builtin.help_tags,                 { desc = "Help tags" })
map("n", "<leader>fk", builtin.keymaps,                   { desc = "Keymaps" })
map("n", "<leader>fm", builtin.man_pages,                 { desc = "Man pages" })
map("n", "<leader>fe", "<cmd>Telescope env<cr>",          { desc = "Env vars" })
map("n", "<leader>fc", builtin.git_bcommits,              { desc = "Git bcommits" })
map("n", "<leader>fT", builtin.builtin,                   { desc = "Telescope builtins" })
map("n", "<leader>fa", require("actions-preview").code_actions, { desc = "Code actions" })

vim.cmd([[
  noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
  noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
  noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
  noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
  nnoremap g= g+
  nnoremap gK @='ddkPJ'<cr>
  xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
  xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])

local function jump_and_center(keys)
  return function()
    local ok = pcall(vim.cmd, "normal! " .. vim.api.nvim_replace_termcodes(keys, true, false, true))
    if ok then vim.cmd("normal! zz") end
  end
end


map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = { "/", "\\?" },
  callback = function()
    vim.schedule(function()
      if vim.v.hlsearch == 1 then vim.cmd("normal! zz") end
    end)
  end,
})
