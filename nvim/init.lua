HOME_DIR = os.getenv("HOME")

local function ensure_directory(path)
    if os.execute("test -d '" .. path .. "'") ~= 0 then
        os.execute("mkdir -p " .. path)
    end
    return path
end

local function apply_options(options)
    for key, value in pairs(options) do
        vim.opt[key] = value
    end
end

local function apply_sets(options)
    for _, value in pairs(options) do
        vim.cmd("set " .. value)
    end
end

local function install_plugins(plugins)
    local file = HOME_DIR .. "/.vim/autoload/plug.vim"
    local url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    if os.execute("test -f '" .. file .. "'") ~= 0 then
        print("Downloading Plug")
        os.execute("curl -fLo " .. file .. " --create-dirs " .. url)
    end

    vim.call("plug#begin", HOME_DIR .. "/.vim/plugged")
    for key, value in pairs(plugins) do
        if value == false then
            vim.fn["plug#"](key)
        else
            vim.fn["plug#"](key, value)
        end
    end
    vim.call("plug#end")
end

apply_options({
    -- general
    wrap = false,
    colorcolumn = "80",
    termguicolors = false,
    -- line number
    number = true,
    scrolloff = 10,
    -- indentation
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    smartindent = true,
    -- long-lasting undos
    swapfile = false,
    backup = false,
    undofile = true,
    undodir = ensure_directory(HOME_DIR .. "/.vim/undos"),
    -- search
    hlsearch = false,
    incsearch = true,
})

apply_sets({
    "autochdir",
})

vim.cmd("colorscheme slate")
-- prevent the illusion that the cursor has jumped to the matching paren
vim.cmd("hi MatchParen ctermfg=none ctermbg=none guifg=none guibg=none")
-- restore transparency after setting colorscheme
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

install_plugins({
    ["mbbill/undotree"] = false,
    ["williamboman/mason.nvim"] = {
        ["do"] = function () vim.call("MasonUpdate") end
    },
    ["williamboman/mason-lspconfig.nvim"] = false,
    ["neovim/nvim-lspconfig"] = false,
    ["mhartington/formatter.nvim"] = false,
})

local lsp_config = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        -- tooling
        "lua_ls",
        "bashls",
        "marksman",
        "yamlls",
        -- web
        "html",
        "unocss",
        "tsserver",
        "jsonls",
        -- backend
        "intelephense",
        "sqlls",
        -- ops
        "dockerls",
        "docker_compose_language_service",
        -- backend
        -- hobby
        "denols",
        "svelte",
    },
    handlers = {
        function (server_name)
            lsp_config[server_name].setup({})
        end,
        ["lua_ls"] = function ()
            lsp_config.lua_ls.setup {
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            globals = {
                                'vim',
                                'require'
                            },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
        ["intelephense"] = function ()
            lsp_config.intelephense.setup({
                init_options = {
                    licenceKey = os.getenv("INTELEPHENSE_LICENCE_KEY"),
                },
            })
        end,
    },
})

local prettier = require("formatter.defaults.prettier")
require("formatter").setup({
    logging = true,
    log_level = vim.log.levels.WARN,
    filetype = {
        -- tooling
        ["sh"] = prettier,
        -- web
        ["html"] = prettier,
        ["css"] = prettier,
        ["javascript"] = prettier,
        ["javascriptreact"] = prettier,
        ["typescript"] = prettier,
        ["typescriptreact"] = prettier,
        ["json"] = prettier,
        -- backend
        ["php"] = prettier,
        ["sql"] = prettier,
        -- hobby
        ["svelte"] = prettier,
        ["*"] = {
            require("formatter.filetypes.any").remove_trailing_whitespace
        },
    },
})

vim.cmd([[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost * FormatWrite
augroup END
]])
