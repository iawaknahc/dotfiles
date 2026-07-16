{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
# This plugin is based on https://github.com/BurntSushi/jiff
# which in turn is based on EMCAScript Temporal,
# which in turn is based on ISO 8601.
#
# Therefore, ISO 8601 notation is used.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_dt";
  version = "0.2.0-unstable-2026-07-11";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_dt";
    rev = "85a04ae1048ad20166027e5e2c3e913fbf4b5ab7";
    hash = "sha256-r7Vow8Nnazj2mBX+Mz6KjCpLo4bXOajdh7Nj0WhjBfk=";
  };
  doCheck = false;
  cargoHash = "sha256-ea5hk94XHlEDITu6vuKrYZW/0OUkGOrT5mdyCCMCX9Y=";
  meta = {
    description = "A nushell datetime plugin that uses the jiff crate ";
    homepage = "https://github.com/fdncred/nu_plugin_dt";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_dt";
  };
}
