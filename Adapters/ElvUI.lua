local addonName, ns = ...

local exportTypes = {
  {
    dataType = "profile",
    id = "elvui-import-1",
    name = "ElvUI 1",
    order = "10"
  },
  {
    dataType = "private",
    id = "elvui-import-2",
    name = "ElvUI 2",
    order = "20"
  },
  {
    dataType = "global",
    id = "elvui-import-3",
    name = "ElvUI 3",
    order = "30"
  },
  {
    dataType = "filters",
    id = "elvui-import-4",
    name = "ElvUI 4",
    order = "40"
  }
}

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

    local entries = {}
    for _, exportType in ipairs(exportTypes) do
      local _, body = distributor:GetProfileExport(exportType.dataType, nil, "text")
      if body and body ~= "" then
        table.insert(entries, {
          id = exportType.id,
          addon = "ElvUI",
          name = exportType.name,
          group = "Elv UI",
          format = "elvui",
          tags = "ui, required",
          order = exportType.order,
          instructions = "ElvUI 프로필 가져오기 창에 붙여넣습니다.",
          source = "official-export",
          body = body
        })
      end
    end

    if #entries == 0 then
      error("ElvUI profile export returned empty text")
    end

    return entries
  end
})
