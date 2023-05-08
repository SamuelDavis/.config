local utility = require("utility")
local constants = require("constants")
local configure = require("configure")

utility.install_plugins(constants.HOME_DIR, {
	-- automatic tabstop / shiftwidth
	["tpope/vim-sleuth"] = false,
	-- lsp
	["folke/neodev.nvim"] = false, -- neovim lua specific
	["williamboman/mason.nvim"] = { ["do"] = function()
		vim.cmd("MasonUpdate")
	end },
	["williamboman/mason-lspconfig.nvim"] = false,
	["neovim/nvim-lspconfig"] = false,
	-- autocomplete
	["saadparwaiz1/cmp_luasnip"] = false,
	["L3MON4D3/LuaSnip"] = false,
	["hrsh7th/cmp-nvim-lsp"] = false,
	["hrsh7th/nvim-cmp"] = false,
	-- keybind help
	["folke/which-key.nvim"] = false,
	-- quick comment
	["numToStr/Comment.nvim"] = false,
	-- fuzzy find
	["nvim-lua/plenary.nvim"] = false,
	["nvim-telescope/telescope.nvim"] = { tag = "0.1.1" },
	-- ast
	["nvim-treesitter/nvim-treesitter-textobjects"] = false,
	["nvim-treesitter/nvim-treesitter"] = { ["do"] = function()
		vim.cmd("TSUpdate")
	end },
	-- formatter
	["mhartington/formatter.nvim"] = false,
})

utility.apply_theme("slate")
configure.misc()
configure.lsp()
configure.autocomplete()
configure.formatting()
configure.keymaps()
