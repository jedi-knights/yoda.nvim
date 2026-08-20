-- tests/yoda/plugins/blink_cmp_spec.lua

describe("plugins.blink-cmp", function()
  local spec

  before_each(function()
    package.loaded["yoda.plugins.blink-cmp"] = nil
    spec = require("yoda.plugins.blink-cmp")
  end)

  it(
    "declares blink.cmp, deferred to InsertEnter, pinned to a release tag",
    function()
      -- Assert
      assert.equals("saghen/blink.cmp", spec[1])
      assert.equals("InsertEnter", spec.event)
      assert.equals("1.*", spec.version)
      assert.same(
        { "rafamadriz/friendly-snippets", "folke/lazydev.nvim" },
        spec.dependencies
      )
    end
  )

  it(
    "enables lazydev only for lua buffers, kept out of the default sources",
    function()
      -- Assert
      assert.same(
        { "lsp", "path", "snippets", "buffer" },
        spec.opts.sources.default
      )
      assert.same(
        { "lsp", "path", "snippets", "lazydev" },
        spec.opts.sources.per_filetype.lua
      )
      assert.is_false(vim.tbl_contains(spec.opts.sources.default, "lazydev"))
    end
  )

  it("extends rather than replaces the default source list", function()
    -- Assert
    assert.same({ "sources.default" }, spec.opts_extend)
  end)
end)
