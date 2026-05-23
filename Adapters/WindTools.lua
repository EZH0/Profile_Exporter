local addonName, ns = ...

ns.RegisterAdapter({
  id = "windtools",
  label = "ElvUI WindTools",

  isAvailable = function()
    local WT = _G.WindTools
    local F = WT and WT[2]
    return F and F.Profiles and F.Profiles.GetOutputString ~= nil
  end,

  export = function()
    local WT = _G.WindTools
    local F = WT and WT[2]
    if not F or not F.Profiles or not F.Profiles.GetOutputString then
      error("WindTools profile export API is not available")
    end

    local body = F.Profiles.GetOutputString(true, true)
    if not body or body == "" then
      error("WindTools profile export returned empty text")
    end

    return {
      id = "windtools-main",
      addon = "ElvUI WindTools",
      name = "WindTools Profile",
      group = "Elv UI",
      format = "windtools",
      tags = "ui, required",
      order = "50",
      instructions = "WindTools 설정 > 고급 > 프로필 가져오기에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
