{ pkgs, config, ... }:
let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/numbat"
    else
      "${config.xdg.configHome}/numbat";
  currency_nbt = "${config.home.homeDirectory}/${configDir}/modules/custom/currency.nbt";
  genCurrencyScript = pkgs.writeShellScript "numbat-gen-currency" ''
    mkdir -p "$(dirname "${currency_nbt}")"
    ${config.mypython.package}/bin/python3 ${./gen_currency.py} > "${currency_nbt}"
  '';
in
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        # The HTTP client recommended on the documentation page of urllib.request since Python 3.4
        # See https://docs.python.org/3.4/library/urllib.request.html#module-urllib.request
        requests
      ]
    )
  ];

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
  home.file."${configDir}/modules" = {
    source = ./modules;
  };

  launchd.agents.numbat-gen-currency = {
    enable = true;
    config = {
      RunAtLoad = true;
      # Run every 06:00
      StartCalendarInterval = [
        {
          Hour = 6;
          Minute = 0;
        }
      ];
      StandardOutPath = "/dev/null";
      StandardErrorPath = "/tmp/numbat-gen-currency.log";
      ProgramArguments = [ "${genCurrencyScript}" ];
    };
  };
}
