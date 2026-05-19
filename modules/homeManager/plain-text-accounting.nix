{ pkgs, config, ... }:
{
  programs.ledger.enable = true;
  home.packages = with pkgs; [ hledger ];
  home.sessionVariables = {
    # hledger by default passes its opinionated set of flags to `less`.
    HLEDGER_LESS = config.home.sessionVariables.LESS;
  };
  xdg.configFile."hledger/hledger.conf".text = ''
    --strict
  '';
}
