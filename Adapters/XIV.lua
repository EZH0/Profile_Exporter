local addonName, ns = ...

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

local function getXIVBar()
  if _G.XIVBar and _G.XIVBar.db then
    return _G.XIVBar
  end

  local aceAddon = _G.LibStub and _G.LibStub("AceAddon-3.0", true)
  if not aceAddon or not aceAddon.GetAddon then
    return nil
  end

  return aceAddon:GetAddon("XIV_Databar_Continued", true)
end

local function encodeProfile(profile)
  if not _G.C_EncodingUtil then
    return nil
  end

  local serialized = C_EncodingUtil.SerializeCBOR(profile)
  if not serialized then
    return nil
  end

  local compressed = C_EncodingUtil.CompressString(serialized, 0, 2)
  if not compressed then
    return nil
  end

  return "PE:XIV:1:" .. C_EncodingUtil.EncodeBase64(compressed, 0)
end

ns.RegisterAdapter({
  id = "xiv",
  label = "XIV Databar",

  isAvailable = function()
    local xiv = getXIVBar()
    return xiv and xiv.db and xiv.db.profile and _G.C_EncodingUtil ~= nil
  end,

  export = function()
    local xiv = getXIVBar()
    if not xiv or not xiv.db or not xiv.db.profile then
      error("XIV Databar profile is not available")
    end

    local profileName = "Default"
    if xiv.db.GetCurrentProfile then
      profileName = xiv.db:GetCurrentProfile() or profileName
    end

    local body = encodeProfile({
      addon = "XIV_Databar_Continued",
      payloadType = "Profile",
      payloadVersion = 1,
      profileName = profileName,
      profile = copyTable(xiv.db.profile)
    })

    if not body or body == "" then
      error("XIV Databar export returned empty text")
    end

    return {
      id = "xiv-main",
      addon = "XIV",
      name = profileName,
      group = "XIV",
      format = "xiv",
      tags = "bar",
      order = "105",
      instructions = "Profile Exporter backup string for XIV_Databar_Continued.",
      source = "profile-exporter",
      body = body
    }
  end
})
