local addonName, ns = ...

local function slug(value)
  value = tostring(value or ""):lower()
  value = value:gsub("[^%w_-]+", "-")
  value = value:gsub("^-+", ""):gsub("-+$", "")
  if value == "" then
    return "profile"
  end
  return value
end

local function copyTable(value, seen)
  if type(value) ~= "table" then
    return value
  end

  seen = seen or {}
  if seen[value] then
    return seen[value]
  end

  local copied = {}
  seen[value] = copied
  for key, child in pairs(value) do
    copied[copyTable(key, seen)] = copyTable(child, seen)
  end
  return copied
end

local function getCell()
  return _G.Cell
end

local function getCellVersionNumber(cell)
  if cell and cell.versionNum then
    return cell.versionNum
  end

  local version
  if _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata then
    version = _G.C_AddOns.GetAddOnMetadata("Cell", "Version")
  elseif _G.GetAddOnMetadata then
    version = _G.GetAddOnMetadata("Cell", "Version")
  end

  local versionNum = tonumber(string.match(tostring(version or ""), "%d+"))
  if versionNum then
    return versionNum
  end

  return nil
end

local function getCellExportString(cell)
  if not _G.CellDB then
    error("CellDB is not available")
  end

  local serializer = _G.LibStub and _G.LibStub:GetLibrary("LibSerialize", true)
  local deflate = _G.LibStub and _G.LibStub:GetLibrary("LibDeflate", true)
  if not serializer or not deflate then
    error("Cell export libraries are not available")
  end

  local versionNum = getCellVersionNumber(cell)
  if not versionNum then
    error("Cell version is not available")
  end

  local db
  if cell and cell.funcs and cell.funcs.Copy then
    db = cell.funcs.Copy(_G.CellDB)
  else
    db = copyTable(_G.CellDB)
  end

  -- Match Cell's own About > Import/Export exporter defaults.
  db.nicknames = nil
  db.flavor = cell and cell.flavor or "retail"
  db.fallbackGroupType = nil
  db.fallbackInMythic = nil

  local encoded = serializer:Serialize(db)
  encoded = deflate:CompressDeflate(encoded, { level = 9 })
  encoded = deflate:EncodeForPrint(encoded)

  return "!CELL:" .. tostring(versionNum) .. ":ALL!" .. encoded
end

ns.RegisterAdapter({
  id = "cell",
  label = "Cell",

  isAvailable = function()
    return getCell() and _G.CellDB and _G.LibStub and _G.LibStub:GetLibrary("LibSerialize", true) and _G.LibStub:GetLibrary("LibDeflate", true)
  end,

  export = function()
    local cell = getCell()
    if not cell then
      error("Cell is not available")
    end

    local body = getCellExportString(cell)
    if not body or body == "" then
      error("Cell profile export returned empty text")
    end

    local profileName = "Cell Settings"
    if _G.UnitName then
      local playerName = _G.UnitName("player")
      if playerName and playerName ~= "" then
        profileName = playerName
      end
    end

    return {
      id = "cell-" .. slug(profileName),
      addon = "Cell",
      name = profileName,
      group = "Raid Frames",
      format = "cell",
      tags = "raid-frame, required",
      order = "140",
      instructions = "Cell 옵션의 가져오기 창에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
