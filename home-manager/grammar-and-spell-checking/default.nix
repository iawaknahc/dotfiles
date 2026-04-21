{
  pkgs,
  lib,
  config,
  ...
}:
let
  codebook_home = "${config.home.homeDirectory}/.config/codebook";
  harper_ls_home =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/harper-ls"
    else
      "${config.home.homeDirectory}/.config/harper-ls";
in
{
  home.packages = with pkgs; [
    # After using Harper for a month,
    # the most annoying problem is https://github.com/Automattic/harper/discussions/938
    harper # general spellchecking
    codebook # source code spellchecking
    typos-lsp # source code spellchecking

    # Without dictionary, cspell produces many false positives.
    #nodePackages.cspell

    codespell

    # The following tools are not very practical.
    # They consume 1GB, even without the n-gram data.
    # Even if I start a languagetool HTTP server, and ask ltex-ls-plus to connect to it.
    # ltex-ls-plus still consumes 1GB memory.
    #languagetool
    #ltex-ls-plus
  ];

  # words.txt must be in lowercase because codebook normalizes the file to lowercase when it adds new words.

  home.activation.check-words-txt = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    src="${./words.txt}"
    ${pkgs.jq}/bin/jq --raw-input --null-input -r '[inputs] | sort | .[]' "$src" | ${pkgs.moreutils}/bin/sponge /tmp/words.txt
    if ! diff "$src" /tmp/words.txt; then
      printf 1>&2 "words.txt is not sorted.\n"
      exit 1
    fi
  '';

  home.activation.check-config-codebook = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    src="${codebook_home}/codebook.toml"
    if [ -f "$src" ]; then
      ${pkgs.remarshal}/bin/toml2json "$src" | ${pkgs.jq}/bin/jq '.words | sort | .[]' -r | ${pkgs.moreutils}/bin/sponge /tmp/codebook.words.txt
      difference="$(LC_ALL=C ${pkgs.coreutils}/bin/comm -23 /tmp/codebook.words.txt ${./words.txt})"
      if [ -n "$difference" ]; then
        printf 1>&2 "%s has the following additions which you must manually add to words.txt\n" "$src"
        printf 1>&2 "\n"
        printf 1>&2 "%s\n" "$difference"
        exit 1
      fi
    fi
  '';

  home.activation.write-config-codebook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${codebook_home}"
    ${pkgs.jq}/bin/jq --raw-input --null-input '[inputs] | { words: . }' ${./words.txt} | ${pkgs.remarshal}/bin/json2toml | ${pkgs.taplo}/bin/taplo fmt - | ${pkgs.moreutils}/bin/sponge "${codebook_home}/codebook.toml"
  '';

  home.activation.check-config-harper-ls = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    src="${harper_ls_home}/dictionary.txt"
    if [ -f "$src" ]; then
      ${pkgs.jq}/bin/jq --raw-input --null-input -r '[inputs] | sort | .[]' "$src" | ${pkgs.moreutils}/bin/sponge /tmp/harper-ls-dictionary.txt
      difference="$(LC_ALL=C ${pkgs.coreutils}/bin/comm -23 /tmp/harper-ls-dictionary.txt ${./words.txt})"
      if [ -n "$difference" ]; then
        printf 1>&2 "%s has the following additions which you must manually add to words.txt\n" "$src"
        printf 1>&2 "\n"
        printf 1>&2 "%s\n" "$difference"
        exit 1
      fi
    fi
  '';

  home.activation.write-config-harper-ls = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${harper_ls_home}"
    ${pkgs.moreutils}/bin/sponge <${./words.txt} "${harper_ls_home}/dictionary.txt"
  '';
}
