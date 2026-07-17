return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function () 
		local configs = require("nvim-treesitter.configs")

	      	configs.setup({
		ensure_installed = { "c", "lua", "vim", "vimdoc", "rust", "go", "cpp", "javascript", "typescript", "tsx", "html", "css", "php" },
		sync_install = false,
		highlight = { enable = true },
		-- Désactiver Treesitter indent (buggé avec TypeScript/TSX), on utilise smartindent
		indent = { enable = false },  
	})
	end
}
