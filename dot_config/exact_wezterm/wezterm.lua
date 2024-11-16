-- I have tried wezterm on 2023-08-16
-- It is just too slow, e.g. hangs a few seconds on saving this config file, great delay when I press CTRL + or CTRL - to scale.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- font
config.font = wezterm.font 'Source Han Mono'
config.font_size = 13.0

-- color
config.color_scheme = 'Dracula (Official)'

-- key binding
-- Use CTRL+SPACE as the leader.
config.leader = {
  mods = 'CTRL',
  key = ' ',
}
config.keys = {
  {
    key = ' ',
    mods = 'LEADER|CTRL',
    action = act.SendKey { key = ' ', mods = 'CTRL' },
  },
  {
    key = '%',
    mods = 'LEADER|SHIFT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '"',
    mods = 'LEADER|SHIFT',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
}

return config
