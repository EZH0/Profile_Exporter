local addonName, ns = ...

local Core = {}
ns.Core = Core

local defaults = {
  entries = {}
}

local function copyDefaults(source, target)
  target = target or {}
  for key, value in pairs(source) do
    if type(value) == "table" then
      target[key] = copyDefaults(value, target[key])
    elseif target[key] == nil then
      target[key] = value
    end
  end
  return target
end

local function slug(value)
  value = tostring(value or ""):lower()
  value = value:gsub("[^%w_-]+", "-")
  value = value:gsub("^-+", ""):gsub("-+$", "")
  if value == "" then
    return "profile"
  end
  return value
end

function Core:OnLoad()
  ProfileExporterDB = copyDefaults(defaults, ProfileExporterDB)
  self.db = ProfileExporterDB
end

function Core:AddEntry(entry)
  entry.id = entry.id ~= "" and entry.id or slug((entry.addon or "") .. "-" .. (entry.name or ""))
  entry.format = entry.format ~= "" and entry.format or slug(entry.addon)
  entry.group = entry.group ~= "" and entry.group or entry.addon
  entry.source = entry.source ~= "" and entry.source or "manual"
  table.insert(self.db.entries, entry)
end

function Core:ClearEntries()
  self.db.entries = {}
end

function Core:GetEntries()
  return self.db.entries
end

function Core:BuildBundle()
  return ns.Serializer.SerializeBundle(self.db.entries)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, loadedAddon)
  if loadedAddon ~= addonName then
    return
  end

  Core:OnLoad()
end)

SLASH_PROFILEEXPORTER1 = "/pex"
SLASH_PROFILEEXPORTER2 = "/profileexporter"
SlashCmdList.PROFILEEXPORTER = function()
  if ns.UI then
    ns.UI:Toggle()
  end
end
