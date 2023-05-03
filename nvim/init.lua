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
            vim.fn["plug#"](key, config)
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
})
