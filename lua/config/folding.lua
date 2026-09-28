local lsp_folding_method = "textDocument/foldingRange"
local lsp_foldexpr = "v:lua.vim.lsp.foldexpr()"
local treesitter_foldexpr = "v:lua.vim.treesitter.foldexpr()"

local function windows_for_buffer(bufnr)
    return vim.tbl_filter(function(win)
        return vim.api.nvim_win_get_buf(win) == bufnr
    end, vim.api.nvim_list_wins())
end

local function has_lsp_folds(bufnr)
    return next(vim.lsp.get_clients({ bufnr = bufnr, method = lsp_folding_method })) ~= nil
end

local function has_treesitter_folds(bufnr)
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then
        return false
    end

    local parser_ok = pcall(vim.treesitter.language.add, lang)
    if not parser_ok then
        return false
    end

    local query_ok, query = pcall(vim.treesitter.query.get, lang, "folds")
    return query_ok and query ~= nil
end

local function set_expr_folding(win, foldexpr)
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = foldexpr
end

local function reset_managed_folding(win)
    local foldexpr = vim.wo[win][0].foldexpr
    if foldexpr == lsp_foldexpr or foldexpr == treesitter_foldexpr then
        vim.wo[win][0].foldmethod = "manual"
        vim.wo[win][0].foldexpr = "0"
    end
end

local function apply_to_window(bufnr, win)
    if has_lsp_folds(bufnr) then
        set_expr_folding(win, lsp_foldexpr)
    elseif has_treesitter_folds(bufnr) then
        set_expr_folding(win, treesitter_foldexpr)
    else
        reset_managed_folding(win)
    end
end

local function apply_to_buffer(bufnr)
    for _, win in ipairs(windows_for_buffer(bufnr)) do
        apply_to_window(bufnr, win)
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(event)
        apply_to_buffer(event.buf)
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(event)
        apply_to_window(event.buf, vim.api.nvim_get_current_win())
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(lsp_folding_method, event.buf) then
            apply_to_buffer(event.buf)
        end
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(event)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(event.buf) then
                apply_to_buffer(event.buf)
            end
        end)
    end,
})

vim.lsp.handlers["client/registerCapability"] = (function(overridden)
    return function(err, result, ctx, config)
        local ret = overridden and overridden(err, result, ctx, config) or nil
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for bufnr in pairs(client.attached_buffers) do
                apply_to_buffer(bufnr)
            end
        end
        return ret
    end
end)(vim.lsp.handlers["client/registerCapability"])

vim.lsp.handlers["client/unregisterCapability"] = (function(overridden)
    return function(err, result, ctx, config)
        local ret = overridden and overridden(err, result, ctx, config) or nil
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for bufnr in pairs(client.attached_buffers) do
                apply_to_buffer(bufnr)
            end
        end
        return ret
    end
end)(vim.lsp.handlers["client/unregisterCapability"])
