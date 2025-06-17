{ pkgs, ... }:
{
  home.packages = with pkgs; [
    harper
    typos-lsp

    # Without dictionary, cspell produces many false positives.
    # nodePackages.cspell

    codespell

    # The following tools are not very practical.
    # They consume 1GB, even without the n-gram data.
    # languagetool
    # ltex-ls-plus
  ];
}
