local gopath = vim.system({ "go", "env", "GOPATH" }):wait().stdout

return {
    clangd = vim.fn.exepath("clangd"),
    lua_ls = vim.fn.exepath("lua-language-server"),
    pyright = vim.fn.exepath("pyright"),
    ruff = vim.fn.exepath("ruff"),
    gopls = string.sub(gopath, 1, -2) .. "/bin/gopls",
}
