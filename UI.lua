local addonName, ns = ...

local UI = {}
ns.UI = UI

local frame
local fields = {}
local outputBox
local listText

local function createLabel(parent, text, x, y)
  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  label:SetPoint("TOPLEFT", x, y)
  label:SetText(text)
  return label
end

local function createEditBox(parent, name, x, y, width, height, multiline)
  createLabel(parent, name, x, y)
  local box = CreateFrame("EditBox", nil, parent, multiline and "InputBoxTemplate" or "InputBoxTemplate")
  box:SetPoint("TOPLEFT", x, y - 16)
  box:SetSize(width, height)
  box:SetAutoFocus(false)
  box:SetFontObject(ChatFontNormal)
  if multiline then
    box:SetMultiLine(true)
    box:SetMaxLetters(0)
  end
  return box
end

local function createButton(parent, text, x, y, width, onClick)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetPoint("TOPLEFT", x, y)
  button:SetSize(width, 24)
  button:SetText(text)
  button:SetScript("OnClick", onClick)
  return button
end

local function readField(key)
  return fields[key] and fields[key]:GetText() or ""
end

local function clearInputFields()
  for _, key in ipairs({ "id", "addon", "name", "group", "format", "tags", "order", "instructions", "body" }) do
    fields[key]:SetText("")
  end
end

local function refreshList()
  local entries = ns.Core:GetEntries()
  local lines = {}
  for index, entry in ipairs(entries) do
    table.insert(lines, index .. ". " .. (entry.addon or "Unknown") .. " - " .. (entry.name or "Profile"))
  end
  listText:SetText(#lines > 0 and table.concat(lines, "\n") or "아직 추가된 항목이 없습니다.")
end

local function addManualEntry()
  ns.Core:AddEntry({
    id = readField("id"),
    addon = readField("addon"),
    name = readField("name"),
    group = readField("group"),
    format = readField("format"),
    tags = readField("tags"),
    order = readField("order"),
    instructions = readField("instructions"),
    source = "manual",
    body = readField("body")
  })
  clearInputFields()
  refreshList()
end

local function generateBundle()
  local bundle = ns.Core:BuildBundle()
  outputBox:SetText(bundle)
  outputBox:HighlightText()
  outputBox:SetFocus()
end

local function clearEntries()
  ns.Core:ClearEntries()
  outputBox:SetText("")
  refreshList()
end

function UI:Create()
  if frame then
    return frame
  end

  frame = CreateFrame("Frame", "ProfileExporterFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(760, 640)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()

  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
  frame.title:SetText("Profile Exporter")

  fields.id = createEditBox(frame, "ID", 18, -42, 170, 22)
  fields.addon = createEditBox(frame, "Addon", 204, -42, 170, 22)
  fields.name = createEditBox(frame, "Name", 390, -42, 170, 22)
  fields.order = createEditBox(frame, "Order", 576, -42, 80, 22)

  fields.group = createEditBox(frame, "Group", 18, -92, 170, 22)
  fields.format = createEditBox(frame, "Format", 204, -92, 170, 22)
  fields.tags = createEditBox(frame, "Tags", 390, -92, 266, 22)
  fields.instructions = createEditBox(frame, "Instructions", 18, -142, 638, 22)
  fields.body = createEditBox(frame, "Profile String", 18, -192, 310, 160, true)

  createButton(frame, "Add", 18, -372, 90, addManualEntry)
  createButton(frame, "Generate", 118, -372, 110, generateBundle)
  createButton(frame, "Clear", 238, -372, 90, clearEntries)

  createLabel(frame, "Current Bundle", 350, -192)
  outputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  outputBox:SetPoint("TOPLEFT", 350, -208)
  outputBox:SetSize(380, 260)
  outputBox:SetAutoFocus(false)
  outputBox:SetMultiLine(true)
  outputBox:SetMaxLetters(0)
  outputBox:SetFontObject(ChatFontNormal)

  createLabel(frame, "Added Entries", 18, -420)
  listText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  listText:SetPoint("TOPLEFT", 18, -438)
  listText:SetJustifyH("LEFT")
  listText:SetJustifyV("TOP")
  listText:SetSize(700, 150)

  refreshList()
  return frame
end

function UI:Toggle()
  local createdFrame = self:Create()
  createdFrame:SetShown(not createdFrame:IsShown())
  if createdFrame:IsShown() then
    refreshList()
  end
end
