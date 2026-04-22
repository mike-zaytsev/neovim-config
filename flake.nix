{
  description = "Self-contained Neovim setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tree-sitter-flake.url = "github:tree-sitter/tree-sitter/v0.26.8";
  };

  outputs =
    {
      self,
      nixpkgs,
      tree-sitter-flake,
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
            slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp",
        }
      '';

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
            python3

            curl
            fd
            gcc
            gnumake
            gnutar
            lldb
            ripgrep
            tree-sitter-flake.packages.${system}.cli

            clang-tools
            gopls
            lua-language-server
            pyright
            ruff
            rust-analyzer
            slint-lsp
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
