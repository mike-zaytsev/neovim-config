require("config.lazy")

vim.g.moonflyTransparent = true
-- require("catppuccin").setup({
-- 	flavour = "latte",
-- 	transparent_background = false,
-- })
vim.cmd.colorscheme("moonfly")

require("keymaps.setup")
