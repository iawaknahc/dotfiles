-- This is used karabiner.
hs.urlevent.bind("type", function(_eventName, params)
  local text = params["text"]
  hs.eventtap.keyStrokes(text)
end)
