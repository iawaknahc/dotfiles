{
  pkgs,
  ...
}:
let
  harperLintersToBeDisabled = [
    "CapitalizePersonalPronouns" # It is common to have a lone 'i' character.
    "Dashes" # Comments in Lua starts with two dashes.
    "DisjointPrefixes" # It suggests to join "multi-user" to become "multiuser", which seems incorrect.
    "EllipsisLength" # `..` in Lua is an operator.
    "ExpandArgument" # It is perfectly fine use arg and args in programming settings.
    "ExpandConfiguration" # The word "config" is very common in programming settings.
    "ExpandControl" # The word "CTRL" is very common in programming settings.
    "ExpandMemoryShorthands" # The shorthands are much more common.
    "ExpandPreference" # The word "pref" is very common in programming settings.
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

  harper-ls_configuration = {
    harper-ls = {
      linters = builtins.foldl' (
        attrs: linter: attrs // { ${linter} = false; }
      ) { } harperLintersToBeDisabled;
    };
  };

  harper-ls_lspconfig = {
    settings = harper-ls_configuration;
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

  harper-ls_configuration_json = pkgs.writeText "harper-ls_configuration.json" (
    builtins.toJSON harper-ls_configuration
  );
  harper-ls_lspconfig_json = pkgs.writeText "harper-ls_lspconfig.json" (
    builtins.toJSON harper-ls_lspconfig
  );
  harper-ls_lspconfig_lua = pkgs.runCommand "harper-ls_lspconfig.lua" { } ''
    printf "return " > $out
    "${pkgs.lua55Packages.cjson}"/bin/json2lua "${harper-ls_lspconfig_json}" >> $out
  '';

  # This wrapper is separated from harper-cli because we do not want to rebuild
  # harper-cli every time linters configuration is changed.
  harper-cli-lint =
    pkgs.runCommand "harper-cli-lint"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper \
          ${pkgs.harper}/bin/harper-cli \
          $out/bin/harper-cli-lint \
          --add-flag 'lint' \
          --add-flag '--ignore' \
          --add-flag '${builtins.concatStringsSep "," harperLintersToBeDisabled}'
      '';

  hunspellWithDicts = pkgs.hunspell.withDicts (dicts: [
    # The difference between dicts.en_US and dicts.en_US-large is that
    # en_US-large contains words like café.
    dicts.en_US-large
  ]);

  hunspell-en_US-large-words = pkgs.runCommand "hunspell-en_US-large-words" { } ''
    ${pkgs.hunspell.bin}/bin/unmunch \
      ${hunspellWithDicts}/share/hunspell/en_US.dic \
      ${hunspellWithDicts}/share/hunspell/en_US.aff \
      | LC_ALL=C sort -df | uniq | grep -v -E '^[[:digit:]]' > $out
  '';
in
{
  home.packages = with pkgs; [
    # After using Harper for a month,
    # the most annoying problem is https://github.com/Automattic/harper/discussions/938
    harper
    harper-cli-lint

    typos
    typos-lsp

    # Without dictionary, cspell produces many false positives.
    #nodePackages.cspell
    # Without dictionary, codebook produces many false positives.
    #codebook

    codespell

    hunspellWithDicts

    # The following tools are not very practical.
    # They consume 1GB, even without the n-gram data.
    # Even if I start a languagetool HTTP server, and ask ltex-ls-plus to connect to it.
    # ltex-ls-plus still consumes 1GB memory.
    #languagetool
    #ltex-ls-plus
  ];

  xdg.configFile."rassumfrassum/harper-ls_configuration.json".source = "${
    harper-ls_configuration_json
  }";

  xdg.configFile."nvim/lsp/harper_ls.lua".source = "${harper-ls_lspconfig_lua}";

  xdg.dataFile."dict/hunspell-en_US-large-words".source = hunspell-en_US-large-words;
}
