local addonName, ns = ...

local function encodeProfile(profileData)
  if not _G.C_EncodingUtil then
    return nil
  end

  local serialized = C_EncodingUtil.SerializeCBOR(profileData)
  if not serialized then
    return nil
  end

  local compressed = C_EncodingUtil.CompressString(serialized, 0, 2)
  if not compressed then
    return nil
  end

  return C_EncodingUtil.EncodeBase64(compressed, 0)
end

ns.RegisterAdapter({
  id = "dbm",
  label = "DBM",

  isAvailable = function()
    return _G.DBM and _G.DBM.Options and _G.DBT_AllPersistentOptions ~= nil
  end,

  export = function()
    local profileName = _G.DBM_UsedProfile or "Default"
    local body = encodeProfile({
      payloadType = "Profile",
      payloadVersion = 1,
      DBM = _G.DBM.Options,
      DBT = _G.DBT_AllPersistentOptions and _G.DBT_AllPersistentOptions[profileName],
      minimap = _G.DBM_MinimapIcon
    })

    if not body or body == "" then
      error("DBM profile export returned empty text")
    end

    return {
      id = "dbm-" .. tostring(profileName):lower():gsub("[^%w_-]+", "-"),
      addon = "DBM",
      name = profileName,
      group = "DBM",
      format = "dbm",
      tags = "boss-mod, required",
      order = "100",
      instructions = "DBM 프로필 가져오기 기능에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
