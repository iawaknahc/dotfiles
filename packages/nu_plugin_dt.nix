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
  version = "0-unstable-2026-05-28";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_dt";
    rev = "dca9d1b9c879c3002d35f293ad086b3cfe744ee4";
    hash = "sha256-BOkUkRd0sZ+LnLCfUxFHjz1a4gim541K/Vt+IMzRNmI=";
  };
  doCheck = false;
  cargoHash = "sha256-UwP4jCUaEErCMKmINIUargotLEe3/l2CiNxI1YyoEsc=";
  meta = {
    description = "A nushell datetime plugin that uses the jiff crate ";
    homepage = "https://github.com/fdncred/nu_plugin_dt";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_dt";
  };
}
