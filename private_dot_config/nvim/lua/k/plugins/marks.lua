return {
  'chentoast/marks.nvim',
  opts = {
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
  }
}
