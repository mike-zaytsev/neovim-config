vim.g.moonflyTransparent = true
require("catppuccin").setup({
    flavour = "latte",
    transparent_background = false,
})

local themes = {
    {
        name = "nightfly",
    },
    {
        name = "moonfly",
    },
    {
        name = "catppuccin",
    }
}

local function set_theme(theme)
    vim.cmd.colorscheme(theme.name)
end

local function select_theme()
    vim.ui.select(themes, {
        format_item = function(theme)
            return theme.name
        end,
        prompt = "Select theme",
    }, function(theme)
        if theme ~= nil then
            set_theme(theme)
        end
    end)
end

set_theme(themes[2])
vim.api.nvim_create_user_command("SelectTheme", select_theme, {})
