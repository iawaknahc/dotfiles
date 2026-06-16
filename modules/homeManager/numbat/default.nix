{ pkgs, config, ... }:
let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin && !config.xdg.enable then
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

  # programs.numbat is not used because it does not support xdg.enable.

  home.sessionVariables = {
    NUMBAT_MODULES_PATH = "${config.home.homeDirectory}/${configDir}";
  };
  home.packages = with pkgs; [
    numbat
  ];
  home.file."${configDir}/config.toml".source = ./config.toml;
  home.file."${configDir}/init.nbt".source = ./init.nbt;
  # Build our custom prelude to exclude dimension Money and the associated units.
  # The overriding of prelude is documented at https://numbat.dev/docs/cli/customization/#startup
  home.file."${configDir}/modules" = {
    source = ./modules;
    recursive = true; # It has to be recursive because we will write to modules/custom/
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
