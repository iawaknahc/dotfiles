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
  version = "0.2.0-unstable-2026-10-06";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_dt";
    rev = "6b5ecf6f728c0fd44c27079faca4e644be4a89f1";
    hash = "sha256-Ewhh6BBWgPLjjQHAUVjhCWyBNH8+Uf5oGgZrwzf7ioE=";
  };
  doCheck = false;
  cargoHash = "sha256-s1wFR3EM6PBhiVrV5QdrUV54x9S7RDM97DfqH3joo5k=";
  meta = {
    description = "A nushell datetime plugin that uses the jiff crate ";
    homepage = "https://github.com/fdncred/nu_plugin_dt";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_dt";
  };
}
