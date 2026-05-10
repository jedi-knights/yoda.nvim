-- lua/plugins/nvim-treesitter.lua
--
-- Uses the new nvim-treesitter main branch API (post-rewrite).
-- The legacy require("nvim-treesitter.configs").setup() was removed;
-- highlighting and indentation are configured via native vim.treesitter APIs.

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  -- The new main branch does not support lazy-loading; it must be available
  -- before any buffer triggers treesitter parsing.
  lazy = false,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
  },
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Register the custom gherkin parser so :TSInstall gherkin works.
    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      desc = "Register gherkin parser for nvim-treesitter",
      callback = function()
        require("nvim-treesitter.parsers").gherkin = {
          install_info = {
            url = "https://github.com/binhtran432k/tree-sitter-gherkin",
            branch = "main",
          },
        }
      end,
    })

    vim.treesitter.language.register("gherkin", "feature")

    -- Install desired parsers on first run (async, non-blocking).
    -- "comment" intentionally omitted: it is a pure injection parser that runs
    -- over every buffer in every language, adding injection query overhead on
    -- every file open. Per-language comment highlighting is already handled
    -- natively by each language's own parser.
    local ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "python",
      "rust",
      "go",
      "javascript",
      "typescript",
      "c_sharp",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
      "bash",
      "regex",
      "gherkin",
    }

    local installed = require("nvim-treesitter").get_installed()
    local missing = vim
      .iter(ensure_installed)
      :filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end)
      :totable()

    if #missing > 0 then
      -- The main-branch rewrite shells out to the `tree-sitter` CLI to compile
      -- parsers; without it, install() emits one ENOENT per parser. Surface a
      -- single actionable error instead.
      if vim.fn.executable("tree-sitter") == 0 then
        vim.notify(
          "nvim-treesitter: `tree-sitter` CLI not found on PATH. "
            .. "Install it (`brew install tree-sitter-cli`) and restart Neovim. "
            .. "Missing parsers: "
            .. table.concat(missing, ", "),
          vim.log.levels.ERROR
        )
      else
        require("nvim-treesitter").install(missing)
      end
    end

    -- Enable treesitter highlighting and indentation for all filetypes.
    -- Cache the indentexpr function in a stable global so the indentexpr
    -- evaluation (called on every indent op) does not re-resolve require()
    -- on each keystroke.
    _G.YodaTSIndent = require("nvim-treesitter").indentexpr
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("YodaTreesitter", { clear = true }),
      desc = "Enable treesitter highlight and indent",
      callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.YodaTSIndent()"
        end
      end,
    })

    -- Configure nvim-treesitter-textobjects (main branch API).
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
    })

    -- stylua: ignore start
    vim.keymap.set({ "x", "o" }, "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end, { desc = "around function" })
    vim.keymap.set({ "x", "o" }, "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end, { desc = "inside function" })
    vim.keymap.set({ "x", "o" }, "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects") end, { desc = "around class" })
    vim.keymap.set({ "x", "o" }, "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects") end, { desc = "inside class" })
    -- stylua: ignore end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "feature",
      desc = "Set commentstring for Gherkin feature files",
      callback = function()
        vim.bo.commentstring = "# %s"
      end,
    })

    -- Treesitter foldexpr disabled: setting foldmethod=expr causes Neovim to
    -- re-evaluate the foldexpr on every text change, adding measurable typing
    -- lag. Manual folding (set in options.lua) is used instead.
  end,
}
