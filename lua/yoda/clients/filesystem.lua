-- lua/yoda/clients/filesystem.lua
-- Specialized filesystem clients with perfect ISP compliance
-- Each client only depends on the minimal interface it needs

local M = {}

local granular = require("yoda.interfaces.granular")
local core_loader = require("yoda.core.loader")

-- ============================================================================
-- SPECIALIZED CLIENTS (Perfect ISP)
-- ============================================================================

--- Create client that only needs file existence checking
--- Perfect ISP: depends only on FileExistenceInterface
--- @return table file_existence_client
function M.create_existence_client()
  local filesystem = core_loader.load_core("filesystem")

  return granular.create_minimal_client(filesystem, {
    "FileExistenceInterface",
  })
end

--- Create client that only needs file I/O operations
--- Perfect ISP: depends only on FileIOInterface
--- @return table file_io_client
function M.create_io_client()
  local filesystem = core_loader.load_core("filesystem")

  return granular.create_minimal_client(filesystem, {
    "FileIOInterface",
  })
end

--- Create client that needs both existence and I/O
--- Perfect ISP: composes only required interfaces
--- @return table full_filesystem_client
function M.create_full_client()
  local filesystem = core_loader.load_core("filesystem")

  return granular.create_minimal_client(filesystem, {
    "FileExistenceInterface",
    "FileIOInterface",
  })
end

-- ============================================================================
-- USAGE EXAMPLES (Perfect ISP in action)
-- ============================================================================

--- Configuration validator that only needs existence checking
--- Perfect ISP: doesn't depend on I/O methods it doesn't use
--- @param config_path string Path to config file
--- @return boolean valid
function M.validate_config_exists(config_path)
  local existence_client = M.create_existence_client()
  -- Client only has: is_file, is_dir, exists, file_exists
  -- Doesn't have: read_file, write_file (perfect ISP)
  return existence_client.is_file(config_path)
end

--- Log writer that only needs I/O operations
--- Perfect ISP: doesn't depend on existence methods after initial check
--- @param log_path string Path to log file
--- @param content string Content to write
--- @return boolean success
function M.write_log(log_path, content)
  local io_client = M.create_io_client()
  -- Client only has: read_file, write_file
  -- Doesn't have: is_file, is_dir, exists (perfect ISP)
  return io_client.write_file(log_path, content)
end

--- Backup utility that needs full filesystem access
--- Perfect ISP: composes exactly what it needs
--- @param source_path string Source file path
--- @param backup_path string Backup file path
--- @return boolean success
function M.create_backup(source_path, backup_path)
  local full_client = M.create_full_client()

  -- Check source exists
  if not full_client.is_file(source_path) then
    return false
  end

  -- Read source content
  local success, content = full_client.read_file(source_path)
  if not success then
    return false
  end

  -- Write backup
  return full_client.write_file(backup_path, content)
end

return M
