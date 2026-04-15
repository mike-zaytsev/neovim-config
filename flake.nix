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

      # Build a fake XDG config home whose subdir matches NVIM_APPNAME.
      configHome = pkgs.runCommandNoCC "nvim-config-home" {} ''
        mkdir -p "$out/${appName}"
        cp ${./init.lua} "$out/${appName}/init.lua"
        cp -r ${./lua} "$out/${appName}/lua"
      '';
    in {
      packages.${system}.default = pkgs.writeShellApplication {
        name = "nvim-flake";
        runtimeInputs = [ pkgs.neovim ];
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
