local helpers = require("tests.helpers")

describe("adaptive_lsp", function()
  local adaptive_lsp
  local test_buf

  before_each(function()
    package.loaded["yoda.performance.adaptive_lsp"] = nil
    adaptive_lsp = require("yoda.performance.adaptive_lsp")
    test_buf = vim.api.nvim_create_buf(false, true)
  end)

  after_each(function()
    if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end
    adaptive_lsp.clear_cache()
  end)

  describe("setup()", function()
    it("initializes with default config", function()
      adaptive_lsp.setup()
      local config = adaptive_lsp.get_config()
      assert.is_true(config.enabled)
      assert.equals(150, config.small_file_debounce)
    end)

    it("accepts custom config", function()
      adaptive_lsp.setup({
        small_file_debounce = 100,
        medium_file_debounce = 250,
        enabled = false,
      })
      local config = adaptive_lsp.get_config()
      assert.equals(100, config.small_file_debounce)
      assert.equals(250, config.medium_file_debounce)
      assert.is_false(config.enabled)
    end)

    it("creates user commands", function()
      adaptive_lsp.setup()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.LSPDebounceStats)
      assert.is_not_nil(commands.LSPDebounceToggle)
    end)

    it("creates autocmds when enabled", function()
      adaptive_lsp.setup({ enabled = true })
      local autocmds = vim.api.nvim_get_autocmds({ group = "YodaAdaptiveLSP" })
      assert.is_true(#autocmds > 0)
    end)
  end)

  describe("get_debounce()", function()
    it("returns small file debounce for small files", function()
      adaptive_lsp.setup({
        small_file_debounce = 150,
        small_file_threshold = 50 * 1024,
      })
      local debounce = adaptive_lsp.get_debounce(test_buf)
      assert.equals(150, debounce)
    end)

    it("returns default when disabled", function()
      adaptive_lsp.setup({
        enabled = false,
        small_file_debounce = 150,
      })
      local debounce = adaptive_lsp.get_debounce(test_buf)
      assert.equals(150, debounce)
    end)

    it("caches debounce values", function()
      adaptive_lsp.setup()
      local debounce1 = adaptive_lsp.get_debounce(test_buf)
      local debounce2 = adaptive_lsp.get_debounce(test_buf)
      assert.equals(debounce1, debounce2)
    end)
  end)

  describe("format_size()", function()
    it("formats bytes correctly", function()
      assert.equals("500B", adaptive_lsp.format_size(500))
    end)

    it("formats kilobytes correctly", function()
      assert.equals("1.0KB", adaptive_lsp.format_size(1024))
      assert.equals("50.0KB", adaptive_lsp.format_size(51200))
    end)

    it("formats megabytes correctly", function()
      assert.equals("1.0MB", adaptive_lsp.format_size(1024 * 1024))
      assert.equals("5.5MB", adaptive_lsp.format_size(5.5 * 1024 * 1024))
    end)
  end)

  describe("get_stats()", function()
    it("returns stats for buffer", function()
      adaptive_lsp.setup()
      local stats = adaptive_lsp.get_stats(test_buf)
      assert.is_not_nil(stats)
      assert.equals(test_buf, stats.buffer)
      assert.is_number(stats.size_bytes)
      assert.is_string(stats.size_formatted)
      assert.is_string(stats.category)
      assert.is_number(stats.debounce_ms)
    end)

    it("includes enabled status", function()
      adaptive_lsp.setup({ enabled = false })
      local stats = adaptive_lsp.get_stats(test_buf)
      assert.is_false(stats.enabled)
    end)

    it("categorizes file sizes correctly", function()
      adaptive_lsp.setup({
        small_file_threshold = 50 * 1024,
        medium_file_threshold = 200 * 1024,
        large_file_threshold = 500 * 1024,
      })
      local stats = adaptive_lsp.get_stats(test_buf)
      assert.equals("small", stats.category)
    end)
  end)

  describe("clear_cache()", function()
    it("clears single buffer cache", function()
      adaptive_lsp.setup()
      adaptive_lsp.get_debounce(test_buf)
      adaptive_lsp.clear_cache(test_buf)
    end)

    it("clears all caches when no buffer provided", function()
      adaptive_lsp.setup()
      local buf1 = vim.api.nvim_create_buf(false, true)
      local buf2 = vim.api.nvim_create_buf(false, true)
      adaptive_lsp.get_debounce(buf1)
      adaptive_lsp.get_debounce(buf2)
      adaptive_lsp.clear_cache()
      vim.api.nvim_buf_delete(buf1, { force = true })
      vim.api.nvim_buf_delete(buf2, { force = true })
    end)
  end)

  describe("apply_to_buffer()", function()
    it("applies debounce to buffer", function()
      adaptive_lsp.setup()
      adaptive_lsp.apply_to_buffer(test_buf)
    end)

    it("does nothing when disabled", function()
      adaptive_lsp.setup({ enabled = false })
      adaptive_lsp.apply_to_buffer(test_buf)
    end)
  end)

  describe("user commands", function()
    it("LSPDebounceStats displays stats", function()
      adaptive_lsp.setup()
      local ok = pcall(vim.cmd, "LSPDebounceStats")
      assert.is_true(ok)
    end)

    it("LSPDebounceToggle toggles enabled state", function()
      adaptive_lsp.setup({ enabled = true })
      vim.cmd("LSPDebounceToggle")
      local config = adaptive_lsp.get_config()
      assert.is_false(config.enabled)
      vim.cmd("LSPDebounceToggle")
      config = adaptive_lsp.get_config()
      assert.is_true(config.enabled)
    end)
  end)

  describe("edge cases", function()
    it("handles invalid buffer gracefully", function()
      adaptive_lsp.setup()
      local debounce = adaptive_lsp.get_debounce(999999)
      assert.is_number(debounce)
    end)

    it("handles buffer without file", function()
      adaptive_lsp.setup()
      local scratch_buf = vim.api.nvim_create_buf(false, true)
      local debounce = adaptive_lsp.get_debounce(scratch_buf)
      assert.is_number(debounce)
      vim.api.nvim_buf_delete(scratch_buf, { force = true })
    end)

    it("handles nil config gracefully", function()
      adaptive_lsp.setup(nil)
      local config = adaptive_lsp.get_config()
      assert.is_not_nil(config)
    end)
  end)

  describe("file size thresholds", function()
    it("uses correct debounce for small files", function()
      adaptive_lsp.setup({
        small_file_debounce = 100,
        small_file_threshold = 1024 * 1024,
      })
      local debounce = adaptive_lsp.get_debounce(test_buf)
      assert.equals(100, debounce)
    end)

    it("respects custom thresholds", function()
      adaptive_lsp.setup({
        small_file_threshold = 10 * 1024,
        medium_file_threshold = 50 * 1024,
        large_file_threshold = 100 * 1024,
        small_file_debounce = 100,
        medium_file_debounce = 200,
        large_file_debounce = 400,
        xlarge_file_debounce = 800,
      })
      local config = adaptive_lsp.get_config()
      assert.equals(10 * 1024, config.small_file_threshold)
      assert.equals(100, config.small_file_debounce)
    end)
  end)
end)
