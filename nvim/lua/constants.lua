HOME_DIR = os.getenv("HOME")
PREFERRED_LANGUAGES = {
    -- tooling
    { treesitter = "lua" },
    { treesitter = "bash", prettier = "sh" },
    { treesitter = "json", prettier = "json" },
    { treesitter = "yaml" },
    { treesitter = "toml" },
    { treesitter = "git_config" },
    -- web
    { treesitter = "html", prettier = "html" },
    { treesitter = "css", prettier = "css" },
    { treesitter = "javascript", prettier = "javascript" },
    { treesitter = "typescript", prettier = "typescript" },
    { prettier = "javascriptreact" },
    { treesitter = "tsx", prettier = "typescriptreact" },
    -- backend
    { treesitter = "php", prettier = "php" },
    { treesitter = "sql", prettier = "sql" },
    { treesitter = "dockerfile" },
    -- hobby
    { treesitter = "svelte", prettier = "svelte" },
    { treesitter = "rust" },
}
