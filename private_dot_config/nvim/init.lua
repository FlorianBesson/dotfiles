vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("k.plugins")

vim.o.background = "light"
pcall(vim.cmd, "colorscheme gruvbox")

vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.hidden = true
vim.o.autowrite = true
vim.o.winborder = "rounded"
vim.opt.showtabline = 2
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = false
vim.opt.preserveindent = true
vim.opt.copyindent = true
vim.opt.termguicolors = true
vim.opt.undofile = true

-- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--   pattern = "*",
--   callback = function()
--     if vim.bo.buftype == "" and vim.bo.modifiable and vim.fn.expand("%") ~= "" then
--       vim.cmd("silent! update")
--     end
--   end,
-- })

-- ouvre infos lsp
vim.keymap.set('n', '<S-k>', vim.lsp.buf.hover)

--speed key
vim.keymap.set('n', '<leader>r', ':update<CR> :make<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')

-- Swap ; et : pour éviter le Shift (plus ergonomique)
vim.keymap.set({ "n", "v", "x" }, ";", ":", { desc = "Enter command mode" })
vim.keymap.set({ "n", "v", "x" }, ":", ";", { desc = "Repeat f/t motion" })

-- Remap ' pour jump exact (position exacte au lieu de début de ligne)
vim.keymap.set("n", "'", "`", { desc = "Jump to mark exact position" })

-- Insert date/time en mode insert
vim.cmd([[
  noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
  noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
]])

-- recentre l'ecran
vim.api.nvim_set_keymap('n', '<C-U>', '<C-U>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-D>', '<C-D>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-]>', '<C-]>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-o>', '<C-o>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-i>', '<C-i>zz', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>e', ':Oil<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })





local ok_telescope, builtin = pcall(require, 'telescope.builtin')
if ok_telescope then
  -- Files & Navigation
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fG', builtin.git_files, {})

  -- Search
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fi', builtin.grep_string, {})
  vim.keymap.set('n', '<leader>f/', builtin.current_buffer_fuzzy_find, {})

  -- LSP
  vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
  vim.keymap.set('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>fS', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>ft', builtin.lsp_type_definitions, {})
  vim.keymap.set('n', '<leader>fw', builtin.diagnostics, {})

  -- Utilities
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
  vim.keymap.set('n', '<leader>fk', builtin.keymaps, {})
  vim.keymap.set('n', '<leader>fm', builtin.man_pages, {})
  vim.keymap.set('n', '<leader>fe', '<cmd>Telescope env<cr>', {})
  vim.keymap.set('n', '<leader>fc', builtin.git_bcommits, {})
  vim.keymap.set('n', '<leader>fT', builtin.builtin, {})
end


-- Native completion (Neovim 0.11+)
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('native_completion', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

vim.cmd [[set completeopt=menu,menuone,noselect]]

-- html filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.autoindent = false
    vim.opt_local.smartindent = false
    vim.opt_local.indentexpr = ""
  end
})

-- python filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal makeprg=python3\\ %"
})

-- Fix indentation pour TypeScript/React (ne pas utiliser Treesitter indent, il est buggé)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    -- Utiliser smartindent au lieu de Treesitter indentexpr
    vim.opt_local.indentexpr = ""
    vim.opt_local.smartindent = true
    vim.opt_local.cindent = false
  end
})

local map = vim.keymap.set

-- Code actions
local ok_actions_preview, actions_preview = pcall(require, "actions-preview")
if ok_actions_preview then
  map({ "n" }, "<leader>fa", actions_preview.code_actions)
end

map({ "n" }, "<M-n>", "<cmd>resize +2<CR>")
map({ "n" }, "<M-e>", "<cmd>resize -2<CR>")
map({ "n" }, "<M-i>", "<cmd>vertical resize +5<CR>")
map({ "n" }, "<M-m>", "<cmd>vertical resize -5<CR>")
map({ "n" }, "<leader>c", "1z=")
map({ "n" }, "<C-q>", ":copen<CR>", { silent = true })


vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float(nil, {
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    border = 'rounded',
    source = 'always',
    prefix = ' ',
    scope = 'cursor',
  })
end, { desc = 'Show diagnostic float' })

vim.keymap.set('n', 'n', 'nzzzv')  -- Recherche toujours centrée
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y')  -- Copie vers clipboard système
vim.keymap.set("n", "<leader>a", ":edit #<CR>")  -- Retour au buffer précédent

-- Gestion des tabs
vim.keymap.set({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>", { desc = "Close tab" })

-- Navigation rapide entre tabs (1-8)
for i = 1, 8 do
  vim.keymap.set({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>", { desc = "Go to tab " .. i })
end
-- Configuration Telescope
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

vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, {
  noremap = true,
  silent = true,
  desc = "Find files"
})
