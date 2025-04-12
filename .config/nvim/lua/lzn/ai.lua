require("lz.n").load({
  "codecompanion.nvim",
  event = { "DeferredUIEnter" },
  before = function()
    require("lz.n").trigger_load("plenary.nvim")
    require("lz.n").trigger_load("nvim-treesitter")
  end,
  after = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "deepseek",
        },
        inline = {
          adapter = "deepseek",
        },
        cmd = {
          adapter = "deepseek",
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = {
              api_key = "cmd:op read --no-newline op://Personal/deepseek-api-key/credential",
            },
            schema = {
              model = {
                -- The default is "deepseek-reasoner" and it reasons a lot.
                default = "deepseek-chat",
              },
            },
          })
        end,
      },
    })
  end,
})
