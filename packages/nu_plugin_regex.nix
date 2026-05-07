{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
# This plugin is authored by a core maintainer of Nushell.
rustPlatform.buildRustPackage {
  pname = "nu_plugin_regex";
  version = "0.21.0-unstable-2026-04-20";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "b13ad14b3e5fa333a92cb486dfe5ff3c8bf963c3";
    hash = "sha256-6rBUkUuJAL+9ivHgDyfYWbyyHR9CAKjbjOoHrVBJfqg=";
  };
  doCheck = false;
  cargoHash = "sha256-V/8ZCrzq2iJOE8h1BAsA4k0L4gYu8lslrYvuGsTs+mA=";
  meta = {
    description = "Nushell plugin to search text with regular expressions.";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_regex";
  };
}
