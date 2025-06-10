require("lz.n").load({
  "vim-caser",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  before = function()
    vim.g.caser_no_mappings = 1
  end,
  after = function()
    local variants = {
      { "PascalCase", "MixedCase", "PascalCase" },
      { "CamelCase", "CamelCase", "camelCase" },
      { "SnakeCase", "SnakeCase", "snake_case" },
      { "ConstantCase", "UpperCase", "CONSTANT_CASE" },
      { "TitleCase", "TitleCase", "Title Case" },
      { "SentenceCase", "SentenceCase", "Sentence case" },
      { "DashCase", "KebabCase", "dash-case" },
      { "DotCase", "DotCase", "dot.case" },
    }

    for _, variant in ipairs(variants) do
      local command_name, caser_name, desc = unpack(variant)
      vim.api.nvim_create_user_command("To" .. command_name, function(args)
        -- When the user command is created with range=true,
        -- The range field is
        -- 0 when the user command is executed without a visual selection.
        -- 2 when the user command is executed with a visual selection.
        local range = args.range

        if range == 0 then
          vim.fn["caser#ActionSetup"](caser_name)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("g@", true, false, true), "n", false)
        elseif range == 2 then
          vim.fn["caser#DoAction"](caser_name, vim.fn.visualmode())
        end
      end, {
        desc = desc,
        range = true,
      })
    end
  end,
})
