local addonName, ns = ...

local function getActiveLayout()
  if not _G.C_EditMode then
    return nil
  end

  if C_EditMode.GetActiveLayoutInfo then
    local ok, layout = pcall(C_EditMode.GetActiveLayoutInfo)
    if ok and layout then
      return layout
    end
  end

  if not C_EditMode.GetLayouts then
    return nil
  end

  local ok, layouts = pcall(C_EditMode.GetLayouts)
  if not ok or type(layouts) ~= "table" then
    return nil
  end

  local active = layouts.activeLayout or layouts.activeLayoutIndex
  local list = layouts.layouts or layouts

  if active and type(list) == "table" then
    for _, layout in ipairs(list) do
      if layout.layoutIndex == active or layout.layoutName == active then
        return layout
      end
    end
  end

  for _, layout in ipairs(list) do
    if layout.active or layout.isActive then
      return layout
    end
  end

  return list[1]
end

ns.RegisterAdapter({
  id = "editmode",
  label = "Edit Mode",

  isAvailable = function()
    return _G.C_EditMode and C_EditMode.ConvertLayoutInfoToString ~= nil
  end,

  export = function()
    local layout = getActiveLayout()
    if not layout then
      error("active Edit Mode layout was not found")
    end

    local ok, body = pcall(C_EditMode.ConvertLayoutInfoToString, layout)
    if not ok or not body or body == "" then
      error("Edit Mode layout export returned empty text")
    end

    local name = layout.layoutName or layout.name or "Current Layout"
    return {
      id = "edit-mode-" .. tostring(name):lower():gsub("[^%w_-]+", "-"),
      addon = "Edit Mode",
      name = name,
      group = "Edit Mode",
      format = "editmode",
      tags = "edit-mode",
      order = "80",
      instructions = "WoW 편집 모드 가져오기 창에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
