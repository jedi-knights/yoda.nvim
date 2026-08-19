-- Minimal init for plenary.nvim-based test runs.
-- Boots yoda's runtimepath, locates plenary, and stubs the yoda-* sibling
-- plugins so unit tests can run in isolation.

-- Get the root directory
local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")

-- Add lua/ to runtimepath so tests can require modules
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(root .. "/lua")

-- Prepend the repo's lua/ to package.path so require() finds our copy
-- before any personal ~/.config/nvim install of yoda that sits earlier in rtp.
package.path = root
  .. "/lua/?.lua;"
  .. root
  .. "/lua/?/init.lua;"
  .. package.path

-- Minimal Neovim settings for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

-- Disable notifications during fast tests for speed
vim.notify = function() end -- No-op notifications

-- Disable file watching and change detection
vim.opt.eventignore = "all"

-- Speed up test execution
vim.g.did_load_filetypes = 1
vim.g.did_indent_on = 1
vim.g.did_syntax_on = 1

-- Disable additional plugins that might slow down tests
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Disable plugins we don't need for tests
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Locate plenary. CI clones it to /tmp/plenary.nvim before invoking; local dev
-- typically has it under lazy.nvim's data dir. Fall back to a one-shot install
-- via lazy so a fresh `make test` on a new machine still works.
-- Empty-string fallback: ipairs stops on the first nil, so an unset
-- PLENARY_PATH would silently skip the /tmp and lazy candidates.
local plenary_candidates = {
  os.getenv("PLENARY_PATH") or "",
  "/tmp/plenary.nvim",
  vim.fn.stdpath("data") .. "/lazy/plenary.nvim",
}
local plenary_ready = false
for _, path in ipairs(plenary_candidates) do
  if path ~= "" and vim.uv.fs_stat(path) then
    vim.opt.rtp:prepend(path)
    -- --noplugin skips plugin/plenary.vim; source it explicitly so
    -- PlenaryBustedDirectory / PlenaryBustedFile get registered.
    vim.cmd("runtime plugin/plenary.vim")
    plenary_ready = true
    break
  end
end

if not plenary_ready then
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup({
    { "nvim-lua/plenary.nvim", lazy = false },
  }, {
    install = { missing = true },
    ui = { border = "rounded" },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = { cache = { enabled = false } },
  })
end

-- Note: vim.cmd mocking removed - was causing exit code issues in CI

-- Mock external yoda plugins for testing (extracted modules)
package.preload["yoda-adapters"] = function()
  return {}
end

package.preload["yoda-adapters.notification"] = function()
  return {
    notify = function(msg, level) end,
    reset_backend = function() end,
    detect_backend = function()
      return "native"
    end,
  }
end

package.preload["yoda-adapters.picker"] = function()
  return {
    select = function(items, opts, on_choice)
      if on_choice then
        on_choice(items[1], 1)
      end
    end,
    multiselect = function(items, opts, on_choice)
      if on_choice then
        on_choice(items)
      end
    end,
  }
end

package.preload["yoda-core"] = function()
  return {}
end

package.preload["yoda-core.io"] = function()
  return {
    file_exists = function(path)
      return vim.fn.filereadable(path) == 1
    end,
    is_file = function(path)
      return vim.fn.filereadable(path) == 1
    end,
    read_file = function(path)
      local f = io.open(path, "r")
      if not f then
        return nil
      end
      local content = f:read("*all")
      f:close()
      return content
    end,
    parse_json_file = function(path)
      if vim.fn.filereadable(path) == 0 then
        return nil
      end
      local ok, content = pcall(vim.fn.readfile, path)
      if not ok or #content == 0 then
        return nil
      end
      local json_ok, result =
        pcall(vim.fn.json_decode, table.concat(content, "\n"))
      if not json_ok then
        return nil
      end
      return result
    end,
  }
end

package.preload["yoda-logging"] = function()
  return {
    LEVELS = { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 },
    setup = function() end,
  }
end

package.preload["yoda-logging.logger"] = function()
  local noop = function() end
  return {
    trace = noop,
    debug = noop,
    info = noop,
    warn = noop,
    error = noop,
    set_strategy = noop,
    set_level = noop,
  }
end

package.preload["yoda-logging.config"] = function()
  return {
    LEVELS = {
      TRACE = 0,
      DEBUG = 1,
      INFO = 2,
      WARN = 3,
      ERROR = 4,
    },
    get_level = function()
      return 2
    end,
    set_level = function() end,
  }
end

package.preload["yoda-logging.formatter"] = function()
  return {
    format = function(level, message, context)
      return message
    end,
  }
end

package.preload["yoda-terminal"] = function()
  return {
    setup = function() end,
  }
end

package.preload["yoda-window"] = function()
  return {
    setup = function() end,
  }
end

package.preload["yoda-window.utils"] = function()
  return {
    is_special_buffer = function()
      return false
    end,
    is_protected_buffer = function()
      return false
    end,
  }
end

package.preload["yoda-diagnostics"] = function()
  return {
    setup = function() end,
    run_all = function() end,
  }
end

package.preload["yoda-diagnostics.ai"] = function()
  return {
    display_detailed_check = function() end,
  }
end

package.preload["yoda-diagnostics.ai_cli"] = function()
  return {
    get_claude_path = function()
      return nil
    end,
    is_claude_available = function()
      return false
    end,
    get_claude_version = function()
      return nil, nil
    end,
  }
end
