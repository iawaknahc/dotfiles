{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "hledger-lsp";
  version = "0.2.45";
  src = fetchFromGitHub {
    owner = "juev";
    repo = "hledger-lsp";
    rev = "v0.2.45";
    hash = "sha256-SyTxqtOhyYFkONM0LlBGswcqaJ3FpEacBy1ag1U/4ss=";
  };
  vendorHash = "sha256-Oo/8LCX6svcH/0vCowzOiAhlif9LJfNrU3OgNiZDupo=";
  meta = {
    description = "Language Server Protocol implementation for hledger";
    homepage = "https://github.com/juev/hledger-lsp";
    license = lib.licenses.mit;
    mainProgram = "hledger-lsp";
  };
}
