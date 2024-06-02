return {
  {
    "williamboman/mason.nvim",
    -- We used to use cmd={"Mason"} to lazy-load, but
    -- using cmd={"Mason"} in mason and its companion plugins seem confuse lazy.nvim.
    event = {
      "VeryLazy",
    },
    main = "mason",
    config = true,
  },
}
