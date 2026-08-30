{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_regex";
  version = "0.24.0-unstable-2026-08-20";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "96e317bde7f7c600275e7559f0dcc2bdee97f278";
    hash = "sha256-k1cl1yWOFB7Xiurdi9m2FvFuoyP48u+l1RAw5yglXH4=";
  };
  doCheck = false;
  cargoHash = "sha256-YsYmKpqCtDtDscdgdISVwHz4sJGId9+9hXkrm95sQM0=";
  meta = {
    description = "Nushell plugin to search text with regular expressions.";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_regex";
  };
}
