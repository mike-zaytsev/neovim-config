require("config.lazy")

vim.env.XDG_CONFIG_HOME = nil

require("config.themes")
require("keymaps.setup")
require("config.treesitter")

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex" },
    callback = function()
        vim.cmd("set tw=100")
    end,
})
