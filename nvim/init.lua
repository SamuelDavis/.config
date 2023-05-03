local function ensure_directory(path)
    if not os.execute("cd " .. path) == 0 then
        os.execute("mkdir -p " .. path)
    end
end

local function apply_options(options)
    for key, value in pairs(options) do
        vim.opt[key] = value
    end
end

local colorscheme = "slate"
local home_directory = os.getenv("HOME")
local undo_directory = home_directory .. "/.vim/undos"

ensure_directory(undo_directory)
apply_options({
    -- general
    wrap = false,
    colorcolumn = "80",
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
    undodir = undo_directory,
    -- search
    hlsearch = false,
    incsearch = true,
})

vim.cmd("colorscheme " .. colorscheme)
-- restore transparency after setting colorscheme
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
