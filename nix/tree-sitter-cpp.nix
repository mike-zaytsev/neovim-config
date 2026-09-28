pkgs:
let
  c = pkgs.tree-sitter-grammars.tree-sitter-c;
  cpp = pkgs.tree-sitter-grammars.tree-sitter-cpp;
  cppHighlights = pkgs.concatTextFile {
    name = "tree-sitter-cpp-highlights-with-c";
    files = [
      "${c}/queries/highlights.scm"
      "${cpp}/queries/highlights.scm"
    ];
  };
in
(pkgs.linkFarm "tree-sitter-cpp-with-c-highlights" [
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
])
