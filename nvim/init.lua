require("constants")
local utility = require("utility")
local configure = require("configure")

utility.apply_options({
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
    undodir = utility.ensure_directory(HOME_DIR .. "/.vim/undos"),
    -- search
    hlsearch = false,
    incsearch = true,
})

utility.apply_sets({
    foldmethod = "expr",
    foldexpr = "nvim_treesitter#foldexpr()",
    nofoldenable = false,
})

utility.install_plugins({
    -- theme
    ["doums/darcula"] = false,
    -- syntax tree
    ["nvim-treesitter/nvim-treesitter"] = {
        ["do"] = function() lua.cmd("TSUpdate") end,
    },
    -- quick commenting
    ["numToStr/Comment.nvim"] = false,
    -- fuzzy-finder
    ["nvim-lua/plenary.nvim"] = false,
    ["nvim-telescope/telescope.nvim"] = {
        tag = "0.1.1"
    },
    -- formatter
    ["mhartington/formatter.nvim"] = false,
    -- language server
    ["williamboman/mason.nvim"] = false,
    ["williamboman/mason-lspconfig.nvim"] = false,
    ["neovim/nvim-lspconfig"] = false,
    -- autocomplete
    ["hrsh7th/cmp-nvim-lsp"] = false,
    ["L3MON4D3/LuaSnip"] = false,
    ["saadparwaiz1/cmp_luasnip"] = false,
    ["hrsh7th/nvim-cmp"] = false,
})

utility.apply_theme("darcula")

configure.treesitter()
configure.comment()
configure.prettier()
configure.lsp()

vim.g.mapleader = ","
-- fuzzy-finder
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>?", "<cmd>Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>")
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
