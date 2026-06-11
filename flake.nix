{
  description = "Self-contained Neovim setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      appName = "nvim-flake";

      binPaths = pkgs.writeTextDir "${appName}/lua/config/nix_paths.lua" ''
        return {
            clangd = "${pkgs.clang-tools}/bin/clangd",
            cmake_language_server = "${pkgs.cmake-language-server}/bin/cmake-language-server",
            gopls = "${pkgs.gopls}/bin/gopls",
            lldb_dap = "${pkgs.lldb}/bin/lldb-dap",
            lua_ls = "${pkgs.lua-language-server}/bin/lua-language-server",
            nil_ls = "${pkgs.nil}/bin/nil",
            make = "${pkgs.gnumake}/bin/make",
            pyright = "${pkgs.pyright}/bin/pyright-langserver",
            ruff = "${pkgs.ruff}/bin/ruff",
            texlab = "${pkgs.texlab}/bin/texlab",
            slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp",
        }
      '';

      tsLangs = with pkgs.tree-sitter-grammars; {
        lua = tree-sitter-lua;
        c = tree-sitter-c;
        cpp = tree-sitter-cpp;
        cmake = tree-sitter-cmake;
        cuda = tree-sitter-cuda;
        rust = tree-sitter-rust;
        toml = tree-sitter-toml;
        python = tree-sitter-python;
        typescript = tree-sitter-typescript;
        vim = tree-sitter-vim;
        markdown = tree-sitter-markdown;
        hyprlang = tree-sitter-hyprlang;
        yaml = tree-sitter-yaml;
        nix = tree-sitter-nix;
        json = tree-sitter-json;
      };

      parsers = pkgs.linkFarm "tree-sitter-parsers" (
        builtins.attrValues (
          builtins.mapAttrs (lang: grammar: {
            name = "${appName}/parser/${lang}.so";
            path = "${grammar}/parser";
          }) tsLangs
        )
      );

      queries = pkgs.linkFarm "tree-sitter-queries" (
        builtins.filter ({ path, ... }: builtins.pathExists "${path}/.") (
          builtins.attrValues (
            builtins.mapAttrs (lang: grammar: {
              name = "${appName}/queries/${lang}";
              path = "${grammar}/queries";
            }) tsLangs
          )
        )
      );

      configTree = pkgs.runCommand "nvim-config-tree" { } ''
        mkdir -p "$out/${appName}"
        cp ${./init.lua} "$out/${appName}/init.lua"
        cp -r ${./lua} "$out/${appName}/lua"
      '';

      configHome = pkgs.symlinkJoin {
        name = "nvim-config-home";
        paths = [
          configTree
          binPaths
          parsers
          queries
        ];
      };
    in
    {
      packages.${system} = {
        default = pkgs.writeShellApplication {
          name = "nvim";
          runtimeInputs = with pkgs; [
            neovim

            git
            lua51Packages.lua
            lua51Packages.luarocks

            curl
            fd
            gnutar
            ripgrep
            tree-sitter

            rust-analyzer-unwrapped
          ];
          runtimeEnv = {
            NVIM_APPNAME = appName;
            XDG_CONFIG_HOME = configHome;
          };
          text = ''
            exec ${pkgs.neovim}/bin/nvim "$@"
          '';
        };
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/nvim";
      };
    };
}
