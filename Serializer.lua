local addonName, ns = ...

local Serializer = {}
ns.Serializer = Serializer

local BEGIN_MARKER = "===== WOW_PROFILE_VAULT BEGIN ====="
local CONTENT_MARKER = "===== CONTENT ====="
local END_MARKER = "===== WOW_PROFILE_VAULT END ====="

local function trim(value)
  local trimmed = tostring(value or ""):gsub("^%s+", "")
  trimmed = trimmed:gsub("%s+$", "")
  return trimmed
end

local function sanitizeHeader(value)
  local sanitized = trim(value):gsub("[\r\n]", " ")
  return sanitized
end

local function addHeader(lines, key, value)
  value = sanitizeHeader(value)
  if value ~= "" then
    table.insert(lines, key .. ": " .. value)
  end
end

function Serializer.SerializeEntry(entry)
  local lines = {}
  table.insert(lines, BEGIN_MARKER)
  addHeader(lines, "id", entry.id)
  addHeader(lines, "addon", entry.addon)
  addHeader(lines, "name", entry.name)
  addHeader(lines, "group", entry.group)
  addHeader(lines, "format", entry.format)
  addHeader(lines, "version", entry.version)
  addHeader(lines, "tags", entry.tags)
  addHeader(lines, "order", entry.order)
  addHeader(lines, "instructions", entry.instructions)
  addHeader(lines, "source", entry.source or "manual")
  table.insert(lines, CONTENT_MARKER)
  table.insert(lines, trim(entry.body))
  table.insert(lines, END_MARKER)
  return table.concat(lines, "\n")
end

function Serializer.SerializeBundle(entries)
  local chunks = {}
  for _, entry in ipairs(entries or {}) do
    if trim(entry.body) ~= "" then
      table.insert(chunks, Serializer.SerializeEntry(entry))
    end
  end
  return table.concat(chunks, "\n\n")
end
