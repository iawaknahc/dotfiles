local lh = { forward = "l", backward = "h" }
local jk = { forward = "j", backward = "k" }
local G_ = { forward = "G", backward = "G" }
local gg = { forward = "gg", backward = "gg" }
local wb = { forward = "w", backward = "b" }
local WB = { forward = "W", backward = "B" }
local e_ge = { forward = "e", backward = "ge" }
local E_gE = { forward = "E", backward = "gE" }
local parens = { forward = ")", backward = "(" }
local braces = { forward = "}", backward = "{" }
local fF = { forward = "f", backward = "F" }
local tT = { forward = "t", backward = "T" }
local squares = { forward = "]", backward = "[" }

local count_motion = {
  l = lh,
  h = lh,
  j = jk,
  k = jk,
  G = G_,
  gg = gg,
  w = wb,
  b = wb,
  W = WB,
  B = WB,
  e = e_ge,
  ge = e_ge,
  E = E_gE,
  gE = E_gE,
  [")"] = parens,
  ["("] = parens,
  ["}"] = braces,
  ["{"] = braces,
}

local count_motion_char = {
  f = fF,
  F = fF,
  t = tT,
  T = tT,
  ["]"] = squares,
  ["["] = squares,
}

---@class MotionSpec
---@field forward string
---@field backward string
---@field char string|nil
---@field count integer|nil
local motion_spec = {}

-- Store a potential g motion.
---@type string
local g_motion = ""

-- Store a pending char motion.
---@type string
local char_motion = ""

-- Store the last motion to be repeated with ; and ,
---@type MotionSpec|nil
local last_motion = nil

vim.on_key(
  ---@param _ string
  ---@param typed string
  function(_, typed)
    typed = vim.fn.keytrans(typed)

    ---@type MotionSpec|nil
    local motion = nil

    if g_motion ~= "" then
      g_motion = g_motion .. typed
      if count_motion[g_motion] ~= nil then
        motion = {
          forward = count_motion[g_motion].forward,
          backward = count_motion[g_motion].backward,
        }
      end
      g_motion = ""
    elseif char_motion ~= "" then
      motion = {
        forward = count_motion_char[char_motion].forward,
        backward = count_motion_char[char_motion].backward,
        char = typed,
      }
      char_motion = ""
    elseif count_motion_char[typed] ~= nil then
      char_motion = typed
    elseif count_motion[typed] ~= nil then
      motion = {
        forward = count_motion[typed].forward,
        backward = count_motion[typed].backward,
      }
    elseif typed == "g" then
      g_motion = "g"
    end

    if vim.v.count ~= 0 and motion ~= nil then
      motion.count = vim.v.count
    end

    if motion ~= nil then
      last_motion = motion
    end
  end
)

---@param direction "forward"|"backward"
local function repeat_last_motion(direction)
  if last_motion == nil then
    return
  end

  local command = last_motion[direction]
  if last_motion.count ~= nil then
    command = last_motion.count .. command
  end
  if last_motion.char ~= nil then
    command = command .. last_motion.char
  end

  -- This plugin does not support mapping (yet).
  local vim_cmd = [[normal! ]] .. command
  vim.cmd(vim_cmd)
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
