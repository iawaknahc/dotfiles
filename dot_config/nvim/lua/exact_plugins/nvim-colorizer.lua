return {
  {
    "NvChad/nvim-colorizer.lua",
    enabled = true,
    event = {
      "VeryLazy",
    },
    main = "colorizer",
    opts = {
      user_default_options = {
        rgb_fn = true,
        hsl_fn = true,
        mode = "virtualtext",
        tailwind = "both",
      },
    },
  },
}
