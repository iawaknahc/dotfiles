{ pkgs, ... }:
{
  programs.ledger.enable = true;
  home.packages = with pkgs; [ hledger ];
  xdg.configFile."hledger/hledger.conf".text = ''
    --strict
  '';
}
