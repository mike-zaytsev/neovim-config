{
  pkgs,
  appName,
}:
pkgs.writeTextDir "${appName}/lua/config/nix_paths.lua" ''
  return {
      clangd = "${pkgs.clang-tools}/bin/clangd",
      cmake_language_server = "${pkgs.cmake-language-server}/bin/cmake-language-server",
      gopls = "${pkgs.gopls}/bin/gopls",
      lldb_dap = "${pkgs.lldb}/bin/lldb-dap",
      lua_ls = "${pkgs.lua-language-server}/bin/lua-language-server",
      nil_ls = "${pkgs.nil}/bin/nil",
      make = "${pkgs.gnumake}/bin/make",
      gcc = "${pkgs.gcc}/bin/gcc",
      glsl_analyzer = "${pkgs.glsl_analyzer}/bin/glsl_analyzer",
      pyright = "${pkgs.pyright}/bin/pyright-langserver",
      rust_analyzer = "${pkgs.rust-analyzer-unwrapped}/bin/rust-analyzer",
      ruff = "${pkgs.ruff}/bin/ruff",
      texlab = "${pkgs.texlab}/bin/texlab",
      slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp",
      vscode_css = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server",
      vscode_html = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server",
      vscode_json = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server",
  }
''
