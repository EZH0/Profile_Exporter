local addonName, ns = ...

ns.RegisterAdapter({
  id = "xiv",
  label = "XIV Databar",

  isAvailable = function()
    return _G.XIVBar and _G.XIVBar.ExportProfile ~= nil
  end,

  export = function()
    local body = _G.XIVBar:ExportProfile()
    if not body or body == "" then
      error("XIV Databar export returned empty text")
    end

    return {
      id = "xiv-main",
      addon = "XIV",
      name = "XIV",
      group = "XIV",
      format = "xiv",
      tags = "bar",
      order = "105",
      instructions = "XIV 프로필 가져오기 기능에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
