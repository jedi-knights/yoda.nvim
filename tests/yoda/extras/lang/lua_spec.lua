-- tests/yoda/extras/lang/lua_spec.lua

describe("extras.lang.lua", function()
  it(
    "declares lazydev.nvim scoped to lua buffers with the luv library",
    function()
      -- Act
      package.loaded["yoda.extras.lang.lua"] = nil
      local spec = require("yoda.extras.lang.lua")

      -- Assert
      assert.equals("folke/lazydev.nvim", spec[1])
      assert.equals("lua", spec.ft)
      assert.equals("${3rd}/luv/library", spec.opts.library[1].path)
      assert.same({ "vim%.uv" }, spec.opts.library[1].words)
    end
  )
end)
