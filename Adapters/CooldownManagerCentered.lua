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

local function getAddon()
  return _G.CooldownManagerCentered
end

ns.RegisterAdapter({
  id = "cooldown-manager-centered",
  label = "Cooldown Manager Centered",

  isAvailable = function()
    local addon = getAddon()
    return addon and addon.ExportCurrentProfileToString ~= nil
  end,

  export = function()
    local addon = getAddon()
    if not addon or not addon.ExportCurrentProfileToString then
      error("Cooldown Manager Centered export API is not available")
    end

    local profileName = "Current Profile"
    if addon.db and addon.db.GetCurrentProfile then
      profileName = addon.db:GetCurrentProfile()
    end

    local body = addon:ExportCurrentProfileToString()
    if not body or body == "" then
      error("Cooldown Manager Centered profile export returned empty text")
    end

    return {
      id = "cooldown-manager-centered-" .. slug(profileName),
      addon = "Cooldown Manager Centered",
      name = profileName or "Current Profile",
      group = "Cooldown Manager",
      format = "cooldown-manager-centered",
      tags = "cooldown, ui, required",
      order = "130",
      instructions = "Cooldown Manager Centered 설정의 프로필 가져오기 창에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
