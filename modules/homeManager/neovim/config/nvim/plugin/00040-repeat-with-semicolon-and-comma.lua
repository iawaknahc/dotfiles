---@class MotionSpec
---@field mode string[]
---@field forward string
---@field backward string
---@field has_char_argument boolean|nil

---@class CapturedMotion
---@field motion MotionSpec
---@field char string|nil
---@field count integer|nil

---@type MotionSpec[]
local MOTION_SPECS = {
  { mode = { "n", "x" }, forward = "l", backward = "h" },
  { mode = { "n", "x" }, forward = "j", backward = "k" },
  { mode = { "n", "x" }, forward = "w", backward = "b" },
  { mode = { "n", "x" }, forward = "W", backward = "B" },
  { mode = { "n", "x" }, forward = "e", backward = "ge" },
  { mode = { "n", "x" }, forward = "E", backward = "gE" },
  { mode = { "n", "x" }, forward = ")", backward = "(" },
  { mode = { "n", "x" }, forward = "}", backward = "{" },
  { mode = { "n" }, forward = "gt", backward = "gT" },
  { mode = { "x" }, forward = "an", backward = "in" },
  { mode = { "n", "x" }, forward = "f", backward = "F", has_char_argument = true },
  { mode = { "n", "x" }, forward = "t", backward = "T", has_char_argument = true },
  { mode = { "n", "x" }, forward = "]", backward = "[", has_char_argument = true },
}

---@param motion_spec MotionSpec
---@param nvim_mode string
---@return boolean
local function match_mode(motion_spec, nvim_mode)
  nvim_mode = nvim_mode:sub(1, 1)
  for _, motion_spec_mode in ipairs(motion_spec.mode) do
    if motion_spec_mode == "n" and nvim_mode == "n" then
      return true
    elseif motion_spec_mode == "x" and (nvim_mode == "v" or nvim_mode == "V" or nvim_mode == "\22") then
      return true
    end
  end
  return false
end

---@param s string
---@param prefix string
---@return boolean
local function startswith(s, prefix)
  return s:sub(1, #prefix) == prefix
end

---@param motion_spec MotionSpec
---@param input_buffer string
---@return boolean
local function match_prefix(motion_spec, input_buffer)
  if #input_buffer > #motion_spec.forward or #input_buffer > #motion_spec.backward then
    return false
  end
  return startswith(motion_spec.forward, input_buffer) or startswith(motion_spec.backward, input_buffer)
end

---@return integer|nil
local function get_count()
  if vim.v.count ~= 0 then
    return vim.v.count
  end
  return nil
end

---@param motion_spec MotionSpec
---@param input_buffer string
---@return CapturedMotion|nil
local function capture_motion(motion_spec, input_buffer)
  if motion_spec.has_char_argument == true then
    local without_char_argument = input_buffer:sub(1, #input_buffer - 1)
    local char_argument = input_buffer:sub(#input_buffer, #input_buffer)

    if without_char_argument == motion_spec.forward or without_char_argument == motion_spec.backward then
      return {
        motion = motion_spec,
        count = get_count(),
        char = char_argument,
      }
    end
  else
    if input_buffer == motion_spec.forward or input_buffer == motion_spec.backward then
      return {
        motion = motion_spec,
        count = get_count(),
        char = nil,
      }
    end
  end

  return nil
end

vim.on_key(
  ---@param _ string
  ---@param typed string
  function(_, typed)
    typed = vim.fn.keytrans(typed)

    if vim.g.semicoloncomma_input_buffer == nil then
      vim.g.semicoloncomma_input_buffer = ""
    end
    vim.g.semicoloncomma_input_buffer = vim.g.semicoloncomma_input_buffer .. typed

    local mode = vim.api.nvim_get_mode().mode

    for _, motion_spec in ipairs(MOTION_SPECS) do
      if match_mode(motion_spec, mode) then
        local captured_motion = capture_motion(motion_spec, vim.g.semicoloncomma_input_buffer)
        if captured_motion ~= nil then
          vim.g.semicoloncomma_captured_motion = captured_motion
          goto cleanup
        end

        if match_prefix(motion_spec, vim.g.semicoloncomma_input_buffer) then
          goto wait_for_next_key
        end
      end
    end

    -- The loop falls through.
    -- This means the input keys match nothing.
    -- We forget everything and start from scratch.
    ::cleanup::
    vim.g.semicoloncomma_input_buffer = ""

    ::wait_for_next_key::
  end
)

---@param direction "forward"|"backward"
local function repeat_last_motion(direction)
  if vim.g.semicoloncomma_captured_motion == nil then
    return
  end

  local command = vim.g.semicoloncomma_captured_motion.motion[direction]
  if vim.g.semicoloncomma_captured_motion.count ~= nil then
    command = vim.g.semicoloncomma_captured_motion.count .. command
  end
  if vim.g.semicoloncomma_captured_motion.char ~= nil then
    command = command .. vim.g.semicoloncomma_captured_motion.char
  end

  -- m: remap keys so that mappings like [h (from gitsigns) work
  -- t: treat the keys as if typed by the user. We want `;` and `,` work like typing the command again.
  -- x: execute all commands.
  vim.api.nvim_feedkeys(command, "m" .. "t" .. "x", true)
end

vim.keymap.set({ "n", "x" }, ";", function()
  repeat_last_motion("forward")
end, {
  desc = "repeat last motion forward",
})
vim.keymap.set({ "n", "x" }, ",", function()
  repeat_last_motion("backward")
end, {
  desc = "repeat last motion backward",
})
