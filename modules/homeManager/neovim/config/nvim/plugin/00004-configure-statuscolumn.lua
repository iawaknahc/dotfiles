---@alias StatusColumnSegment StatusColumnSegmentNumber | StatusColumnSegmentFold | StatusColumnSegmentLegacySign | StatusColumnSegmentExtmark | StatusColumnSegmentFunc | StatusColumnSegmentSpace

---@alias StatusColumnClickHandler fun(minwid: integer, num_clicks: integer, btn: "l" | "r" | "m" | string, modifiers: string): void

---@class StatusColumnSegmentNumber
---@field specifier "%l"
---@field click_handler StatusColumnClickHandler

---@class StatusColumnSegmentFold
---@field specifier "%C"
---@field click_handler StatusColumnClickHandler

---@class StatusColumnSegmentLegacySign
---@field name_matcher fun(name: string): boolean
---@field click_handler StatusColumnClickHandler
---@field check_virtnum fun(virtnum: integer): boolean
---@field fallback string

---@class StatusColumnSegmentExtmark
---@field group_matcher fun(group: string): boolean
---@field click_handler StatusColumnClickHandler
---@field check_virtnum fun(virtnum: integer): boolean
---@field fallback string

---@class StatusColumnSegmentFunc
---@field click_handler StatusColumnClickHandler
---@field func fun(): string

---@class StatusColumnSegmentSpace
---@field space string

local global_function_count = 0

---@return string
local function make_global_function_name()
  local count = global_function_count
  global_function_count = global_function_count + 1
  return string.format("STATUSCOLUMN_CLICK_%d", count)
end

---@param segment StatusColumnSegmentNumber
---@return string
local function StatusColumnSegmentNumber(segment)
  local click_handler_name = make_global_function_name()
  _G[click_handler_name] = segment.click_handler

  local func_name = make_global_function_name()
  _G[func_name] = function()
    -- When vim.v.virtnum != 0, %4l collapses to empty string.
    -- So we replace it with static number of spaces.
    -- This ensures the layout is in wrapped lines.
    if vim.v.virtnum ~= 0 then
      return string.rep(" ", vim.o.numberwidth + 1)
    end
    return "%" .. tostring(vim.o.numberwidth) .. "l"
  end

  return "%@v:lua." .. click_handler_name .. "@%{%v:lua." .. func_name .. "()%}%T"
end

---@param segment StatusColumnSegmentFold
---@return string
local function StatusColumnSegmentFold(segment)
  local click_handler_name = make_global_function_name()
  _G[click_handler_name] = segment.click_handler

  local func_name = make_global_function_name()
  _G[func_name] = function()
    return "%C"
  end

  return "%@v:lua." .. click_handler_name .. "@%{%v:lua." .. func_name .. "()%}%T"
end

---@param segment StatusColumnSegmentFunc
---@return string
local function StatusColumnSegmentFunc(segment)
  local click_handler_name = make_global_function_name()
  _G[click_handler_name] = segment.click_handler
  local func_name = make_global_function_name()
  _G[func_name] = segment.func
  return "%@v:lua." .. click_handler_name .. "@%{%v:lua." .. func_name .. "()%}%T"
end

---@param segment StatusColumnSegmentLegacySign
---@return string
local function StatusColumnSegmentLegacySign(segment)
  local click_handler_name = make_global_function_name()
  _G[click_handler_name] = segment.click_handler

  local func_name = make_global_function_name()
  ---@return string
  _G[func_name] = function()
    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local fallback = segment.fallback
    local lnum_0 = vim.v.lnum - 1
    local all_namespaces = -1

    ---@type string[]
    local out = {}

    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, all_namespaces, { lnum_0, 0 }, { lnum_0, 0 }, {
      details = true,
      type = "sign",
    })
    for _, extmark in ipairs(extmarks) do
      local details = extmark[4]
      if details ~= nil then
        if details.sign_name ~= nil then
          if segment.name_matcher(details.sign_name) then
            local content = "%#" .. details.sign_hl_group .. "#" .. details.sign_text .. "%*"
            table.insert(out, content)
          end
        end
      end
    end

    if #out == 0 then
      return fallback
    end
    return table.concat(out, "")
  end

  return "%@v:lua." .. click_handler_name .. "@%{%v:lua." .. func_name .. "()%}%T"
end

---@param segment StatusColumnSegmentExtmark
---@return string
local function StatusColumnSegmentExtmark(segment)
  local click_handler_name = make_global_function_name()
  _G[click_handler_name] = segment.click_handler

  local func_name = make_global_function_name()
  ---@return string
  _G[func_name] = function()
    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local fallback = segment.fallback
    local lnum_0 = vim.v.lnum - 1
    local all_namespaces = -1

    ---@type string[]
    local out = {}

    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, all_namespaces, { lnum_0, 0 }, { lnum_0, 0 }, {
      details = true,
      type = "sign",
    })
    for _, extmark in ipairs(extmarks) do
      local details = extmark[4]
      if details ~= nil then
        if details.sign_hl_group ~= nil and details.sign_text ~= nil and details.sign_text ~= "" then
          if segment.group_matcher(details.sign_hl_group) then
            local content = "%#" .. details.sign_hl_group .. "#" .. details.sign_text .. "%*"
            table.insert(out, content)
          end
        end
      end
    end

    if #out == 0 then
      return fallback
    end

    -- For unknown reason, gitsigns will place many duplicate signs if we press and hold ENTER to create many newlines,
    -- or if we press and hold BACKSPACE to delete many newlines.
    -- So we just take the first sign to render.
    return out[1] --[[@as string]]
  end

  return "%@v:lua." .. click_handler_name .. "@%{%v:lua." .. func_name .. "()%}%T"
end

---@param segments StatusColumnSegment[]
---@return string
local function build_segments_into_statuscolumn(segments)
  ---@type string[]
  local out = {}
  for _, segment in ipairs(segments) do
    if segment.space ~= nil then
      local s = segment --[[@as StatusColumnSegmentSpace]]
      table.insert(out, s.space)
    elseif segment.specifier == "%l" then
      local s = segment --[[@as StatusColumnSegmentNumber]]
      table.insert(out, StatusColumnSegmentNumber(s))
    elseif segment.specifier == "%C" then
      local s = segment --[[@as StatusColumnSegmentFold]]
      table.insert(out, StatusColumnSegmentFold(s))
    elseif segment.name_matcher ~= nil then
      local s = segment --[[@as StatusColumnSegmentLegacySign]]
      table.insert(out, StatusColumnSegmentLegacySign(s))
    elseif segment.group_matcher ~= nil then
      local s = segment --[[@as StatusColumnSegmentExtmark]]
      table.insert(out, StatusColumnSegmentExtmark(s))
    elseif segment.func ~= nil then
      local s = segment --[[@as StatusColumnSegmentFunc]]
      table.insert(out, StatusColumnSegmentFunc(s))
    else
      error("unknown segment")
    end
  end
  return table.concat(out, "")
end

local function STATUSCOLUMN_DIAGNOSTIC()
  local EMPTY = " "

  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)

  if vim.v.virtnum < 0 then
    -- Virtual lines do not have diagnostics.
    return EMPTY
  elseif vim.v.virtnum > 0 then
    -- Wrapped lines do not have diagnostics.
    return EMPTY
  end
  -- If we reach here, `vim.v.virtnum` is 0.

  -- Get the diagnostics on this line and sort them in decreasing severity order.
  local items = vim.diagnostic.get(bufnr, {
    lnum = vim.v.lnum - 1, -- vim.v.lnum is 1-indexing.
  })
  table.sort(items, function(a, b)
    return a.severity < b.severity
  end)

  local first = items[1]
  if first == nil then
    return EMPTY
  end

  if first.severity == vim.diagnostic.severity.ERROR then
    return "%#DiagnosticSignError#E%*"
  elseif first.severity == vim.diagnostic.severity.WARN then
    return "%#DiagnosticSignWarn#W%*"
  elseif first.severity == vim.diagnostic.severity.INFO then
    return "%#DiagnosticSignInfo#I%*"
  elseif first.severity == vim.diagnostic.severity.HINT then
    return "%#DiagnosticSignHint#H%*"
  end

  return EMPTY
end

---@param _minwid integer
---@param _num_clicks integer
---@param _btn "l" | "r" | "m" | string
---@param _modifiers string
local function STATUSCOLUMN_CLICK_FOLD(_minwid, _num_clicks, _btn, _modifiers)
  local mousepos = vim.fn.getmousepos()

  if vim.fn.foldlevel(mousepos.line) == 0 then
    return
  end

  local result = vim.fn.foldclosed(mousepos.line)
  if result ~= -1 then
    -- The closed fold is clicked. Open it.
    if result == mousepos.line then
      vim.cmd(tostring(result) .. [[foldopen!]])
    end
    return
  end

  local view = vim.fn.winsaveview()
  vim.fn.cursor(mousepos.line, 1)
  vim.cmd([[normal! [z]])
  local start = vim.fn.line(".")
  vim.fn.winrestview(view)

  -- The opened fold is clicked. Close it.
  if start == mousepos.line then
    vim.cmd(tostring(start) .. [[foldclose!]])
  end
end

---@param _minwid integer
---@param _num_clicks integer
---@param _btn "l" | "r" | "m" | string
---@param _modifiers string
local function STATUSCOLUMN_CLICK_DAP(_minwid, _num_clicks, _btn, _modifiers)
  require("dap").toggle_breakpoint()
end

---@param _minwid integer
---@param _num_clicks integer
---@param _btn "l" | "r" | "m" | string
---@param _modifiers string
local function STATUSCOLUMN_CLICK_DIAGNOSTIC(_minwid, _num_clicks, _btn, _modifiers)
  local mousepos = vim.fn.getmousepos()
  local winid = mousepos.winid
  local bufnr = vim.api.nvim_win_get_buf(winid)
  vim.diagnostic.open_float({
    bufnr = bufnr,
    scope = "line",
    pos = mousepos.line - 1,
  })
end

---@param _minwid integer
---@param _num_clicks integer
---@param _btn "l" | "r" | "m" | string
---@param _modifiers string
local function STATUSCOLUMN_CLICK_NUMBER(_minwid, _num_clicks, _btn, _modifiers)
  require("dap").toggle_breakpoint()
end

---@param _minwid integer
---@param _num_clicks integer
---@param _btn "l" | "r" | "m" | string
---@param _modifiers string
local function STATUSCOLUMN_CLICK_GITSIGNS(_minwid, _num_clicks, _btn, _modifiers)
  require("gitsigns").preview_hunk()
end

vim.o.foldcolumn = "1"
vim.o.signcolumn = "no"
vim.o.numberwidth = 4
vim.o.number = true
vim.o.statuscolumn = build_segments_into_statuscolumn({
  {
    specifier = "%C",
    click_handler = STATUSCOLUMN_CLICK_FOLD,
  },
  {
    name_matcher = function(name)
      return string.match(name, "Dap.*") ~= nil
    end,
    click_handler = STATUSCOLUMN_CLICK_DAP,
    check_virtnum = function(virtnum)
      return virtnum == 0
    end,
    -- By observation, the sign is "B ", so two characters.
    fallback = "  ",
  },
  {
    -- The default behavior of diagnostic signs handler is to render all signs.
    -- But it is much better to render only the most severe sign.
    -- Instead of overriding vim.diagnostic.handlers.sign, we use the low-level API of vim.diagnostic to draw directly.
    func = STATUSCOLUMN_DIAGNOSTIC,
    click_handler = STATUSCOLUMN_CLICK_DIAGNOSTIC,
  },
  {
    specifier = "%l",
    click_handler = STATUSCOLUMN_CLICK_NUMBER,
  },
  {
    group_matcher = function(group)
      return string.match(group, "GitSigns.*") ~= nil
    end,
    click_handler = STATUSCOLUMN_CLICK_GITSIGNS,
    check_virtnum = function(virtnum)
      -- Render the git signs for actual buffer lines and wrapped lines.
      -- Render wrapped lines so that the hunk will not appear as separate.
      return virtnum >= 0
    end,
    -- By observation, the sign is "┃ ", so two characters.
    -- The fallback is the same as added lines.
    -- The highlight group LineNr is applied to it so that it will not be highlighted by the option 'cursorline' and 'cursorlineopt=number'.
    fallback = "%#LineNr#┃ %*",
  },
})
