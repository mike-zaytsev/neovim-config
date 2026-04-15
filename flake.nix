{
  description = "Wrapped Neovim with isolated config and state";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {};

      appName = "nvim-flake";

      configHome = pkgs.runCommand "nvim-config-home" {} ''
        mkdir -p "$out/${appName}"
        cp ${./init.lua} "$out/${appName}/init.lua"
        cp -r ${./lua} "$out/${appName}/lua"

        cat > "$out/${appName}/lua/config/binary_paths.lua <<EOF
        return {
            clangd = "${pkgs.clang-tools}/bin/clangd",
            lua_ls = "${pkgs.lua-language-server}/bin/lua-language-server",
            pyright = "${pkgs.pyright}/bin/pyright}",
            gopls = "${pkgs.gopls}/bin/gopls",
        }
        EOF
      '';
    in {
      packages.${system}.default = pkgs.writeShellApplication {
        name = "nvim-flake";
        runtimeInputs = with pkgs [
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

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/nvim-flake";
      };
    };
}
