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
  version = "0.2.0-unstable-2026-04-20";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_dt";
    rev = "f854f2733936b649df7f489e9e3f8476ef0543ed";
    hash = "sha256-brukATxoB9SbYdLqT5wymgxsL+F1IeIBik59F0xEeUk=";
  };
  doCheck = false;
  cargoHash = "sha256-NzTPYYjwh6tqMkVK8udPs9oAOtWNQHeWGC9w6F70HDI=";
  meta = {
    description = "A nushell datetime plugin that uses the jiff crate ";
    homepage = "https://github.com/fdncred/nu_plugin_dt";
    license = lib.licenses.mit;
    mainProgram = "nu_plugin_dt";
  };
}
