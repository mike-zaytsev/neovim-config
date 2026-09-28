{
  description = "Self-contained Neovim setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    numtide-tree-sitter-nix = {
      url = "github:numtide/tree-sitter-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      numtide-tree-sitter-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNeovim =
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          appName = "nvim-flake";

          callLocal = pkgs.newScope {
            inherit pkgs appName system numtide-tree-sitter-nix;
          };

          binPaths = callLocal ./nix/binaries.nix { };

          treeSitter = callLocal ./nix/tree-sitter.nix { };

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
              treeSitter.parsers
              treeSitter.queries
            ];
          };
        in
        pkgs.writeShellApplication {
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
          ];
          runtimeEnv = {
            NVIM_APPNAME = appName;
            XDG_CONFIG_HOME = configHome;
          };
          text = ''
            exec ${pkgs.neovim}/bin/nvim "$@"
          '';
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkNeovim system;
      });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim";
        };
      });
    };
}
