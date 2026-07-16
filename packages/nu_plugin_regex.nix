{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_regex";
  version = "0.23.0-unstable-2026-07-11";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "8c7864a8050d75869af8ad5e6a961da23eb71ae9";
    hash = "sha256-0TZ1Wy5ShwRTTeqM4B3wfwiwo6/iZe4ImV3rjCdwSmM=";
  };
  doCheck = false;
  cargoHash = "sha256-VOehMz7XxNyWsfp5SVcBKZV53Y+ql88VH/lWaXJu/VQ=";
  meta = {
    description = "Nushell plugin to search text with regular expressions.";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_regex";
  };
}
