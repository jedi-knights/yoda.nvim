local M = {}

local DEFAULT_CONFIG = {
  enabled = true,
  small_file_debounce = 150,
  medium_file_debounce = 300,
  large_file_debounce = 500,
  xlarge_file_debounce = 1000,
  small_file_threshold = 50 * 1024,
  medium_file_threshold = 200 * 1024,
  large_file_threshold = 500 * 1024,
  show_notifications = false,
}

local config = vim.deepcopy(DEFAULT_CONFIG)
local buffer_debounce_cache = {}

local function get_file_size(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return 0
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if not filepath or filepath == "" then
    return 0
  end

  local ok, stats = pcall(vim.loop.fs_stat, filepath)
  if ok and stats then
    return stats.size
  end

  return 0
end

local function calculate_debounce(size)
  if size < config.small_file_threshold then
    return config.small_file_debounce
  elseif size < config.medium_file_threshold then
    return config.medium_file_debounce
  elseif size < config.large_file_threshold then
    return config.large_file_debounce
  else
    return config.xlarge_file_debounce
  end
end

local function get_size_category(size)
  if size < config.small_file_threshold then
    return "small"
  elseif size < config.medium_file_threshold then
    return "medium"
  elseif size < config.large_file_threshold then
    return "large"
  else
    return "xlarge"
  end
end

function M.get_debounce(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not config.enabled then
    return config.small_file_debounce
  end

  if buffer_debounce_cache[bufnr] then
    return buffer_debounce_cache[bufnr]
  end

  local size = get_file_size(bufnr)
  local debounce = calculate_debounce(size)
  buffer_debounce_cache[bufnr] = debounce

  if config.show_notifications then
    local category = get_size_category(size)
    vim.notify(string.format("LSP debounce: %dms (file size: %s, category: %s)", debounce, M.format_size(size), category), vim.log.levels.INFO)
  end

  return debounce
end

function M.apply_to_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not config.enabled then
    return
  end

  local debounce = M.get_debounce(bufnr)

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities.textDocumentSync then
      local capabilities = client.server_capabilities
      if capabilities.textDocumentSync.change then
        vim.b[bufnr].lsp_debounce = debounce
      end
    end
  end
end

function M.clear_cache(bufnr)
  if bufnr then
    buffer_debounce_cache[bufnr] = nil
  else
    buffer_debounce_cache = {}
  end
end

function M.format_size(bytes)
  if bytes < 1024 then
    return bytes .. "B"
  elseif bytes < 1024 * 1024 then
    return string.format("%.1fKB", bytes / 1024)
  else
    return string.format("%.1fMB", bytes / (1024 * 1024))
  end
end

function M.get_stats(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local size = get_file_size(bufnr)
  local debounce = M.get_debounce(bufnr)
  local category = get_size_category(size)

  return {
    buffer = bufnr,
    size_bytes = size,
    size_formatted = M.format_size(size),
    category = category,
    debounce_ms = debounce,
    enabled = config.enabled,
  }
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, opts or {})

  if not config.enabled then
    return
  end

  local augroup = vim.api.nvim_create_augroup("YodaAdaptiveLSP", { clear = true })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = augroup,
    callback = function(args)
      M.apply_to_buffer(args.buf)
    end,
    desc = "Apply adaptive LSP debouncing",
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      M.apply_to_buffer(args.buf)
    end,
    desc = "Apply adaptive LSP debouncing on attach",
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    callback = function(args)
      M.clear_cache(args.buf)
    end,
    desc = "Clear adaptive LSP debounce cache on buffer delete",
  })

  vim.api.nvim_create_user_command("LSPDebounceStats", function()
    local stats = M.get_stats()
    print("=== Adaptive LSP Debouncing Stats ===")
    print(string.format("Buffer: %d", stats.buffer))
    print(string.format("File size: %s (%d bytes)", stats.size_formatted, stats.size_bytes))
    print(string.format("Category: %s", stats.category))
    print(string.format("Debounce: %dms", stats.debounce_ms))
    print(string.format("Enabled: %s", stats.enabled))
    print("=====================================")
  end, { desc = "Show adaptive LSP debouncing stats" })

  vim.api.nvim_create_user_command("LSPDebounceToggle", function()
    config.enabled = not config.enabled
    M.clear_cache()
    vim.notify(string.format("Adaptive LSP debouncing: %s", config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
  end, { desc = "Toggle adaptive LSP debouncing" })
end

function M.get_config()
  return vim.deepcopy(config)
end

return M
