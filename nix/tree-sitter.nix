{
  pkgs,
  appName,
  system,
  numtide-tree-sitter-nix,
}:
let
  cppHighlights = pkgs.concatTextFile {
    name = "tree-sitter-cpp-highlights-with-c";
    files = with pkgs.tree-sitter-grammars; [
      "${tree-sitter-c}/queries/highlights.scm"
      "${tree-sitter-cpp}/queries/highlights.scm"
    ];
  };

  treeSitterCpp = pkgs.linkFarm "tree-sitter-cpp-with-c-highlights" (
    let
      cpp = pkgs.tree-sitter-grammars.tree-sitter-cpp;
    in
    [
      {
        name = "parser";
        path = "${cpp}/parser";
      }
      {
        name = "tree-sitter.json";
        path = "${cpp}/tree-sitter.json";
      }
      {
        name = "queries/highlights.scm";
        path = cppHighlights;
      }
      {
        name = "queries/injections.scm";
        path = "${cpp}/queries/injections.scm";
      }
      {
        name = "queries/tags.scm";
        path = "${cpp}/queries/tags.scm";
      }
    ]
  );

  tsLangs = with pkgs.tree-sitter-grammars; {
    lua = tree-sitter-lua;
    c = tree-sitter-c;
    cpp = treeSitterCpp;
    cmake = tree-sitter-cmake;
    cuda = tree-sitter-cuda;
    glsl = tree-sitter-glsl;
    rust = tree-sitter-rust;
    toml = tree-sitter-toml;
    python = tree-sitter-python;
    typescript = tree-sitter-typescript;
    vim = tree-sitter-vim;
    markdown = tree-sitter-markdown;
    hyprlang = tree-sitter-hyprlang;
    yaml = tree-sitter-yaml;
    nix = numtide-tree-sitter-nix.packages.${system}.tree-sitter-nix;
    json = tree-sitter-json;
  };
in
{
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
}
