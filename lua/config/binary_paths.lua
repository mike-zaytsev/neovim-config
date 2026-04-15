local status, nix_paths = pcall(require, "config.nix_paths")
if status then
    return nix_paths
end

local gopath = vim.system({ "go", "env", "GOPATH" }):wait().stdout
return {
    clangd = vim.fn.exepath("clangd"),
    lua_ls = vim.fn.exepath("lua-language-server"),
    pyright = vim.fn.exepath("pyright-langserver"),
    ruff = vim.fn.exepath("ruff"),
    slint_lsp = vim.fn.exepath("slint-lsp"),
    gopls = string.sub(gopath, 1, -2) .. "/bin/gopls",
}
