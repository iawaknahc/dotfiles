{ ... }:
{
  programs.numbat.enable = true;
  programs.numbat.initFile = ./init.nbt;
  programs.numbat.settings = {
    exchange-rates = {
      # numbat support of currency is limited as of 2026-04-13
      # See https://github.com/sharkdp/numbat/issues/438
      fetching-policy = "never";
    };
  };
}
