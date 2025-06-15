local function get_firefox()
  local firefox = hs.application.find("Firefox")
  if firefox == nil then
    return nil
  end

  local focusedWindow = firefox:focusedWindow()
  if focusedWindow == nil then
    return nil
  end

  local axwin = hs.axuielement.windowElement(focusedWindow)
  if axwin == nil then
    return nil
  end

  local urlbar = axwin:elementSearch(
    nil,
    hs.axuielement.searchCriteriaFunction({
      attribute = "AXDOMIdentifier",
      value = "urlbar",
    }),
    {
      count = 1,
      depth = 5,
      noCallback = true,
    }
  )[1]
  if urlbar == nil then
    return nil
  end

  local combobox = urlbar:elementSearch(
    nil,
    hs.axuielement.searchCriteriaFunction({
      attribute = "AXRole",
      value = "AXComboBox",
    }),
    {
      count = 1,
      depth = 2,
      noCallback = true,
    }
  )[1]
  if combobox == nil then
    return nil
  end

  local url = combobox.AXValue
  if type(url) ~= "string" then
    return nil
  end

  return url
end

local function get_chrome()
  local chrome = hs.application.find("Chrome")
  if chrome == nil then
    return nil
  end

  local focusedWindow = chrome:focusedWindow()
  if focusedWindow == nil then
    return nil
  end

  local axwin = hs.axuielement.windowElement(focusedWindow)
  if axwin == nil then
    return nil
  end

  local url = axwin.AXDocument
  if type(url) == "string" then
    return url
  end

  return nil
end

local function get_safari()
  local safari = hs.application.find("Safari")
  if safari == nil then
    return nil
  end

  local focusedWindow = safari:focusedWindow()
  if focusedWindow == nil then
    return nil
  end

  local axwin = hs.axuielement.windowElement(focusedWindow)
  if axwin == nil then
    return nil
  end

  local urlTextField = axwin:elementSearch(
    nil,
    hs.axuielement.searchCriteriaFunction({
      attribute = "AXIdentifier",
      value = "WEB_BROWSER_ADDRESS_AND_SEARCH_FIELD",
    }),
    {
      count = 1,
      depth = 5,
      noCallback = true,
    }
  )[1]
  if urlTextField == nil then
    return nil
  end

  local url = urlTextField.AXValue
  if type(url) ~= "string" then
    return nil
  end

  return url
end

local output = {
  browsers = {
    { name = "Firefox", url = get_firefox() },
    { name = "Chrome", url = get_chrome() },
    { name = "Safari", url = get_safari() },
  },
}
local pretty = true

print(hs.json.encode(output, pretty))
