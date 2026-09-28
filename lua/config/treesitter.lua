vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(event)
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
        if not lang then
            return
        end

        local ok = pcall(vim.treesitter.language.add, lang)
        if not ok then
            return
        end

        pcall(vim.treesitter.start, event.buf, lang)
    end,
})
