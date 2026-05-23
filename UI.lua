local addonName, ns = ...

local UI = {}
ns.UI = UI

local frame
local statusText
local outputFrame
local bundleBox
local bundleScrollFrame
local listText
local adapterChecks = {}
local detailsAllProfilesCheck

local function raiseFrame(target, strata, level)
  if not target then
    return
  end

  target:SetFrameStrata(strata or "DIALOG")
  target:SetFrameLevel(level or 1000)
  if target.Raise then
    target:Raise()
  end
end

local function createBorder(parent, r, g, b, a)
  local top = parent:CreateTexture(nil, "OVERLAY")
  top:SetColorTexture(r, g, b, a)
  top:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -24)
  top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
  top:SetHeight(2)

  local bottom = parent:CreateTexture(nil, "OVERLAY")
  bottom:SetColorTexture(r, g, b, a)
  bottom:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 2, 2)
  bottom:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
  bottom:SetHeight(2)

  local left = parent:CreateTexture(nil, "OVERLAY")
  left:SetColorTexture(r, g, b, a)
  left:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -24)
  left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 2, 2)
  left:SetWidth(2)

  local right = parent:CreateTexture(nil, "OVERLAY")
  right:SetColorTexture(r, g, b, a)
  right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
  right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
  right:SetWidth(2)
end

local function createLabel(parent, text, x, y)
  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  label:SetPoint("TOPLEFT", x, y)
  label:SetText(text)
  return label
end

local function createButton(parent, text, x, y, width, onClick)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetPoint("TOPLEFT", x, y)
  button:SetSize(width, 24)
  button:SetText(text)
  button:SetScript("OnClick", onClick)
  return button
end

local function createCheckBox(parent, text, x, y, onClick)
  local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  check:SetPoint("TOPLEFT", x, y)
  check:SetSize(22, 22)
  check.label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  check.label:SetPoint("LEFT", check, "RIGHT", 2, 0)
  check.label:SetText(text)
  check:SetScript("OnClick", function(self)
    onClick(self:GetChecked())
  end)
  return check
end

local function setStatus(text)
  if statusText then
    statusText:SetText(text or "")
  end
end

local function refreshList()
  local entries = ns.Core:GetEntries()
  local lines = {}

  for index, entry in ipairs(entries) do
    table.insert(lines, index .. ". " .. (entry.addon or "Unknown") .. " - " .. (entry.name or "Profile"))
  end

  listText:SetText(#lines > 0 and table.concat(lines, "\n") or "No entries collected yet.")
end

local function createBundleFrame()
  if outputFrame then
    return outputFrame
  end

  outputFrame = CreateFrame("Frame", "ProfileExporterBundleFrame", UIParent, "BasicFrameTemplateWithInset")
  outputFrame:SetSize(760, 560)
  outputFrame:SetPoint("CENTER", UIParent, "CENTER", 40, -20)
  outputFrame:SetFrameStrata("DIALOG")
  outputFrame:SetFrameLevel(1000)
  outputFrame:SetToplevel(true)
  outputFrame:SetClampedToScreen(true)
  outputFrame:SetMovable(true)
  outputFrame:EnableMouse(true)
  outputFrame:RegisterForDrag("LeftButton")
  outputFrame:SetScript("OnMouseDown", function(self)
    raiseFrame(self, "DIALOG", 1000)
  end)
  outputFrame:SetScript("OnDragStart", function(self)
    raiseFrame(self, "DIALOG", 1000)
    self:StartMoving()
  end)
  outputFrame:SetScript("OnDragStop", outputFrame.StopMovingOrSizing)
  outputFrame:Hide()
  createBorder(outputFrame, 0.12, 0.58, 0.95, 0.95)

  outputFrame.title = outputFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  outputFrame.title:SetPoint("LEFT", outputFrame.TitleBg, "LEFT", 5, 0)
  outputFrame.title:SetText("Profile Exporter Bundle")
  outputFrame.title:SetTextColor(0.45, 0.85, 1)

  local hint = outputFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("LEFT", outputFrame, "TOPLEFT", 222, -54)
  hint:SetText("Select All, then Ctrl+C")
  hint:SetTextColor(0.75, 0.88, 1)

  createButton(outputFrame, "Select All", 18, -42, 100, function()
    raiseFrame(outputFrame, "DIALOG", 1000)
    bundleBox:HighlightText()
    bundleBox:SetFocus()
  end)

  createButton(outputFrame, "Close", 128, -42, 80, function()
    outputFrame:Hide()
  end)

  local bodyBackground = outputFrame:CreateTexture(nil, "BACKGROUND")
  bodyBackground:SetColorTexture(0.01, 0.015, 0.018, 0.92)
  bodyBackground:SetPoint("TOPLEFT", outputFrame, "TOPLEFT", 14, -74)
  bodyBackground:SetPoint("BOTTOMRIGHT", outputFrame, "BOTTOMRIGHT", -28, 14)

  bundleScrollFrame = CreateFrame("ScrollFrame", "ProfileExporterBundleScrollFrame", outputFrame, "UIPanelScrollFrameTemplate")
  bundleScrollFrame:SetPoint("TOPLEFT", 18, -78)
  bundleScrollFrame:SetPoint("BOTTOMRIGHT", -32, 18)
  bundleScrollFrame:SetFrameLevel(outputFrame:GetFrameLevel() + 5)

  bundleBox = CreateFrame("EditBox", nil, bundleScrollFrame)
  bundleBox:SetAutoFocus(false)
  bundleBox:EnableMouse(true)
  bundleBox:SetMultiLine(true)
  bundleBox:SetMaxLetters(0)
  bundleBox:SetFontObject(ChatFontNormal)
  bundleBox:SetWidth(690)
  bundleBox:SetHeight(430)
  bundleBox:SetTextInsets(4, 4, 4, 4)
  bundleBox:SetFrameLevel(bundleScrollFrame:GetFrameLevel() + 1)
  bundleBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)

  bundleScrollFrame:SetScrollChild(bundleBox)
  return outputFrame
end

local function showBundle(bundle)
  local bundleFrame = createBundleFrame()
  local text = bundle or ""
  local approximateLines = math.max(30, math.ceil(string.len(text) / 95))
  bundleBox:SetHeight(math.min(120000, approximateLines * 16 + 120))
  bundleBox:SetText(text)
  bundleFrame:Show()
  raiseFrame(bundleFrame, "DIALOG", 1000)
  bundleScrollFrame:SetVerticalScroll(0)
  bundleBox:HighlightText(0, 0)
  bundleBox:ClearFocus()
end

local function generateBundle()
  local bundle = ns.Core:BuildBundle()
  showBundle(bundle)
  setStatus("Bundle generated in a separate window.")
end

local function refreshAdapterControls()
  for adapterId, check in pairs(adapterChecks) do
    check:SetChecked(ns.Core:GetAdapterEnabled(adapterId))
  end

  if detailsAllProfilesCheck then
    detailsAllProfilesCheck:SetChecked(ns.Core:GetOption("detailsAllProfiles") and true or false)
  end
end

local function collectAdapters()
  local results = ns.Core:CollectAdapters()
  local lines = { "Auto collect results:" }

  for _, result in ipairs(results) do
    if result.skipped then
      table.insert(lines, "- " .. result.label .. ": skipped")
    elseif result.ok then
      table.insert(lines, "- " .. result.label .. ": " .. result.count .. " added/updated")
    else
      table.insert(lines, "- " .. result.label .. ": unavailable or failed" .. (result.error and (" (" .. result.error .. ")") or ""))
    end
  end

  refreshList()
  setStatus(table.concat(lines, "\n"))
end

local function clearEntries()
  ns.Core:ClearEntries()
  setStatus("")
  if bundleBox then
    bundleBox:SetText("")
  end
  if outputFrame then
    outputFrame:Hide()
  end
  refreshList()
end

function UI:Create()
  if frame then
    return frame
  end

  frame = CreateFrame("Frame", "ProfileExporterFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(880, 620)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("MEDIUM")
  frame:SetFrameLevel(100)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self)
    raiseFrame(self, "MEDIUM", 100)
    self:StartMoving()
  end)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()
  createBorder(frame, 0.95, 0.68, 0.12, 0.85)

  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
  frame.title:SetText("Profile Exporter")

  createButton(frame, "Auto Collect", 18, -42, 120, collectAdapters)
  createButton(frame, "Generate", 148, -42, 110, generateBundle)
  createButton(frame, "Clear", 268, -42, 90, clearEntries)

  createLabel(frame, "Enabled Adapters", 18, -84)
  local adapters = ns.GetAdapters and ns.GetAdapters() or {}
  for index, adapter in ipairs(adapters) do
    local col = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    local x = 18 + (col * 215)
    local y = -104 - (row * 24)
    adapterChecks[adapter.id] = createCheckBox(frame, adapter.label or adapter.id, x, y, function(enabled)
      ns.Core:SetAdapterEnabled(adapter.id, enabled)
    end)
  end

  local adapterRows = math.ceil(#adapters / 2)
  local detailsY = -112 - (adapterRows * 24)
  detailsAllProfilesCheck = createCheckBox(frame, "Details: all profiles", 18, detailsY, function(enabled)
    ns.Core:SetOption("detailsAllProfiles", enabled and true or false)
  end)

  createLabel(frame, "Added Entries", 18, detailsY - 38)
  listText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  listText:SetPoint("TOPLEFT", 18, detailsY - 56)
  listText:SetJustifyH("LEFT")
  listText:SetJustifyV("TOP")
  listText:SetSize(420, 330)

  createLabel(frame, "Status", 470, -42)
  statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  statusText:SetPoint("TOPLEFT", 470, -64)
  statusText:SetJustifyH("LEFT")
  statusText:SetJustifyV("TOP")
  statusText:SetSize(380, 500)
  statusText:SetText("")

  refreshAdapterControls()
  refreshList()
  return frame
end

function UI:Toggle()
  local createdFrame = self:Create()
  createdFrame:SetShown(not createdFrame:IsShown())
  if createdFrame:IsShown() then
    refreshAdapterControls()
    refreshList()
  end
end
