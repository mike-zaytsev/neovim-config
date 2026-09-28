---@class BinaryPaths
---@field clangd string
---@field cmake_language_server string
---@field gopls string
---@field lldb_dap string
---@field lua_ls string
---@field nil_ls string
---@field make string
---@field gcc string
---@field glsl_analyzer string
---@field pyright string
---@field rust_analyzer string
---@field ruff string
---@field texlab string
---@field slint_lsp string
---@field vscode_css string
---@field vscode_html string
---@field vscode_json string

---@type BinaryPaths
local nix_paths = require("config.nix_paths")

return nix_paths
