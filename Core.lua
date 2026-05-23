local addonName, ns = ...

local Core = {}
ns.Core = Core

local defaults = {
  entries = {},
  adapters = {},
  options = {
    detailsAllProfiles = false
  },
  minimap = {
    angle = 225
  }
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

function Core:NormalizeEntry(entry)
  entry = entry or {}
  entry.id = entry.id and entry.id ~= "" and entry.id or slug((entry.addon or "") .. "-" .. (entry.name or ""))
  entry.format = entry.format and entry.format ~= "" and entry.format or slug(entry.addon)
  entry.group = entry.group and entry.group ~= "" and entry.group or entry.addon
  entry.source = entry.source and entry.source ~= "" and entry.source or "manual"
  return entry
end

function Core:OnLoad()
  ProfileExporterDB = copyDefaults(defaults, ProfileExporterDB)
  self.db = ProfileExporterDB
end

function Core:GetAdapterEnabled(adapterId)
  if not self.db then
    self:OnLoad()
  end

  local value = self.db.adapters and self.db.adapters[adapterId]
  return value ~= false
end

function Core:SetAdapterEnabled(adapterId, enabled)
  if not self.db then
    self:OnLoad()
  end

  self.db.adapters[adapterId] = enabled and true or false
end

function Core:GetOption(key)
  if not self.db then
    self:OnLoad()
  end

  return self.db.options and self.db.options[key]
end

function Core:SetOption(key, value)
  if not self.db then
    self:OnLoad()
  end

  self.db.options[key] = value
end

function Core:GetMinimapAngle()
  if not self.db then
    self:OnLoad()
  end

  return tonumber(self.db.minimap and self.db.minimap.angle) or defaults.minimap.angle
end

function Core:SetMinimapAngle(angle)
  if not self.db then
    self:OnLoad()
  end

  self.db.minimap.angle = angle
end

function Core:AddEntry(entry)
  entry = self:NormalizeEntry(entry)

  for index, existing in ipairs(self.db.entries) do
    if existing.id == entry.id then
      self.db.entries[index] = entry
      return entry, "updated"
    end
  end

  table.insert(self.db.entries, entry)
  return entry, "added"
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

function Core:CollectAdapters()
  local results = {}
  local adapters = ns.GetAdapters and ns.GetAdapters() or {}

  for _, adapter in ipairs(adapters) do
    local label = adapter.label or adapter.id or "Unknown"
    if not self:GetAdapterEnabled(adapter.id) then
      table.insert(results, {
        label = label,
        skipped = true,
        count = 0
      })
    else
      local availableOk, isAvailable = pcall(adapter.isAvailable or function() return false end)
      local ok, exported = false, nil
      local count = 0

      if availableOk and isAvailable then
        ok, exported = pcall(adapter.export, adapter)
      else
        exported = availableOk and "not available" or isAvailable
      end

      if ok and exported then
        local entries = exported.body and { exported } or exported
        if type(entries) == "table" then
          for _, entry in ipairs(entries) do
            if type(entry) == "table" and entry.body and entry.body ~= "" then
              self:AddEntry(entry)
              count = count + 1
            end
          end
        end
      end

      table.insert(results, {
        label = label,
        ok = ok and count > 0,
        count = count,
        error = ok and nil or tostring(exported)
      })
    end
  end

  return results
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
