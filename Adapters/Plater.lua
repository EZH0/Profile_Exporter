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

local function getCurrentProfileName()
  if _G.PlaterAPI and _G.PlaterAPI.GetCurrentProfileKey then
    local ok, profileName = pcall(_G.PlaterAPI.GetCurrentProfileKey, _G.PlaterAPI)
    if ok and profileName and profileName ~= "" then
      return profileName
    end
  end

  if _G.Plater and _G.Plater.db and _G.Plater.db.GetCurrentProfile then
    local ok, profileName = pcall(_G.Plater.db.GetCurrentProfile, _G.Plater.db)
    if ok and profileName and profileName ~= "" then
      return profileName
    end
  end

  return "Global"
end

local function exportProfile(profileName)
  if not (_G.PlaterAPI and _G.PlaterAPI.ExportProfile) then
    return nil
  end

  local ok, body = pcall(_G.PlaterAPI.ExportProfile, _G.PlaterAPI, profileName)
  if ok then
    return body
  end

  return nil
end

ns.RegisterAdapter({
  id = "plater",
  label = "Plater",

  isAvailable = function()
    return _G.Plater and _G.PlaterAPI and _G.PlaterAPI.ExportProfile ~= nil
  end,

  export = function()
    local profileName = getCurrentProfileName()
    local body = exportProfile(profileName)
    if not body or body == "" then
      error("Plater profile export returned empty text")
    end

    return {
      id = "plater-" .. slug(profileName),
      addon = "Plater",
      name = profileName or "Plater",
      group = "Plater",
      format = "plater",
      tags = "nameplate, required",
      order = "120",
      instructions = "Plater 프로필 가져오기 창에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
