local utility = require("utility")
local constants = require("constants")

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
	undodir = utility.ensure_directory(constants.HOME_DIR .. "/.vim/undos"),
	hlsearch = false,
	incsearch = true,
	completeopt = "menu,menuone,noselect",
	updatetime = 250,
	timeout = true,
	timeoutlen = 300,
	foldmethod = "expr",
	foldexpr = "nvim_treesitter#foldexpr()",
	foldenable = false,
})

utility.apply_theme("slate")

local function on_attach(_, bufnr)
	local lnmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", "<leader>" .. keys, func, {
			buffer = bufnr,
			desc = desc,
		})
	end

	local Telescope = require("telescope.builtin")
	local Buffer = vim.lsp.buf
	lnmap("rn", Buffer.rename, "[r]e[n]ame")
	lnmap("ca", Buffer.code_action, "[c]ode [a]ction")

	lnmap("gd", Buffer.definition, "[g]oto [d]efinition")
	lnmap("gD", Buffer.declaration, "[g]oto [d]eclaration")
	lnmap("gi", Buffer.implementation, "[g]oto [i]mplementation")
	lnmap("td", Buffer.type_definition, "[t]ype [d]efinition")
	lnmap("fr", Telescope.lsp_references, "[f]ind [r]eferences")
	lnmap("fds", Telescope.lsp_document_symbols, "[f]ind [d]ocument [s]ymbols")
	lnmap(
		"fws",
		Telescope.lsp_dynamic_workspace_symbols,
		"[f]ind [w]orkspace [s]ymbols"
	)

	lnmap("K", Buffer.hover, "Hover Documentation")
	lnmap("<C-k>", Buffer.signature_help, "Signature Documentation")

	lnmap("wa", Buffer.add_workspace_folder, "[w]orkspace [a]dd folder")
	lnmap("wr", Buffer.remove_workspace_folder, "[w]orkspace [r]emove folder")
	lnmap(
		"wl",
		function()
			print(vim.inspect(Buffer.list_workspace_folders()))
		end,
		"[w]orkspace [l]ist folders"
	)

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(
		bufnr,
		"Format",
		function(_)
			Buffer.format()
		end,
		{ desc = "Format current buffer with LSP" }
	)
end

--
-- MISC
--
require("neodev").setup() -- help with init.lua
require("which-key").setup() -- help with keymaps
require("Comment").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = utility.pluck(
		constants.PREFERRED_LANGUAGES,
		"treesitter"
	),
	highlight = { enable = true },
})

--
-- LSP
--
local servers = {
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
	intelephense = {
		init_options = { licenceKey = constants.INTELEPHENSE_LICENCE_KEY },
	},
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = utility.pluck(constants.PREFERRED_LANGUAGES, "mason"),
})

local lsp_config = require("lspconfig")
mason_lspconfig.setup_handlers({ function(server_name)
-- capabilities = capabilities,
	lsp_config[server_name].setup({
		on_attach = on_attach,
		settings = servers[server_name],
		root_dir = vim.loop.cwd,
	})
end })

--
-- AUTOCOMPLETE
--
local cmp = require("cmp")
local luasnip = require("luasnip")
local select_opts = { behavior = cmp.SelectBehavior.Select }

luasnip.config.setup({})
cmp.setup({
	sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
	snippet = { expand = function(args)
		luasnip.lsp_expand(args.body)
	end },
	mapping = {
		["<Up>"] = cmp.mapping.select_prev_item(select_opts),
		["<Down>"] = cmp.mapping.select_next_item(select_opts),
		["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
		["<C-n>"] = cmp.mapping.select_next_item(select_opts),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<C-f>"] = cmp.mapping(
			function(fallback)
				if luasnip.jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end,
			{ "i", "s" }
		),
		["<C-b>"] = cmp.mapping(
			function(fallback)
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end,
			{ "i", "s" }
		),
		["<Tab>"] = cmp.mapping(
			function(fallback)
				local col = vim.fn.col(".") - 1

				if cmp.visible() then
					cmp.select_next_item(select_opts)
				elseif col == 0 or vim.fn.getline("."):sub(col, col):match(
					"%s"
				) then
					fallback()
				else
					cmp.complete()
				end
			end,
			{ "i", "s" }
		),
	},
})

--
-- FORMATTING
--
local prettier = require("formatter.defaults.prettier")
local filetype =
	{ ["*"] = require("formatter.filetypes.any").remove_trailing_whitespace }
for _, value in
	pairs(utility.pluck(constants.PREFERRED_LANGUAGES, "prettier"))
do
	filetype[value] = prettier
end
require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.WARN,
	filetype = filetype,
})

vim.cmd(
	[[
		augroup FormatAutogroup
		autocmd!
		autocmd BufWritePost * FormatWrite
		augroup END
		]]
)

--
-- KEYMAPS
--
local function lnset(keys, fn, desc)
	vim.keymap.set("n", "<leader>" .. keys, fn, { desc = desc })
end
local function ncmd(keys, cmd, desc)
	local fn = function()
		vim.cmd(cmd)
	end
	lnset(keys, fn, desc)
end

vim.g.mapleader = ","
ncmd("ex", "Ex", "[ex]plore filesystem")
ncmd("qc", "cclose", "[q]uick list [c]lose")
ncmd("qp", "cprev", "[q]uick list [p]revious")
ncmd("qn", "cnext", "[q]uick list [n]ext")
lnset("p", '"+p', "[p]aste from clipboard")

local Telescope = require("telescope.builtin")
lnset("fr", Telescope.oldfiles, "[f]ind [r]ecently opened files")
lnset("fb", Telescope.buffers, "[f]ind [b]uffers")
lnset("fc", Telescope.current_buffer_fuzzy_find, "[f]ind [c]urrent buffer")
lnset("fp", Telescope.git_files, "[f]ind [p]roject (git files)")
lnset("ff", Telescope.find_files, "[f]ind [f]iles")
lnset("fh", Telescope.help_tags, "[f]ind [h]elp")
lnset("fw", Telescope.grep_string, "[f]ind current [w]ord")
lnset("fg", Telescope.live_grep, "[f]ind by [g]rep")
lnset("fd", Telescope.diagnostics, "[f]ind [d]iagnostics")

local Diagnostics = vim.diagnostic
lnset("gdp", Diagnostics.goto_prev, "[g]oto [d]iagnostic [p]revious")
lnset("gdn", Diagnostics.goto_next, "[g]oto [d]iagnostic [n]ext")
lnset("dm", Diagnostics.open_float, "open [d]iagnostic [m]essage")
lnset("dl", Diagnostics.setloclist, "open [d]iagnostic [l]ist")
