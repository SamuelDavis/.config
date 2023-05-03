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
    -- undo diffs
    ["mbbill/undotree"] = false,
    -- language server
    ["williamboman/mason.nvim"] = {
        ["do"] = function () vim.call("MasonUpdate") end
    },
    ["williamboman/mason-lspconfig.nvim"] = false,
    ["neovim/nvim-lspconfig"] = false,
    -- formatter
    ["mhartington/formatter.nvim"] = false,
    -- fuzzy-finder
    ["nvim-lua/plenary.nvim"] = false,
    ["nvim-telescope/telescope.nvim"] = { ["tag"] = "0.1.1" },
    -- Autocompletion
    ["hrsh7th/nvim-cmp"] = false,
    ["hrsh7th/cmp-nvim-lsp"] = false,
    ["L3MON4D3/LuaSnip"] = false,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
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
            local options = {
                ["capabilities"] = capabilities,
            }

            if server_name == "intelephense" then
                options.init_options = {
                    ["licenceKey"] = os.getenv("INTELEPHENSE_LICENCE_KEY"),
                }
            end

            lsp_config[server_name].setup(options)
        end,
    },
})

local cmp = require 'cmp'
cmp.setup {
    preselect = "item",
    completion = { completeopt = "menu,menuone,noinsert" },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
    },
}

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

vim.g.mapleader = ","
-- paste+replace without losing yanked value
vim.keymap.set({"n", "v"}, "<leader>p", "\"_dP")
-- yank to system clipboard
vim.keymap.set({"n", "v"}, "<leader>Y", "\"+y")
-- paste from system clipboard
vim.keymap.set("n", "<leader>P", "\"+p")
vim.keymap.set("v", "<leader>P", "\"_d\"+p")
-- view project filetree
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
local Telescope = require("telescope.builtin")
-- fuzzy-find file
vim.keymap.set("n", "<leader>ff", Telescope.find_files, {})
-- fuzzy-find text (in buffers, {})
vim.keymap.set("n", "<leader>fg", Telescope.live_grep, {})
-- fuzzy-find file in git
vim.keymap.set("n", "<leader>fp", Telescope.git_files, {})
-- fuzzy-find symbol
vim.keymap.set("n", "<leader>fs", Telescope.lsp_dynamic_workspace_symbols, {})
-- find definitions
vim.keymap.set("n", "<leader>fd", Telescope.lsp_definitions, {})
-- find references
vim.keymap.set("n", "<leader>fr", Telescope.lsp_references, {})
