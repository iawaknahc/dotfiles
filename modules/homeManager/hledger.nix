{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    hledger
    hledger-fmt
  ];
  home.sessionVariables = {
    # hledger by default passes its opinionated set of flags to `less`.
    HLEDGER_LESS = config.home.sessionVariables.LESS;
  };
  # `check payees` is turned off because I do not want to include `|` in every transaction description.
  # `check uniqueleafnames` is turned off because I do want to have non-unique leaf account names.
  xdg.configFile."hledger/hledger.conf".text = ''
    --strict

    [check]
    tags ordereddates
  '';
}
