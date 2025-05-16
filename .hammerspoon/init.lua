-- This is used karabiner.
hs.urlevent.bind("type", function(_eventName, params)
  local text = params["text"]
  hs.eventtap.keyStrokes(text)
end)

-- Window management shortcuts
local function left(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w / 2
  f.h = max_frame.h
end

local function right(f, max_frame)
  f.x = max_frame.x + (max_frame.w / 2)
  f.y = max_frame.y
  f.w = max_frame.w / 2
  f.h = max_frame.h
end

local function maximize(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w
  f.h = max_frame.h
end

local function two_third(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w * 2 / 3
  f.h = max_frame.h
end

local function center(f, max_frame)
  f.x = max_frame.x + max_frame.w / 2 - (f.w / 2)
  f.y = max_frame.y + max_frame.h / 2 - (f.h / 2)
end

local function make_window_shortcut(fn)
  return function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max_frame = screen:frame()
    fn(f, max_frame)
    win:setFrame(f)
  end
end

hs.hotkey.bind({ "⌃", "⌥" }, "left", make_window_shortcut(left))
hs.hotkey.bind({ "⌃", "⌥" }, "right", make_window_shortcut(right))
hs.hotkey.bind({ "⌃", "⌥" }, "return", make_window_shortcut(maximize))
hs.hotkey.bind({ "⌃", "⌥" }, "e", make_window_shortcut(two_third))
hs.hotkey.bind({ "⌃", "⌥" }, "c", make_window_shortcut(center))
