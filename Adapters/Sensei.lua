local addonName, ns = ...

ns.RegisterAdapter({
  id = "sensei-resource-bar",
  label = "Sensei Resource Bar",

  isAvailable = function()
    return _G.SCRB and _G.SCRB.exportProfileAsString ~= nil
  end,

  export = function()
    local body = _G.SCRB.exportProfileAsString(true, true)
    if not body or body == "" then
      error("Sensei Resource Bar export returned empty text")
    end

    return {
      id = "sensei-resource-bar",
      addon = "Sensei Resource Bar",
      name = "Sensei Resource Bar",
      group = "Sensei",
      format = "sensei",
      tags = "resource, required",
      order = "110",
      instructions = "Sensei Resource Bar 가져오기 기능에 붙여넣습니다.",
      source = "official-export",
      body = body
    }
  end
})
