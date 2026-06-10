{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_regex";
  version = "0.22.0-unstable-2026-05-28";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "83f74974de8a3588f789d82ff14e05b221d64e61";
    hash = "sha256-jnVDteyV98uw/B6fwdBgAcKLdqJKhmS/IvfPzc6RiCE=";
  };
  doCheck = false;
  cargoHash = "sha256-Y5DxLHKgT1M8dYOTRtYjU07XF36zN0S6STMZUGCpFc4=";
  meta = {
    description = "Nushell plugin to search text with regular expressions.";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_regex";
  };
}
