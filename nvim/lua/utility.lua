local function ensure_directory(path)
    if os.execute("test -d \"" .. path .. "\"") ~= 0 then
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
    for key, value in pairs(options) do
        if value ~= false then
            key = key .. "=" .. value
        end
        vim.cmd("set " .. key)
    end
end

local function apply_theme(name)
    vim.cmd("colorscheme " .. name)
    -- prevent the illusion that the cursor has jumped to the matching paren
    vim.cmd("hi MatchParen ctermfg=none ctermbg=none guifg=none guibg=none")
    -- restore transparency after setting colorscheme
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

local function install_plugins(plugins)
    local file = '"${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim'
    local url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    if os.execute("test -f " .. file) ~= 0 then
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

local function pluck(table, key)
    local i = 1
    local result = {}
    for _, value in pairs(table) do
        if value[key] ~= nil then
            result[i] =value[key]
            i = i + 1
        end
    end
    return result
end

return {
    ensure_directory = ensure_directory,
    apply_options = apply_options,
    apply_sets = apply_sets,
    apply_theme = apply_theme,
    install_plugins = install_plugins,
    pluck = pluck,
}