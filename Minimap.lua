local addonName, ns = ...

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local button
local radius = 80
local iconPath = "Interface\\AddOns\\ProfileExporter\\Media\\PEIcon.tga"
local atan2 = math.atan2 or function(y, x)
  if x == 0 then
    return y >= 0 and math.pi / 2 or -math.pi / 2
  end

  local angle = math.atan(y / x)
  if x < 0 then
    angle = angle + math.pi
  end
  return angle
end

local function updatePosition(angle)
  if not button or not Minimap then
    return
  end

  local savedAngle = ns.Core and ns.Core:GetMinimapAngle() or 225
  local radians = math.rad(angle or savedAngle)
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radius, math.sin(radians) * radius)
end

local function updateAngleFromCursor()
  if not Minimap then
    return
  end

  local scale = Minimap:GetEffectiveScale()
  local cx, cy = Minimap:GetCenter()
  local x, y = GetCursorPosition()
  x = x / scale
  y = y / scale

  local angle = math.deg(atan2(y - cy, x - cx))
  if ns.Core then
    ns.Core:SetMinimapAngle(angle)
  end
  updatePosition(angle)
end

function MinimapButton:Create()
  if button or not Minimap then
    return button
  end

  button = CreateFrame("Button", "ProfileExporterMinimapButton", Minimap)
  button:SetSize(34, 34)
  button:SetFrameStrata("HIGH")
  button:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 8)
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp")
  button:RegisterForDrag("LeftButton")

  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetTexture(iconPath)
  icon:SetSize(30, 30)
  icon:SetPoint("CENTER")

  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  button:SetScript("OnClick", function()
    if ns.UI then
      ns.UI:Toggle()
    end
  end)

  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", updateAngleFromCursor)
  end)

  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    updateAngleFromCursor()
  end)

  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Profile Exporter")
    GameTooltip:AddLine("Left-click: open exporter", 1, 1, 1)
    GameTooltip:AddLine("Drag: move icon", 1, 1, 1)
    GameTooltip:Show()
  end)

  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  updatePosition()
  button:Show()
  return button
end

local function tryCreate()
  if MinimapButton:Create() then
    updatePosition()
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(_, event, loadedAddon)
  if event == "ADDON_LOADED" and loadedAddon ~= addonName then
    return
  end

  tryCreate()
  if C_Timer and C_Timer.After then
    C_Timer.After(1, tryCreate)
  end
end)
