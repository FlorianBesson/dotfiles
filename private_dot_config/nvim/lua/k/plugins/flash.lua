return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Auto-centrage après jump
    action = function(match, state)
      state:hide()
      vim.api.nvim_win_set_cursor(0, match.pos)
      vim.cmd("normal! zz") -- Centrer après jump
    end,
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
