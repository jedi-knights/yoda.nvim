-- lua/yoda/core/string_di.lua
-- String manipulation utilities with Dependency Injection
-- Pure utility module - no dependencies needed, but maintains consistency

local M = {}

--- Create new string utilities instance (DI factory pattern)
--- @param deps table|nil No dependencies needed for pure utilities
--- @return table String utilities instance
function M.new(deps)
  deps = deps or {}
  local instance = {}

  --- Trim whitespace from both ends of string
  --- @param str string
  --- @return string
  function instance.trim(str)
    if type(str) ~= "string" then
      return ""
    end
    return str:match("^%s*(.-)%s*$") or ""
  end

  --- Check if string starts with prefix
  --- @param str string
  --- @param prefix string
  --- @return boolean
  function instance.starts_with(str, prefix)
    if type(str) ~= "string" or type(prefix) ~= "string" then
      return false
    end
    if prefix == "" then
      return true
    end
    return str:sub(1, #prefix) == prefix
  end

  --- Check if string ends with suffix
  --- @param str string
  --- @param suffix string
  --- @return boolean
  function instance.ends_with(str, suffix)
    if type(str) ~= "string" or type(suffix) ~= "string" then
      return false
    end
    if suffix == "" then
      return true
    end
    return str:sub(-#suffix) == suffix
  end

  --- Split string by delimiter
  --- @param str string
  --- @param delimiter string
  --- @return table
  function instance.split(str, delimiter)
    if type(str) ~= "string" then
      return {}
    end
    delimiter = delimiter or "%s"

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
    end
    return result
  end

  --- Get file extension from path
  --- @param path string
  --- @return string Extension without dot, or empty string
  function instance.get_extension(path)
    if type(path) ~= "string" then
      return ""
    end
    local ext = path:match("^.+%.(.+)$")
    return ext or ""
  end

  --- Check if string is blank (nil, empty, or whitespace only)
  --- @param str string|nil
  --- @return boolean
  function instance.is_blank(str)
    if not str then
      return true
    end
    if type(str) ~= "string" then
      return false
    end
    return str:match("^%s*$") ~= nil
  end

  return instance
end

return M
