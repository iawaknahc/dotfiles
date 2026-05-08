return {
  settings = {
    python = {
      pyrefly = {
        -- By default, Pyrefly does not emit diagnostics for files not explicitly listed in the configuration file.
        -- By setting this flag, we can have Pyrefly work with its own default configuration file.
        -- See https://pyrefly.org/en/docs/IDE/#pythonpyreflydisplaytypeerrors
        displayTypeErrors = "force-on",
      },
    },
  },
}
