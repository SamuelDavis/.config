local constants = require("constants")
local utility = require("utility")

local function on_attach(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, {
			buffer = bufnr,
			desc = desc,
		})
	end

	local Telescope = require("telescope.builtin")
	local Buffer = vim.lsp.buf
	nmap("<leader>rn", Buffer.rename, "[r]e[n]ame")
	nmap("<leader>ca", Buffer.code_action, "[c]ode [a]ction")

	nmap("<leader>gd", Buffer.definition, "[g]oto [d]efinition")
	nmap("<leader>gD", Buffer.declaration, "[g]oto [d]eclaration")
	nmap("<leader>gr", Telescope.lsp_references, "[g]oto [r]eferences")
	nmap("<leader>gi", Buffer.implementation, "[g]oto [i]mplementation")
	nmap("<leader>td", Buffer.type_definition, "[t]ype [d]efinition")
	nmap(
		"<leader>sds",
		Telescope.lsp_document_symbols,
		"[s]earch [d]ocument [s]ymbols"
	)
	nmap(
		"<leader>sws",
		Telescope.lsp_dynamic_workspace_symbols,
		"[s]earch [w]orkspace [s]ymbols"
	)

	nmap("K", Buffer.hover, "Hover Documentation")
	nmap("<C-k>", Buffer.signature_help, "Signature Documentation")

	nmap("<leader>wa", Buffer.add_workspace_folder, "[w]orkspace [a]dd folder")
	nmap(
		"<leader>wr",
		Buffer.remove_workspace_folder,
		"[w]orkspace [r]emove folder"
	)
	nmap(
		"<leader>wl",
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

local function configure_misc()
	require("neodev").setup() -- help with init.lua
	require("Comment").setup()
	require("nvim-treesitter.configs").setup({
		ensure_installed = utility.pluck(
			constants.PREFERRED_LANGUAGES,
			"treesitter"
		),
		highlight = { enable = true },
	})
end

local function configure_lsp()
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
		ensure_installed = utility.pluck(
			constants.PREFERRED_LANGUAGES,
			"mason"
		),
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
end

local function configure_autocomplete()
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
end

local function configure_formatting()
	local prettier = require("formatter.defaults.prettier")
	local filetype =
		{
			["*"] = require(
				"formatter.filetypes.any"
			).remove_trailing_whitespace,
		}
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
end

local function configure_keymaps()
	local function nset(keys, fn, desc)
		vim.keymap.set("n", "<leader>" .. keys, fn, { desc = desc })
	end
	local function ncmd(keys, cmd, desc)
		local fn = function()
			vim.cmd(cmd)
		end
		nset(keys, fn, desc)
	end

	require("which-key").setup()
	vim.g.mapleader = ","
	ncmd("ex", "Ex", "[ex]plore filesystem")
	ncmd("qc", "cclose", "[q]uick list [c]lose")
	ncmd("qp", "cprev", "[q]uick list [p]revious")
	ncmd("qn", "cnext", "[q]uick list [n]ext")
	nset("p", '"+p', "[p]aste from clipboard")

	local Telescope = require("telescope.builtin")
	nset("fr", Telescope.oldfiles, "[f]ind [r]ecently opened files")
	nset("fb", Telescope.buffers, "[f]ind [b]uffers")
	nset("fc", Telescope.current_buffer_fuzzy_find, "[f]ind [c]urrent buffer")
	nset("fp", Telescope.git_files, "[f]ind [p]roject (git files)")
	nset("ff", Telescope.find_files, "[f]ind [f]iles")
	nset("fh", Telescope.help_tags, "[f]ind [h]elp")
	nset("fw", Telescope.grep_string, "[f]ind current [w]ord")
	nset("fg", Telescope.live_grep, "[f]ind by [g]rep")
	nset("fd", Telescope.diagnostics, "[f]ind [d]iagnostics")

	local Diagnostics = vim.diagnostic
	nset("gdp", Diagnostics.goto_prev, "[g]oto [d]iagnostic [p]revious")
	nset("gdn", Diagnostics.goto_next, "[g]oto [d]iagnostic [n]ext")
	nset("dm", Diagnostics.open_float, "open [d]iagnostic [m]essage")
	nset("dl", Diagnostics.setloclist, "open [d]iagnostic [l]ist")
end

return {
	misc = configure_misc,
	lsp = configure_lsp,
	autocomplete = configure_autocomplete,
	formatting = configure_formatting,
	keymaps = configure_keymaps,
}
