local HOME_DIR = os.getenv("HOME")
local PREFERRED_LANGUAGES = {
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
    { treesitter = "astro", prettier = "astro" },
}
local utility = require("utility")

vim.filetype.add({
    extension = {
        astro = "astro",
    },
})

utility.apply_options({
    -- general
    wrap = false,
    colorcolumn = "80",
    termguicolors = false,
    signcolumn = "yes",
    -- line number
    number = true,
    scrolloff = 10,
    -- ignore case in search
    ignorecase = true,
    smartcase = true,
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
    undodir = utility.ensure_directory(HOME_DIR .. "/.vim/undos"),
    -- search
    hlsearch = false,
    incsearch = true,
    -- always show autocomplete, force select
    completeopt = "menuone,noselect",
    -- decrease update time
    updatetime = 250,
    timeout = true,
    timeoutlen = 300,
})

utility.apply_sets({
    foldmethod = "expr",
    foldexpr = "nvim_treesitter#foldexpr()",
    nofoldenable = false,
})

utility.install_plugins(HOME_DIR, {
    -- automatic tabstop / shiftwidth
    ["tpope/vim-sleuth"] = false,
    -- lsp
    ["folke/neodev.nvim"] = false, -- neovim lua specific
    ["williamboman/mason.nvim"] = {
        ["do"] = function() vim.cmd("MasonUpdate") end,
    },
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
    ["nvim-telescope/telescope.nvim"] = {
        ["tag"] = "0.1.1",
    },
    -- ast
    ["nvim-treesitter/nvim-treesitter-textobjects"] = false,
    ["nvim-treesitter/nvim-treesitter"] = {
        ["do"] = function() vim.cmd("TSUpdate") end,
    },
    -- formatter
    ["mhartington/formatter.nvim"] = false,
})

utility.apply_theme("slate")
require("Comment").setup()
require("nvim-treesitter.configs").setup({
    ensure_installed = utility.pluck(PREFERRED_LANGUAGES, "treesitter"),
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
        init_options = {
            licenceKey = os.getenv("INTELEPHENSE_LICENCE_KEY"),
        },
    },
}

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
    ensure_installed = utility.pluck(PREFERRED_LANGUAGES, "mason"),
})

local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
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
    nmap("<leader>sds", Telescope.lsp_document_symbols, "[s]earch [d]ocument [s]ymbols")
    nmap("<leader>sws", Telescope.lsp_dynamic_workspace_symbols, "[s]earch [w]orkspace [s]ymbols")

    nmap("K", Buffer.hover, "Hover Documentation")
    nmap("<C-k>", Buffer.signature_help, "Signature Documentation")

    nmap("<leader>wa", Buffer.add_workspace_folder, "[w]orkspace [a]dd folder")
    nmap("<leader>wr", Buffer.remove_workspace_folder, "[w]orkspace [r]emove folder")
    nmap("<leader>wl", function()
        print(vim.inspect(Buffer.list_workspace_folders()))
    end, "[w]orkspace [l]ist folders")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        Buffer.format()
    end, { desc = "Format current buffer with LSP" })
end
local lsp_config = require("lspconfig")
mason_lspconfig.setup_handlers({
    function(server_name)
        lsp_config[server_name].setup({
            -- capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            root_dir = vim.loop.cwd
        })
    end,
})

--
-- AUTOCOMPLETE
--
local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.config.setup({})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})

--
-- FORMATTING
--
local prettier = require("formatter.defaults.prettier")
local filetype = {
    ["*"] = require("formatter.filetypes.any").remove_trailing_whitespace
}
for _, value in pairs(utility.pluck(PREFERRED_LANGUAGES, "prettier")) do
    filetype[value] = prettier
end
require("formatter").setup({
    logging = true,
    log_level = vim.log.levels.WARN,
    filetype = filetype,
})

vim.cmd([[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost * FormatWrite
augroup END
]])

--
-- KEYMAPS
--
require("which-key").setup()
vim.g.mapleader = ","
vim.keymap.set("n", "<leader>ex", function() vim.cmd("Ex") end, { desc = "[ex]plore filesystem" })

local Telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>fr", Telescope.oldfiles, { desc = "[f]ind [r]ecently opened files" })
vim.keymap.set("n", "<leader>fb", Telescope.buffers, { desc = "[f]ind [b]uffers" })
vim.keymap.set("n", "<leader>fc", Telescope.current_buffer_fuzzy_find, { desc = "[f]ind [c]urrent buffer" })
vim.keymap.set("n", "<leader>fp", Telescope.git_files, { desc = "[f]ind [p]roject (git files)" })
vim.keymap.set("n", "<leader>ff", Telescope.find_files, { desc = "[f]ind [f]iles" })
vim.keymap.set("n", "<leader>fh", Telescope.help_tags, { desc = "[f]ind [h]elp" })
vim.keymap.set("n", "<leader>fw", Telescope.grep_string, { desc = "[f]ind current [w]ord" })
vim.keymap.set("n", "<leader>fg", Telescope.live_grep, { desc = "[f]ind by [g]rep" })
vim.keymap.set("n", "<leader>fd", Telescope.diagnostics, { desc = "[f]ind [d]iagnostics" })

local Diagnostics = vim.diagnostic
vim.keymap.set("n", "<leader>gdp", Diagnostics.goto_prev, { desc = "[g]oto [d]iagnostic [p]revious" })
vim.keymap.set("n", "<leader>gdn", Diagnostics.goto_next, { desc = "[g]oto [d]iagnostic [n]ext" })
vim.keymap.set("n", "<leader>dm", Diagnostics.open_float, { desc = "open [d]iagnostic [m]essage" })
vim.keymap.set("n", "<leader>dl", Diagnostics.setloclist, { desc = "open [d]iagnostic [l]ist" })
