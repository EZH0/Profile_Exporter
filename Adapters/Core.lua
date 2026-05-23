local addonName, ns = ...

ns.Adapters = {}

function ns.RegisterAdapter(adapter)
  if not adapter or not adapter.id then
    return
  end

  table.insert(ns.Adapters, adapter)
end

function ns.GetAdapters()
  return ns.Adapters
end

function ns.GetAvailableAdapters()
  local available = {}
  for _, adapter in ipairs(ns.Adapters) do
    local ok, isAvailable = pcall(adapter.isAvailable or function() return false end)
    if ok and isAvailable then
      table.insert(available, adapter)
    end
  end
  return available
end
