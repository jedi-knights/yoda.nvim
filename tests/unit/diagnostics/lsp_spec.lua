-- Tests for diagnostics/lsp.lua
local lsp = require("yoda-diagnostics.lsp")

describe("diagnostics.lsp", function()
  -- Save originals
  local original_get_active_clients = vim.lsp.get_active_clients
  local original_notify = vim.notify

  -- Restore after each test
  after_each(function()
    vim.lsp.get_active_clients = original_get_active_clients
    vim.notify = original_notify
  end)

  describe("get_clients()", function()
    it("returns active LSP clients", function()
      vim.lsp.get_active_clients = function()
        return {
          { name = "lua_ls", id = 1 },
          { name = "gopls", id = 2 },
        }
      end

      local clients = lsp.get_clients()
      assert.equals(2, #clients)
      assert.equals("lua_ls", clients[1].name)
      assert.equals("gopls", clients[2].name)
    end)

    it("returns empty table when no clients", function()
      vim.lsp.get_active_clients = function()
        return {}
      end

      local clients = lsp.get_clients()
      assert.same({}, clients)
    end)
  end)

  describe("get_client_names()", function()
    it("extracts client names from active clients", function()
      vim.lsp.get_active_clients = function()
        return {
          { name = "lua_ls" },
          { name = "gopls" },
          { name = "tsserver" },
        }
      end

      local names = lsp.get_client_names()
      assert.equals(3, #names)
      assert.same({ "lua_ls", "gopls", "tsserver" }, names)
    end)

    it("returns empty table when no clients", function()
      vim.lsp.get_active_clients = function()
        return {}
      end

      local names = lsp.get_client_names()
      assert.same({}, names)
    end)

    it("handles clients without names", function()
      vim.lsp.get_active_clients = function()
        return {
          { id = 1 }, -- No name field
          { name = "lua_ls" },
        }
      end

      local names = lsp.get_client_names()
      -- Lua tables don't store nil values, so array is compacted
      -- Only the non-nil name is stored
      assert.equals(1, #names)
      assert.equals("lua_ls", names[1])
    end)
  end)

  describe("check_status()", function()
    it("returns true when LSP clients active", function()
      vim.lsp.get_active_clients = function()
        return {
          { name = "lua_ls" },
        }
      end

      local notified = {}
      vim.notify = function(msg, level)
        table.insert(notified, msg)
      end

      local status = lsp.check_status()
      assert.is_true(status)
      assert.matches("Active LSP clients", notified[1])
      assert.matches("lua_ls", notified[2])
    end)

    it("returns false when no LSP clients active", function()
      vim.lsp.get_active_clients = function()
        return {}
      end

      local notified = false
      vim.notify = function(msg, level)
        if msg:match("No LSP clients") then
          notified = true
        end
      end

      local status = lsp.check_status()
      assert.is_false(status)
      assert.is_true(notified)
    end)

    it("notifies with WARN level when no clients", function()
      vim.lsp.get_active_clients = function()
        return {}
      end

      local level_used = nil
      vim.notify = function(msg, level)
        level_used = level
      end

      lsp.check_status()
      assert.equals(vim.log.levels.WARN, level_used)
    end)

    it("notifies with INFO level when clients active", function()
      vim.lsp.get_active_clients = function()
        return { { name = "test" } }
      end

      local level_used = nil
      vim.notify = function(msg, level)
        level_used = level
      end

      lsp.check_status()
      assert.equals(vim.log.levels.INFO, level_used)
    end)

    it("lists all active client names", function()
      vim.lsp.get_active_clients = function()
        return {
          { name = "lua_ls" },
          { name = "gopls" },
          { name = "tsserver" },
        }
      end

      local notified = {}
      vim.notify = function(msg)
        table.insert(notified, msg)
      end

      lsp.check_status()
      -- Should have header + 3 client names
      assert.is_true(#notified >= 4)

      local all_msgs = table.concat(notified, " ")
      assert.matches("lua_ls", all_msgs)
      assert.matches("gopls", all_msgs)
      assert.matches("tsserver", all_msgs)
    end)
  end)
end)
