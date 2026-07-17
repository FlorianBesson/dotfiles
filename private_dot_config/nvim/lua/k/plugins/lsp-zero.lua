return {
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
  },

  { 'williamboman/mason.nvim', lazy = false, opts = {} },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
          'html',
          'cssls',
          'emmet_ls',
          'tailwindcss',
          'ts_ls',
          'intelephense',
        },
      })

      -- Keymaps LSP
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', vim.lsp.buf.format, opts)
          vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      -- lua
      vim.lsp.config.lua_ls = {
        cmd = { mason_bin .. "/lua-language-server" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME }
            },
            diagnostics = { globals = { 'vim' } },
            telemetry = { enable = false },
          },
        },
      }
      vim.lsp.enable('lua_ls')

      -- web
      vim.lsp.config.html = {
        cmd = { mason_bin .. "/vscode-html-language-server", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('html')

      vim.lsp.config.cssls = {
        cmd = { mason_bin .. "/vscode-css-language-server", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('cssls')

      vim.lsp.config.emmet_ls = {
        cmd = { mason_bin .. "/emmet-ls", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('emmet_ls')

      vim.lsp.config.tailwindcss = {
        cmd = { mason_bin .. "/tailwindcss-language-server", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('tailwindcss')

      -- typescript/javascript
      vim.lsp.config.ts_ls = {
        cmd = { mason_bin .. "/typescript-language-server", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('ts_ls')

      -- php
      vim.lsp.config.intelephense = {
        cmd = { mason_bin .. "/intelephense", "--stdio" },
        capabilities = capabilities
      }
      vim.lsp.enable('intelephense')
    end,
  },
}
