local addonName, ns = ...

local function getDetails()
  return _G.Details or _G._detalhes
end

ns.RegisterAdapter({
  id = "details",
  label = "Details!",

  isAvailable = function()
    local details = getDetails()
    return details and (details.ExportCurrentProfile or (_G.DetailsAPI and _G.DetailsAPI.ExportProfile))
  end,

  export = function()
    local details = getDetails()
    if not details then
      error("Details is not available")
    end

    local profileName = details.GetCurrentProfileName and details:GetCurrentProfileName() or "Current Profile"
    local profileNames = { profileName }
    if ns.Core and ns.Core:GetOption("detailsAllProfiles") and details.GetProfileList then
      profileNames = details:GetProfileList() or profileNames
    end

    local entries = {}
    for index, name in ipairs(profileNames) do
      local body
      if details.ExportCurrentProfile then
        body = details:ExportCurrentProfile(name)
      elseif _G.DetailsAPI and _G.DetailsAPI.ExportProfile then
        body = _G.DetailsAPI:ExportProfile(name)
      end

      if body and body ~= "" and body ~= false then
        table.insert(entries, {
          id = "details-" .. tostring(name or "current"):lower():gsub("[^%w_-]+", "-"),
          addon = "Details!",
          name = name or "Damage Meter",
          group = "Details!",
          format = "details",
          tags = "meter",
          order = tostring(90 + index),
          instructions = "Details 프로필 가져오기 기능에 붙여넣습니다.",
          source = "official-export",
          body = body
        })
      end
    end

    if #entries == 0 then
      error("Details profile export returned empty text")
    end

    return entries
  end
})
