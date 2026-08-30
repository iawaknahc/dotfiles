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
  version = "0.2.0-unstable-2026-08-20";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_dt";
    rev = "608260b912b0f2edef27bb7a6c6aad01f0726f2e";
    hash = "sha256-HgD47y8IeAxqRWUhjr99AuzFyEZGBDeB1UKIAAk+LaM=";
  };
  doCheck = false;
  cargoHash = "sha256-CTP83EP/eiKzuH0knSgodbpHeu86IrLCb9HadFsszxA=";
  meta = {
    description = "A nushell datetime plugin that uses the jiff crate ";
    homepage = "https://github.com/fdncred/nu_plugin_dt";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_dt";
  };
}
