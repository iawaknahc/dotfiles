local cjson = require("cjson")
local sbar = require("sketchybar")

local Base = 0xff1e1e2e
local Surface_0 = 0xff313244
local Overlay_1 = 0xff7f849c
local Text = 0xffcdd6f4

local function exec_json(command)
  local handle = io.popen(command)
  if handle == nil then
    return nil
  end
  local stdout = handle:read("*all")
  handle:close()
  return cjson.decode(stdout)
end

local function exec(command)
  local handle = io.popen(command)
  if handle == nil then
    return nil
  end
  local stdout = handle:read("*all")
  handle:close()
  return stdout
end

sbar.bar({
  position = "bottom",
  height = 60,
  margin = 16,
  y_offset = 8,
  corner_radius = 12,
  padding_left = 12,
  padding_right = 12,
  display = "main",
  color = Base,
})

sbar.add("event", "aerospace_workspace_change")

local initial_focused_workspace_id =
  tostring(exec_json(aerospace .. [[ list-workspaces --json --focused]])[1].workspace)

local workspaces = exec_json(aerospace .. [[ list-workspaces --json --monitor focused]])

for _, workspace in ipairs(workspaces) do
  local workspace_id = tostring(workspace.workspace)

  local styles = {
    label_color = {
      focused = Text,
      not_focused = Overlay_1,
    },
    font_style = {
      focused = "Bold",
      not_focused = "Regular",
    },
  }

  local item = sbar.add("item", "workspace:" .. workspace_id, "left")

  local function render_focus(focused_workspace_id)
    local label_color = styles.label_color.not_focused
    local font_style = styles.font_style.not_focused
    if focused_workspace_id == workspace_id then
      label_color = styles.label_color.focused
      font_style = styles.font_style.focused
    end

    item:set({
      label = {
        color = label_color,
        font = {
          style = font_style,
        },
      },
    })
  end

  local function render_label()
    local windows = exec_json(aerospace .. [[ list-windows --json --workspace ]] .. workspace_id)
    local app_names = {}
    for _, window in ipairs(windows) do
      table.insert(app_names, window["app-name"])
    end

    local drawing = #app_names > 0
    local label = workspace_id .. ": " .. table.concat(app_names, ", ")
    item:set({
      drawing = drawing,
      label = {
        string = label,
      },
    })
  end

  item:set({
    background = {
      color = Surface_0,
      height = 44,
      corner_radius = 12,
      padding_right = 12,
    },
    label = {
      padding_left = 16,
      padding_right = 16,
      font = {
        family = "JetBrainsMonoNL Nerd Font Mono",
        size = 16,
      },
      align = "center",
    },
  })

  render_focus(initial_focused_workspace_id)
  render_label()

  item:subscribe("aerospace_workspace_change", function(env)
    -- {
    --   AEROSPACE_FOCUSED_WORKSPACE = "1",
    --   AEROSPACE_PREV_WORKSPACE = "2",
    --   NAME = "workspace:2",
    --   SENDER = "aerospace_workspace_change"
    -- }
    if workspace_id == env.AEROSPACE_FOCUSED_WORKSPACE or workspace_id == env.AEROSPACE_PREV_WORKSPACE then
      render_focus(env.AEROSPACE_FOCUSED_WORKSPACE)
      render_label()
    end
  end)

  item:subscribe("mouse.clicked", function(env)
    -- {
    --   BUTTON = "left",
    --   INFO = {
    --     button = "left",
    --     button_code = 0,
    --     modfier_code = 0,
    --     modifier = "none"
    --   },
    --   MODIFIER = "none",
    --   NAME = "workspace:2",
    --   SENDER = "mouse.clicked"
    -- }
    exec(aerospace .. [[ workspace ]] .. workspace_id)
  end)
end

sbar.event_loop()
