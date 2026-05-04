{
  pkgs,
  config,
  lib,
  ...
}:
{
  assertions = [
    {
      assertion = pkgs.nufmt.version == "0-unstable-2026-03-26";
      message = "nufmt has a new version. Consider turning on it usage.";
    }
  ];

  home.packages = with pkgs; [
    nufmt
  ];
  programs.nushell.enable = true;
  # FIXME: nushell does not support home.sessionVariables.
  # See https://github.com/nix-community/home-manager/issues/4313
  programs.nushell.environmentVariables = config.home.sessionVariables;
  programs.nushell.configFile.source = ../.config/nushell/config.nu;
  programs.nushell.plugins = [
    # These are official plugins.
    pkgs.nushellPlugins.polars
    pkgs.nushellPlugins.formats
    pkgs.nushellPlugins.gstat
    pkgs.nushellPlugins.query

    # Plugins authored by a core maintainer of Nushell.
    #
    # This plugin is based on https://github.com/BurntSushi/jiff
    # which in turn is based on EMCAScript Temporal,
    # which in turn is based on ISO 8601.
    #
    # Therefore, ISO 8601 notation is used.
    (pkgs.rustPlatform.buildRustPackage {
      pname = "nu_plugin_dt";
      version = "nushell-0.112.2";
      src = pkgs.fetchFromGitHub {
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
    })
    (pkgs.rustPlatform.buildRustPackage {
      pname = "nu_plugin_regex";
      version = "nushell-0.112.2";
      src = pkgs.fetchFromGitHub {
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
    })
  ];
}
