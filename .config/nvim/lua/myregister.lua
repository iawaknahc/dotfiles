vim.api.nvim_create_user_command("ClearAllRegisters", function()
  -- . and : are not allowed to be cleared in this way.
  local all_registers = [[abcdefghijklmnopqrstuvwxyz0123456789*+-/=_"]]
  for _, register in ipairs(vim.split(all_registers, "")) do
    vim.fn.setreg(register, "")
  end

  ---@type string|nil
  local shada_setting_register = nil
  local shada_settings = vim.split(vim.o.shada, ",")
  for _, shada_setting in ipairs(shada_settings) do
    if string.sub(shada_setting, 1, 1) == "<" then
      shada_setting_register = shada_setting
    end
  end

  if shada_setting_register ~= nil then
    vim.opt.shada:remove({ shada_setting_register })
    vim.cmd([[wshada!]])
    vim.opt.shada:append({ shada_setting_register })
  end

  if shada_setting_register ~= nil then
    vim.notify(string.format("Cleared registers %s from ShaDa", all_registers))
  else
    vim.notify(string.format("Cleared registers %s", all_registers))
  end
end, {
  nargs = 0,
})
