{
  tree-sitter,
  fetchFromGitHub,
}:
tree-sitter.buildGrammar {
  language = "numbat";
  version = "0-unstable-2025-10-17";
  src = fetchFromGitHub {
    owner = "irevoire";
    repo = "tree-sitter-numbat";
    rev = "4d9ce55767f7cc2a0ef97dd070de7e4519920607";
    hash = "sha256-eNr46I8YexE5rFIDoqmlivec9H6RB3tt5/8R6age5i4=";
  };
}
