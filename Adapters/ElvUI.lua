local addonName, ns = ...

ns.RegisterAdapter({
  id = "elvui",
  label = "ElvUI",

  isAvailable = function()
    local E = _G.ElvUI and _G.ElvUI[1]
    return E and E.GetModule and E:GetModule("Distributor", true) ~= nil
  end,

  export = function()
    local E = _G.ElvUI and _G.ElvUI[1]
    local distributor = E and E.GetModule and E:GetModule("Distributor", true)
    if not distributor or not distributor.GetProfileExport then
      error("ElvUI Distributor export API is not available")
    end

    local profileName, body = distributor:GetProfileExport("profile", nil, "text")
    if not body or body == "" then
      error("ElvUI profile export returned empty text")
    end

    return {
      id = "elvui-" .. tostring(profileName or "current"):lower():gsub("[^%w_-]+", "-"),
      addon = "ElvUI",
      name = profileName or "Current Profile",
      group = "Elv UI",
      format = "elvui",
      tags = "ui, required",
      order = "10",
      instructions = "ElvUI 프로필 가져오기 창에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
