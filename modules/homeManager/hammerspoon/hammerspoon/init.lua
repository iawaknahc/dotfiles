-- Hammerspoon 1.0.0 embeds Lua 5.4.
print("The version of Lua running hammerspoon init.lua is " .. _VERSION)

-- Enable IPC
-- See https://www.hammerspoon.org/docs/hs.ipc.html
--
-- The executable `hs` is at /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
-- The manpage is at /Applications/Hammerspoon.app/Contents/Resources/man/hs.man
-- See https://github.com/Hammerspoon/hammerspoon/blob/1.0.0/extensions/ipc/ipc.lua#L286
-- See hammerspoon.nix for how do we install them
require("hs.ipc")

hs.loadSpoon("EmmyLua")

-- Show an alert when this file is (re)loaded.
hs.alert.show("Reloaded")
