local HOME_DIR = os.getenv("HOME")
local INTELEPHENSE_LICENCE_KEY = os.getenv("INTELEPHENSE_LICENCE_KEY")
local PREFERRED_LANGUAGES = {
	-- tooling
	lua = {
		treesitter = "lua",
		prettier = "lua",
		mason = "lua_ls",
	},
	bash = {
		treesitter = "bash",
		prettier = "sh",
		mason = "bashls",
	},
	json = {
		treesitter = "json",
		prettier = "json",
		mason = "jsonls",
	},
	yaml = {
		treesitter = "yaml",
		prettier = "yaml",
		mason = "yamlls",
	},
	yoml = {
		treesitter = "toml",
		prettier = "toml",
	},
	gitconfig = { treesitter = "git_config" },
	-- web
	html = {
		treesitter = "html",
		prettier = "html",
		mason = "html",
	},
	css = {
		treesitter = "css",
		prettier = "css",
		mason = "unocss",
	},
	js = {
		treesitter = "javascript",
		prettier = "javascript",
		mason = "tsserver",
	},
	ts = {
		treesitter = "typescript",
		prettier = "typescript",
		mason = "tsserver",
	},
	jsx = {
		treesitter = "javascript",
		prettier = "javascriptreact",
		mason = "tsserver",
	},
	tsx = {
		treesitter = "tsx",
		prettier = "typescriptreact",
		mason = "tsserver",
	},
	-- backend
	php = {
		treesitter = "php",
		prettier = "php",
		mason = "intelephense",
	},
	sql = {
		treesitter = "sql",
		prettier = "sql",
		mason = "sqlls",
	},
	dockerfile = {
		treesitter = "dockerfile",
		mason = "dockerls",
	},
	-- hobby
	svelte = {
		treesitter = "svelte",
		prettier = "svelte",
		mason = "svelte",
	},
	rust = {
		treesitter = "rust",
		mason = "rust_analyzer",
	},
	astro = {
		treesitter = "astro",
		prettier = "astro",
		mason = "astro",
	},
}

return {
	HOME_DIR = HOME_DIR,
	INTELEPHENSE_LICENCE_KEY = INTELEPHENSE_LICENCE_KEY,
	PREFERRED_LANGUAGES = PREFERRED_LANGUAGES,
}
