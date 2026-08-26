return {
  'chentoast/marks.nvim',
  config = function()
    require('marks').setup({
      -- Seulement afficher les marks quand on les utilise explicitement
      default_mappings = true,
      -- Marks built-in utiles (sélection visuelle + dernière position)
      builtin_marks = { "<", ">", "^" },
      -- Désactiver les marques automatiques qui popent partout
      cyclic = true,
      force_write_shada = false,
      -- Refresh uniquement quand nécessaire
      refresh_interval = 250,
      -- Ne pas afficher de signes pour les marks a-z (lettres)
      sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
      -- Masquer les marks par défaut (utiliser :MarksToggleSigns pour les voir)
      excluded_filetypes = {},
      -- Keymaps utiles
      mappings = {
        set_next = "m,",      -- Créer mark sur la prochaine lettre disponible
        next = "m]",          -- Aller au mark suivant
        prev = "m[",          -- Aller au mark précédent
        delete_line = "dm-",  -- Supprimer tous les marks de la ligne
        delete_buf = "dm<space>", -- Supprimer tous les marks du buffer
      }
    })
    
    -- Auto-centrage après navigation vers marks
    -- Override les mappings pour ajouter centrage
    vim.keymap.set('n', 'm]', function()
      require('marks').next()
      vim.cmd('normal! zz')
    end, { desc = "Next mark (centered)" })
    
    vim.keymap.set('n', 'm[', function()
      require('marks').prev()
      vim.cmd('normal! zz')
    end, { desc = "Prev mark (centered)" })
    
    -- Centrage aussi pour les sauts directs vers marks ('a, `a, etc.)
    for _, key in ipairs({"'", "`"}) do
      vim.keymap.set('n', key, function()
        local char = vim.fn.getcharstr()
        -- Utiliser feedkeys pour ne pas perdre le caractère
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(key .. char, true, false, true), 
          'n', 
          false
        )
        -- Centrer après le jump (schedule évite race condition)
        vim.schedule(function()
          vim.cmd('normal! zz')
        end)
      end, { noremap = true, silent = true, desc = "Jump to mark (centered)" })
    end
  end
}
