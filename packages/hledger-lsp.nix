{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "hledger-lsp";
  version = "0.2.43";
  src = fetchFromGitHub {
    owner = "juev";
    repo = "hledger-lsp";
    rev = "v0.2.43";
    hash = "sha256-fcgDUeWtKG/7INP2obqxXPXRXaAxIyogLd3+ov9s+bY=";
  };
  vendorHash = "sha256-Oo/8LCX6svcH/0vCowzOiAhlif9LJfNrU3OgNiZDupo=";
  meta = {
    description = "Language Server Protocol implementation for hledger";
    homepage = "https://github.com/juev/hledger-lsp";
    license = lib.licenses.mit;
    mainProgram = "hledger-lsp";
  };
}
