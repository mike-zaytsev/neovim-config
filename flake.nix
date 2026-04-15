{
  description = "Wrapped Neovim with isolated config and state";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      appName = "nvim-flake";

      binPaths = pkgs.writeTextDir "${appName}/lua/config/nix_paths.lua" ''
        return {
            clangd = "${pkgs.clang-tools}/bin/clangd",
            lua_ls = "${pkgs.lua-language-server}/bin/lua-language-server",
            pyright = "${pkgs.pyright}/bin/pyright-langserver",
            ruff = "${pkgs.ruff}/bin/ruff",
            slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp",
            gopls = "${pkgs.gopls}/bin/gopls",
        }
      '';

      configTree = pkgs.runCommand "nvim-config-tree" {} ''
        mkdir -p "$out/${appName}"
        cp ${./init.lua} "$out/${appName}/init.lua"
        cp -r ${./lua} "$out/${appName}/lua"
      '';

      configHome = pkgs.symlinkJoin {
        name = "nvim-config-home";
        paths = [ configTree binPaths ];
      };
    in {
      packages.${system} = {
        default = pkgs.writeShellApplication {
          name = "nvim-flake";
          runtimeInputs = with pkgs; [
            neovim
            clang-tools
            lua-language-server
            pyright
            gopls
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
        program = "${self.packages.${system}.default}/bin/nvim-flake";
      };
    };
}
