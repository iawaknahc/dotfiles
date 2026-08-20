-- This plugin sets up autocmd to switch input method back to English.
-- I am aware that there is a plugin https://github.com/keaising/im-select.nvim
-- But for a simple job like this, just roll my own solution.

local function input_method_switch_to_english()
  ---@type uv.uv_process_t?
  local handle
  ---@type string|integer|nil
  local pid
  handle, pid = vim.uv.spawn("macism", {
    args = { "com.apple.keylayout.ABC" },
  }, function(_code, _signal)
    vim.schedule(function()
      if handle ~= nil and not handle:is_closing() then
        handle:close()
      end
    end)
  end)
end

local my_input_method = vim.api.nvim_create_augroup("MyInputMethod", { clear = true })
-- Switch back to English when leaving insert mode and leaving cmdline.
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = my_input_method,
  callback = function(_ev)
    input_method_switch_to_english()
  end,
})
