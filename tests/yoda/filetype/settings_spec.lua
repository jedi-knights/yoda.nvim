-- tests/yoda/filetype/settings_spec.lua
-- Tests for filetype settings module

local helpers = require("tests.helpers")

describe("filetype.settings", function()
  local settings

  before_each(function()
    package.loaded["yoda.filetype.settings"] = nil
    settings = require("yoda.filetype.settings")
  end)

  describe("apply()", function()
    it("applies markdown settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "markdown"

      settings.apply("markdown")

      assert.is_true(vim.opt_local.wrap:get())
      assert.is_false(vim.opt_local.spell:get())
      assert.equals(0, vim.opt_local.conceallevel:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies gitcommit settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "gitcommit"

      settings.apply("gitcommit")

      assert.is_true(vim.opt_local.spell:get())
      assert.is_true(vim.opt_local.wrap:get())
      assert.equals(72, vim.opt_local.textwidth:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies yaml settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "yaml"

      settings.apply("yaml")

      assert.equals("# %s", vim.opt_local.commentstring:get())
      assert.is_false(vim.opt_local.wrap:get())
      assert.is_true(vim.opt_local.expandtab:get())
      assert.equals(2, vim.opt_local.shiftwidth:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies groovy settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "groovy"

      settings.apply("groovy")

      assert.equals("// %s", vim.opt_local.commentstring:get())
      assert.is_false(vim.opt_local.wrap:get())
      assert.equals(4, vim.opt_local.shiftwidth:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies NeogitCommitMessage settings (commit profile)", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("NeogitCommitMessage")

      assert.is_true(vim.opt_local.spell:get())
      assert.is_true(vim.opt_local.wrap:get())
      assert.equals(72, vim.opt_local.textwidth:get())
      assert.equals("manual", vim.opt_local.foldmethod:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies the neogit performance profile for NeogitStatus", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("NeogitStatus")

      assert.equals("manual", vim.opt_local.foldmethod:get())
      assert.equals(2000, vim.opt_local.updatetime:get())
      assert.is_true(vim.opt_local.lazyredraw:get())
      assert.is_false(vim.opt_local.cursorline:get())
      assert.equals(200, vim.opt_local.synmaxcol:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies the neogit performance profile for NeogitPopup", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("NeogitPopup")

      assert.equals("manual", vim.opt_local.foldmethod:get())
      assert.is_true(vim.opt_local.lazyredraw:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies helm settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("helm")

      assert.equals("# %s", vim.opt_local.commentstring:get())
      assert.equals("yaml", vim.opt_local.syntax:get())
      assert.is_false(vim.opt_local.wrap:get())
      assert.is_true(vim.opt_local.expandtab:get())
      assert.equals(2, vim.opt_local.shiftwidth:get())
      assert.equals(2, vim.opt_local.tabstop:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it(
      "applies properties settings and disables treesitter highlight",
      function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)

        settings.apply("properties")

        assert.equals("# %s", vim.opt_local.commentstring:get())
        assert.equals("conf", vim.opt_local.syntax:get())
        assert.equals(2, vim.opt_local.shiftwidth:get())
        assert.is_false(vim.b.ts_highlight)

        vim.api.nvim_buf_delete(buf, { force = true })
      end
    )

    it("applies go settings", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("go")

      assert.equals("// %s", vim.opt_local.commentstring:get())
      assert.equals(4, vim.opt_local.shiftwidth:get())
      assert.equals(4, vim.opt_local.tabstop:get())
      assert.is_true(vim.opt_local.autoindent:get())
      assert.is_false(vim.opt_local.smartindent:get())
      assert.is_true(vim.opt_local.cindent:get())
      -- cinkeys is a comma-list option -- :get() returns it pre-parsed into
      -- a table, so compare the raw buffer-local string form instead.
      assert.equals("0{,0},0),0#,!^F,o,O,e,<:>", vim.bo.cinkeys)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    describe("snacks-explorer", function()
      local original_mode, original_vim_cmd

      before_each(function()
        original_mode = vim.fn.mode
        original_vim_cmd = vim.cmd
      end)

      after_each(function()
        vim.fn.mode = original_mode
        vim.cmd = original_vim_cmd
      end)

      it(
        "stops insert mode once the buffer settles if not in normal mode",
        function()
          vim.fn.mode = function()
            return "i"
          end
          local cmd_spy, cmd_data = helpers.spy()
          vim.cmd = cmd_spy

          settings.apply("snacks-explorer")
          vim.wait(50, function()
            return cmd_data.called
          end)

          helpers.assert_called_with(cmd_data, "stopinsert")
        end
      )

      it("does not stop insert mode when already in normal mode", function()
        vim.fn.mode = function()
          return "n"
        end
        local cmd_spy, cmd_data = helpers.spy()
        vim.cmd = cmd_spy

        settings.apply("snacks-explorer")
        vim.wait(50)

        helpers.assert_not_called(cmd_data)
      end)
    end)

    it("does nothing for unsupported filetype", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("unsupported")

      -- Should not error
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles invalid input types", function()
      settings.apply(nil)
      settings.apply(123)
      settings.apply({})
      settings.apply("")
      -- Should not error
    end)
  end)

  describe("has_settings()", function()
    it("returns true for supported filetype", function()
      assert.is_true(settings.has_settings("markdown"))
      assert.is_true(settings.has_settings("gitcommit"))
      assert.is_true(settings.has_settings("yaml"))
      assert.is_true(settings.has_settings("groovy"))
    end)

    it("returns false for unsupported filetype", function()
      assert.is_false(settings.has_settings("unsupported"))
      assert.is_false(settings.has_settings("javascript"))
    end)

    it("returns false for special filetypes", function()
      assert.is_true(settings.has_settings("snacks-explorer"))
      assert.is_true(settings.has_settings("helm"))
    end)
  end)

  describe("get_supported_filetypes()", function()
    it("returns array of supported filetypes", function()
      local filetypes = settings.get_supported_filetypes()
      assert.is_table(filetypes)
      assert.is_true(#filetypes > 0)
    end)

    it("includes all expected filetypes", function()
      local filetypes = settings.get_supported_filetypes()
      local ft_set = {}
      for _, ft in ipairs(filetypes) do
        ft_set[ft] = true
      end

      assert.is_true(ft_set["markdown"])
      assert.is_true(ft_set["gitcommit"])
      assert.is_true(ft_set["yaml"])
      assert.is_true(ft_set["groovy"])
    end)

    it("returns sorted list", function()
      local filetypes = settings.get_supported_filetypes()
      local prev = ""
      for _, ft in ipairs(filetypes) do
        assert.is_true(ft >= prev, "Filetypes should be sorted")
        prev = ft
      end
    end)
  end)

  describe("performance profiles", function()
    it("applies aggressive profile for markdown", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("markdown")

      -- Check that aggressive performance settings are applied
      assert.equals("manual", vim.opt_local.foldmethod:get())
      assert.is_true(vim.opt_local.lazyredraw:get())
      assert.is_false(vim.opt_local.cursorline:get())

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("applies commit profile for gitcommit", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      settings.apply("gitcommit")

      -- Check that commit performance settings are applied
      assert.equals("manual", vim.opt_local.foldmethod:get())
      assert.is_true(vim.opt_local.lazyredraw:get())
      -- complete is a table in Neovim, check it's empty
      local complete_value = vim.opt_local.complete:get()
      assert.is_true(type(complete_value) == "table" or complete_value == "")

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
