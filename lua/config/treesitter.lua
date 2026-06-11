vim.api.nvim_create_autocmd("FileType", {
    pattern = { "rust", "c", "cpp", "lua", "toml", "markdown" },
    callback = function()
        vim.treesitter.start()
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
    end,
})
return {}
