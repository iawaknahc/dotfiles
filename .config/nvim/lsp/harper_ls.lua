return {
  settings = {
    ["harper-ls"] = {
      linters = {
        CapitalizePersonalPronouns = false, -- It is common to have a lone 'i' character.
        Dashes = false, -- Comments in Lua starts with two dashes.
        EllipsisLength = false, -- `..` in Lua is an operator.
        ExpandArgument = false, -- It is perfectly fine use arg and args in programming settings.
        ExpandControl = false, -- The word "CTRL" is very common in programming settings.
        ExpandMemoryShorthands = false, -- The shorthands are much more common.
        ExpandPrevious = false, -- The word "prev" is very common in programming settings.
        ExpandStandardInputAndOutput = false, -- It is perfectly fine use stdin, stdout, and stderr in programming settings.
        ExpandTimeShorthands = false, -- The shorthands are fine.
        LongSentences = false, -- A text file with a word on each line is considered long sentences, which is nonsense.
        MoreAdjective = false, -- See https://github.com/Automattic/harper/issues/2705
        OrthographicConsistency = false, -- Allow us to spell a word in lowercase.
        SentenceCapitalization = false, -- Allow us to start a sentence with a lowercase character.
        Spaces = false, -- Allow us to write something like "Read ./this/file.". The dot before the slash confuses Harper.
        SpellCheck = false, -- Harper does not even know common words like "docker". Its spellchecking gives too many false positives.
        SplitWords = false, -- Stop Harper from complaining "textDocument" should be spelled as "text document".
        UnclosedQuotes = false, -- It is common to have a lone '"' character.
        UseTitleCase = false, -- See https://github.com/Automattic/harper/issues/2640
      },
    },
  },
  -- The default list from nvim-lspconfig is incomplete.
  -- This list is up-to-date as of 2026-04-17.
  -- https://writewithharper.com/docs/integrations/language-server#Supported-Languages
  filetypes = {
    "asciidoc",
    "c",
    "clojure",
    "cmake",
    "cpp",
    "cs",
    "dart",
    "gitcommit",
    "go",
    "groovy",
    "haskell",
    "html",
    "java",
    "javascript",
    "javascriptreact",
    "kotlin",
    "lua",
    "markdown",
    "nix",
    "php",
    "python",
    "ruby",
    "rust",
    "scala",
    "sh",
    "swift",
    "text",
    "toml",
    "typescript",
    "typescriptreact",
    "typst",
    "zig",
  },
}
