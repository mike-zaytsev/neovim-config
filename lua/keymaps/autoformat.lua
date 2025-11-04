local autoformat_enabled = true

vim.api.nvim_create_autocmd("BufWrite", {
    callback = function()
        if autoformat_enabled then
            vim.lsp.buf.format()
        end
    end,
})

local function toggle_autoformat()
    autoformat_enabled = not autoformat_enabled
    local state = ""
    if autoformat_enabled then
        state = "enabled"
    else
        state = "disabled"
    end
    print("autoformat on write " .. state)
end

return {
    {
        keys = "<leader>tf",
        command = toggle_autoformat,
    },
    {
        keys = "<leader>ff",
        command = vim.lsp.buf.format,
    },
}
