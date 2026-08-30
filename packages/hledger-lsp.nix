{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "hledger-lsp";
  version = "0.2.55";
  src = fetchFromGitHub {
    owner = "juev";
    repo = "hledger-lsp";
    rev = "v0.2.55";
    hash = "sha256-BkvZKCUtI+HOSkWS5jua48LIGD9goda50F3b8HP3y7s=";
  };
  vendorHash = "sha256-imF6wCMC+5J94TQjZU0SXOwlw5SR/EB60GeYVS3O/iA=";
  meta = {
    description = "Language Server Protocol implementation for hledger";
    homepage = "https://github.com/juev/hledger-lsp";
    license = lib.licenses.mit;
    mainProgram = "hledger-lsp";
  };
}
