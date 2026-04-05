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
  { mode = { "n", "x" }, forward = "G", backward = "G" },
  { mode = { "n", "x" }, forward = "gg", backward = "gg" },
  { mode = { "n", "x" }, forward = "w", backward = "b" },
  { mode = { "n", "x" }, forward = "W", backward = "B" },
  { mode = { "n", "x" }, forward = "e", backward = "ge" },
  { mode = { "n", "x" }, forward = "E", backward = "gE" },
  { mode = { "n", "x" }, forward = ")", backward = "(" },
  { mode = { "n", "x" }, forward = "}", backward = "{" },
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

---@param motion_spec MotionSpec
---@param input_buffer string
---@return boolean
local function match_motion(motion_spec, input_buffer)
  return input_buffer == motion_spec.forward or input_buffer == motion_spec.backward
end

local INPUT_BUFFER = ""
local PENDING_CHAR_ARGUMENT = false

-- Store the last motion to be repeated with ; and ,
---@type CapturedMotion|nil
local captured_motion = nil

vim.on_key(
  ---@param _ string
  ---@param typed string
  function(_, typed)
    typed = vim.fn.keytrans(typed)
    local mode = vim.api.nvim_get_mode().mode

    -- If we are not pending char argument, we have to consider the typed key now.
    -- Otherwise, we look at the buffered keys to find out what the motion was.
    if not PENDING_CHAR_ARGUMENT then
      INPUT_BUFFER = INPUT_BUFFER .. typed
    end

    for _, motion_spec in ipairs(MOTION_SPECS) do
      if match_mode(motion_spec, mode) and match_motion(motion_spec, INPUT_BUFFER) then
        -- The motion does not require a char argument, we can capture it immediately.
        if motion_spec.has_char_argument == nil or motion_spec.has_char_argument == false then
          captured_motion = {
            motion = motion_spec,
          }
          if vim.v.count ~= 0 then
            captured_motion.count = vim.v.count
          end
          goto cleanup
        end

        -- Otherwise, the motion require a char argument.
        -- We were waiting already.
        if PENDING_CHAR_ARGUMENT then
          captured_motion = {
            motion = motion_spec,
            char = typed,
          }
          if vim.v.count ~= 0 then
            captured_motion.count = vim.v.count
          end
          goto cleanup
        end

        -- Otherwise, wait for the next char.
        PENDING_CHAR_ARGUMENT = true
        goto wait_for_next_key
      end
    end

    -- The loop falls through.
    -- This means the input keys match nothing.
    -- We forget everything and start from scratch.
    ::cleanup::
    INPUT_BUFFER = ""
    PENDING_CHAR_ARGUMENT = false

    ::wait_for_next_key::
  end
)

---@param direction "forward"|"backward"
local function repeat_last_motion(direction)
  if captured_motion == nil then
    return
  end

  local command = captured_motion.motion[direction]
  if captured_motion.count ~= nil then
    command = captured_motion.count .. command
  end
  if captured_motion.char ~= nil then
    command = command .. captured_motion.char
  end

  -- m: remap keys so that mappings like [h (from gitsigns) work
  -- t: treat the keys as if typed by the user. We want ; and , work like typing the command again.
  -- x: execute all commands.
  vim.api.nvim_feedkeys(command, "mtx", true)
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
