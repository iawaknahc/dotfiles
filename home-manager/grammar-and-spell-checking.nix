{ pkgs, ... }:
{
  home.packages = with pkgs; [
    harper
    typos-lsp
    # Without dictionary, cspell produces many false positives.
    # nodePackages.cspell
    codespell
  ];
}
