{ pkgs, config, ... }:
let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/numbat"
    else
      "${config.xdg.configHome}/numbat";
in
{
  programs.numbat.enable = true;
  programs.numbat.initFile = ./init.nbt;
  programs.numbat.settings = {
    exchange-rates = {
      # Numbat's support for currency is limited as of 2026-04-13
      # See https://github.com/sharkdp/numbat/issues/438
      # We set fetching-policy to "never" so that Numbat will not fetch and define currency units.
      fetching-policy = "never";
    };
  };
  # Build our custom prelude to exclude dimension Money and the associated units.
  # The overriding of prelude is documented at https://numbat.dev/docs/cli/customization/#startup
  home.file."${configDir}/modules/prelude.nbt".source = ./modules/prelude.nbt;
}
