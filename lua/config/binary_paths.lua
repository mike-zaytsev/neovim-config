local status, nix_paths = pcall(require, "config.nix_paths")
if status then
    return nix_paths
end

local gopath = vim.system({ "go", "env", "GOPATH" }):wait().stdout
return {
    clangd = vim.fn.exepath("clangd"),
    cmake_language_server = vim.fn.exepath("cmake-language-server"),
    gopls = string.sub(gopath, 1, -2) .. "/bin/gopls",
    lldb_dap = vim.fn.exepath("lldb-dap"),
    lua_ls = vim.fn.exepath("lua-language-server"),
    make = vim.fn.exepath("make"),
    gcc = vim.fn.exepath("gcc"),
    nil_ls = vim.fn.exepath("nil"),
    pyright = vim.fn.exepath("pyright-langserver"),
    ruff = vim.fn.exepath("ruff"),
    texlab = vim.fn.exepath("texlab"),
    slint_lsp = vim.fn.exepath("slint-lsp"),
    vscode_css = vim.fn.exepath("vscode-css-language-server"),
    vscode_html = vim.fn.exepath("vscode-html-language-server"),
    vscode_json = vim.fn.exepath("vscode-json-language-server"),
}
