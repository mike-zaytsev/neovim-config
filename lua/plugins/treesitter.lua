return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local nvim_ts = require("nvim-treesitter")
            nvim_ts.setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
                highlight = { enable = true },
                indent = { enable = true },
            })
            nvim_ts.install({
                "lua",
                "asm",
                "c",
                "cpp",
                "cmake",
                "cuda",
                "rust",
                "toml",
                "python",
                "typescript",
                "vim",
                "vimdoc",
                "markdown",
                "hyprlang",
                "yaml",
                "yuck",
                "nix",
                "json",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "rust", "c", "cpp", "lua", "toml", "markdown" },
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                end,
            })
        end,
    },
}
