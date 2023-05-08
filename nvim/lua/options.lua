local utility = require("utility")

vim.filetype.add({
	extension = { astro = "astro" },
})

utility.apply_options({
	wrap = false,
	colorcolumn = "80",
	termguicolors = false,
	signcolumn = "yes",
	number = true,
	scrolloff = 10,
	ignorecase = true,
	smartcase = true,
	tabstop = 4,
	softtabstop = 4,
	shiftwidth = 4,
	expandtab = true,
	smartindent = true,
	swapfile = false,
	backup = false,
	undofile = true,
	undodir = utility.ensure_directory(HOME_DIR .. "/.vim/undos"),
	hlsearch = false,
	incsearch = true,
	completeopt = "menu,menuone,noselect",
	updatetime = 250,
	timeout = true,
	timeoutlen = 300,
})

utility.apply_sets({
	foldmethod = "expr",
	foldexpr = "nvim_treesitter#foldexpr()",
	nofoldenable = false,
})
