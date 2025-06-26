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

    local fixed_treewalker = {
      move_up = _G.fix_treesitter_function(treewalker.move_up),
      move_in = _G.fix_treesitter_function(treewalker.move_in),
      move_down = _G.fix_treesitter_function(treewalker.move_down),
      move_out = _G.fix_treesitter_function(treewalker.move_out),
      swap_up = _G.fix_treesitter_function(treewalker.swap_up),
      swap_right = _G.fix_treesitter_function(treewalker.swap_right),
      swap_down = _G.fix_treesitter_function(treewalker.swap_down),
      swap_left = _G.fix_treesitter_function(treewalker.swap_left),
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
