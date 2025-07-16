{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # After using Harper for a month,
    # the most annoying problem is https://github.com/Automattic/harper/discussions/938
    harper
    typos-lsp

    # Without dictionary, cspell produces many false positives.
    # nodePackages.cspell

    codespell

    # The following tools are not very practical.
    # They consume 1GB, even without the n-gram data.
    # Even if I start a languagetool HTTP server, and ask ltex-ls-plus to connect to it.
    # ltex-ls-plus still consumes 1GB memory.
    #languagetool
    #ltex-ls-plus
  ];
}
