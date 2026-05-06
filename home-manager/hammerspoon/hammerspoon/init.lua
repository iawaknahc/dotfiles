-- Enable IPC
-- See https://www.hammerspoon.org/docs/hs.ipc.html
--
-- The executable `hs` is at /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
-- The manpage is at /Applications/Hammerspoon.app/Contents/Resources/man/hs.man
-- See https://github.com/Hammerspoon/hammerspoon/blob/1.0.0/extensions/ipc/ipc.lua#L286
-- See hammerspoon.nix for how do we install them
require("hs.ipc")

hs.loadSpoon("EmmyLua")

-- Window management shortcuts
--- @param f hs.geometry
--- @param max_frame hs.geometry
local function left(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w / 2
  f.h = max_frame.h
end

--- @param f hs.geometry
--- @param max_frame hs.geometry
local function right(f, max_frame)
  f.x = max_frame.x + (max_frame.w / 2)
  f.y = max_frame.y
  f.w = max_frame.w / 2
  f.h = max_frame.h
end

--- @param f hs.geometry
--- @param max_frame hs.geometry
local function maximize(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w
  f.h = max_frame.h
end

--- @param f hs.geometry
--- @param max_frame hs.geometry
local function two_third(f, max_frame)
  f.x = max_frame.x
  f.y = max_frame.y
  f.w = max_frame.w * 2 / 3
  f.h = max_frame.h
end

--- @param f hs.geometry
--- @param max_frame hs.geometry
local function center(f, max_frame)
  f.x = max_frame.x + max_frame.w / 2 - (f.w / 2)
  f.y = max_frame.y + max_frame.h / 2 - (f.h / 2)
end

--- @param fn fun(f: hs.geometry, max_frame: hs.geometry)
--- @return fun()
local function make_window_shortcut(fn)
  return function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max_frame = screen:frame()
    fn(f, max_frame)
    local animation_duration = 0
    win:setFrame(f, animation_duration)
  end
end

hs.hotkey.bind({ "⌃", "⌥" }, "left", make_window_shortcut(left))
hs.hotkey.bind({ "⌃", "⌥" }, "right", make_window_shortcut(right))
hs.hotkey.bind({ "⌃", "⌥" }, "return", make_window_shortcut(maximize))
hs.hotkey.bind({ "⌃", "⌥" }, "e", make_window_shortcut(two_third))
hs.hotkey.bind({ "⌃", "⌥" }, "c", make_window_shortcut(center))

-- Show an alert when this file is (re)loaded.
hs.alert.show("Reloaded")
