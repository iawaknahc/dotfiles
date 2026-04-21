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

  harperLintersToBeDisabled = [
    "CapitalizePersonalPronouns" # It is common to have a lone 'i' character.
    "Dashes" # Comments in Lua starts with two dashes.
    "EllipsisLength" # `..` in Lua is an operator.
    "ExpandArgument" # It is perfectly fine use arg and args in programming settings.
    "ExpandControl" # The word "CTRL" is very common in programming settings.
    "ExpandMemoryShorthands" # The shorthands are much more common.
    "ExpandPrevious" # The word "prev" is very common in programming settings.
    "ExpandStandardInputAndOutput" # It is perfectly fine use stdin, stdout, and stderr in programming settings.
    "ExpandTimeShorthands" # The shorthands are fine.
    "LongSentences" # A text file with a word on each line is considered long sentences, which is nonsense.
    "MoreAdjective" # See https://github.com/Automattic/harper/issues/2705
    "OrthographicConsistency" # Allow us to spell a word in lowercase.
    "SentenceCapitalization" # Allow us to start a sentence with a lowercase character.
    "Spaces" # Allow us to write something like "Read ./this/file.". The dot before the slash confuses Harper.
    "SpellCheck" # Harper does not even know common words like "docker". Its spellchecking gives too many false positives.
    "SplitWords" # Stop Harper from complaining "textDocument" should be spelled as "text document".
    "UnclosedQuotes" # It is common to have a lone '"' character.
    "UseTitleCase" # See https://github.com/Automattic/harper/issues/2640
  ];

  harper-ls_lspconfig = {
    settings = {
      harper-ls = {
        linters = builtins.foldl' (
          attrs: linter: attrs // { ${linter} = false; }
        ) { } harperLintersToBeDisabled;
      };
    };
    # The default list from nvim-lspconfig is incomplete.
    # This list is up-to-date as of 2026-04-17.
    # https://writewithharper.com/docs/integrations/language-server#Supported-Languages
    filetypes = [
      "asciidoc"
      "c"
      "clojure"
      "cmake"
      "cpp"
      "cs"
      "dart"
      "gitcommit"
      "go"
      "groovy"
      "haskell"
      "html"
      "java"
      "javascript"
      "javascriptreact"
      "kotlin"
      "lua"
      "markdown"
      "nix"
      "php"
      "python"
      "ruby"
      "rust"
      "scala"
      "sh"
      "swift"
      "text"
      "toml"
      "typescript"
      "typescriptreact"
      "typst"
      "zig"
    ];
  };

  harper-ls_lspconfig_json = pkgs.writeText "harper_ls.json" (builtins.toJSON harper-ls_lspconfig);
  harper-ls_lspconfig_lua = pkgs.runCommand "harper_ls.lua" { } ''
    printf "return " > $out
    "${pkgs.lua55Packages.cjson}"/bin/json2lua "${harper-ls_lspconfig_json}" >> $out
  '';
  # FIXME: The harper package on nixpkgs does not include harper-cli.
  # So we need to build it ourselves.
  harper-cli-wrapper = (
    pkgs.harper.overrideAttrs (prevAttrs: {
      pname = "harper-cli";
      buildAndTestSubdir = "harper-cli";
      nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [
        pkgs.makeWrapper
      ];
      nativeInstallCheckInputs = [ ]; # harper-cli reports itself as 0.1.0, which does not match the version of harper-ls.
      postInstall = (prevAttrs.postInstall or "") + ''
        makeWrapper \
          $out/bin/harper-cli \
          $out/bin/harper-cli-lint \
          --add-flag 'lint' \
          --add-flag '--ignore' \
          --add-flag '${builtins.concatStringsSep "," harperLintersToBeDisabled}'
      '';
      meta = {
        mainProgram = "harper-cli";
      };
    })
  );
in
{
  home.packages = with pkgs; [
    # After using Harper for a month,
    # the most annoying problem is https://github.com/Automattic/harper/discussions/938
    harper
    harper-cli-wrapper

    codebook
    typos-lsp

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

  xdg.configFile."nvim/lsp/harper_ls.lua".source = "${harper-ls_lspconfig_lua}";

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
