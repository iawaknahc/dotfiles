require("lz.n").load({
  "treewalker.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local treewalker = require("treewalker")
    treewalker.setup({
      highlight_duration = 250,
      highlight_group = "IncSearch",
    })

    -- As of 2025-06-21, https://github.com/aaronik/treewalker.nvim/commits/cfae49dedd041dbe867c2b3d0b081fc381a735e9/
    -- This plugin assumes that parser:parse() has been called once.
    -- This may not be true if I do not have other plugin doing that.
    -- So we have quick workaround by calling parser:parse(true) before letting treewalker to do the actual work.
    local function fix(fn)
      return function(...)
        local ok, parser = pcall(vim.treesitter.get_parser)
        if ok and parser ~= nil then
          parser:parse(true)
        end
        fn(...)
      end
    end

    local fixed_treewalker = {
      move_up = fix(treewalker.move_up),
      move_in = fix(treewalker.move_in),
      move_down = fix(treewalker.move_down),
      move_out = fix(treewalker.move_out),
      swap_up = fix(treewalker.swap_up),
      swap_right = fix(treewalker.swap_right),
      swap_down = fix(treewalker.swap_down),
      swap_left = fix(treewalker.swap_left),
    }

    vim.keymap.set({ "n", "x" }, "<M-k>", function()
      fixed_treewalker.move_up()
    end, { desc = "Treewalker: Move up" })
    vim.keymap.set({ "n", "x" }, "<M-l>", function()
      fixed_treewalker.move_in()
    end, { desc = "Treewalker: Move in" })
    vim.keymap.set({ "n", "x" }, "<M-j>", function()
      fixed_treewalker.move_down()
    end, { desc = "Treewalker: Move down" })
    vim.keymap.set({ "n", "x" }, "<M-h>", function()
      fixed_treewalker.move_out()
    end, { desc = "Treewalker: Move out" })

    -- This is a very simplified version of dot-repeat.
    -- See https://www.vikasraj.dev/blog/vim-dot-repeat
    -- See https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
    --
    -- We could have use nvim_feedkeys(, "nt") and use @: to repeat too,
    -- but hitting @: to repeat is not as ergonomic as hitting .
    -- We are aware that a operatorfunc should support both normal mode and visual mode, v:count, [ ] < >, etc.
    -- But ergonomics is what matters here.
    --- @param fn_name string
    local function make_repeatable(fn_name)
      local global_fn_name = "operatorfunc_treewalker_" .. fn_name
      _G[global_fn_name] = function(type_)
        if type_ == nil then
          vim.o.operatorfunc = "v:lua." .. global_fn_name
          -- l is just a placeholder motion to trigger g@ to execute once.
          return "g@l"
        end
        fixed_treewalker[fn_name]()
      end
      return _G[global_fn_name]
    end

    vim.keymap.set("n", "<M-S-k>", make_repeatable("swap_up"), { expr = true, desc = "Treewalker: Swap up" })
    vim.keymap.set("n", "<M-S-l>", make_repeatable("swap_right"), { expr = true, desc = "Treewalker: Swap right" })
    vim.keymap.set("n", "<M-S-j>", make_repeatable("swap_down"), { expr = true, desc = "Treewalker: Swap down" })
    vim.keymap.set("n", "<M-S-h>", make_repeatable("swap_left"), { expr = true, desc = "Treewalker: Swap left" })
  end,
})
