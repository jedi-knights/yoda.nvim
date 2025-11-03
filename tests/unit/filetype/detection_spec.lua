-- tests/unit/filetype/detection_spec.lua
-- Tests for filetype detection module

local helpers = require("tests.helpers")

describe("filetype.detection", function()
  local detection

  before_each(function()
    package.loaded["yoda.filetype.detection"] = nil
    detection = require("yoda.filetype.detection")
  end)

  describe("PATTERNS", function()
    it("has jenkinsfile patterns defined", function()
      assert.is_table(detection.PATTERNS.jenkinsfile)
      assert.is_true(#detection.PATTERNS.jenkinsfile > 0)
    end)

    it("includes expected jenkinsfile patterns", function()
      local patterns = detection.PATTERNS.jenkinsfile
      local pattern_set = {}
      for _, pattern in ipairs(patterns) do
        pattern_set[pattern] = true
      end

      assert.is_true(pattern_set["Jenkinsfile"])
      assert.is_true(pattern_set["*.Jenkinsfile"])
      assert.is_true(pattern_set["jenkinsfile"])
    end)
  end)

  describe("configure_jenkinsfile()", function()
    it("sets filetype to groovy", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      detection.configure_jenkinsfile()

      assert.equals("groovy", vim.bo.filetype)
      assert.equals("groovy", vim.bo.syntax)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("adds Jenkins-specific syntax highlighting", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      detection.configure_jenkinsfile()

      -- Verify the syntax was set up (checking that it runs without error)
      assert.equals("groovy", vim.bo.filetype)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("can be called multiple times safely", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      detection.configure_jenkinsfile()
      detection.configure_jenkinsfile()

      assert.equals("groovy", vim.bo.filetype)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("setup_jenkinsfile_detection()", function()
    it("creates autocmd with correct patterns", function()
      local autocmd_called = false
      local captured_opts = nil

      local mock_autocmd = function(events, opts)
        autocmd_called = true
        captured_opts = opts
      end

      local mock_augroup = function(name, opts)
        return name
      end

      detection.setup_jenkinsfile_detection(mock_autocmd, mock_augroup)

      assert.is_true(autocmd_called)
      assert.is_not_nil(captured_opts)
      assert.is_table(captured_opts.pattern)
      assert.is_function(captured_opts.callback)
    end)

    it("sets up autocmd for BufRead and BufNewFile events", function()
      local events_captured = nil

      local mock_autocmd = function(events, opts)
        events_captured = events
      end

      local mock_augroup = function(name, opts)
        return name
      end

      detection.setup_jenkinsfile_detection(mock_autocmd, mock_augroup)

      assert.is_table(events_captured)
      assert.equals(2, #events_captured)
    end)
  end)

  describe("setup_all()", function()
    it("sets up all detection autocmds", function()
      local autocmd_count = 0

      local mock_autocmd = function(events, opts)
        autocmd_count = autocmd_count + 1
      end

      local mock_augroup = function(name, opts)
        return name
      end

      detection.setup_all(mock_autocmd, mock_augroup)

      assert.is_true(autocmd_count > 0)
    end)

    it("calls setup_jenkinsfile_detection", function()
      local jenkinsfile_setup_called = false

      -- Spy on the setup function
      local original_setup = detection.setup_jenkinsfile_detection
      detection.setup_jenkinsfile_detection = function(autocmd, augroup)
        jenkinsfile_setup_called = true
        return original_setup(autocmd, augroup)
      end

      local mock_autocmd = function(events, opts) end
      local mock_augroup = function(name, opts)
        return name
      end

      detection.setup_all(mock_autocmd, mock_augroup)

      assert.is_true(jenkinsfile_setup_called)

      -- Restore original
      detection.setup_jenkinsfile_detection = original_setup
    end)
  end)

  describe("integration", function()
    it("correctly detects and configures Jenkinsfile", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "Jenkinsfile")
      vim.api.nvim_set_current_buf(buf)

      detection.configure_jenkinsfile()

      assert.equals("groovy", vim.bo[buf].filetype)
      assert.equals("groovy", vim.bo[buf].syntax)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
