{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_regex";
  version = "0.25.0-unstable-2026-10-06";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "fa8f7434d5bfbaa2991a7ae1737dd691ce073462";
    hash = "sha256-rmaENEoW+YeQv9poJr4BUDiFTt/KHfMxkuA7MmQmuns=";
  };
  doCheck = false;
  cargoHash = "sha256-cikxvOJU3RXabN0jDIBU4rEshQT9Njv7q4iJBjsFm2Y=";
  meta = {
    description = "Nushell plugin to search text with regular expressions.";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_regex";
  };
}
