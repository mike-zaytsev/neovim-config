require("config.lazy")

vim.g.moonflyTransparent = true
require("catppuccin").setup({
    flavour = "latte",
    transparent_background = false,
})
vim.cmd.colorscheme("moonfly")
-- vim.cmd.colorscheme("catppuccin")

require("keymaps.setup")

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex" },
    callback = function()
        vim.cmd("set tw=100")
    end,
})
