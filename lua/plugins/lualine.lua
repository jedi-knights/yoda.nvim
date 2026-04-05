-- lua/plugins/lualine.lua

--- Diagnostic status component using vim.diagnostic.status() (Neovim 0.12+).
--- Falls back to the built-in "diagnostics" string component on older versions.
local function diagnostic_status()
  if not vim.diagnostic.status then
    return ""
  end
  local s = vim.diagnostic.status(0)
  if not s or vim.tbl_isempty(s) then
    return ""
  end
  local severity = vim.diagnostic.severity
  local parts = {}
  if (s[severity.ERROR] or 0) > 0 then
    parts[#parts + 1] = " " .. s[severity.ERROR]
  end
  if (s[severity.WARN] or 0) > 0 then
    parts[#parts + 1] = " " .. s[severity.WARN]
  end
  if (s[severity.INFO] or 0) > 0 then
    parts[#parts + 1] = " " .. s[severity.INFO]
  end
  if (s[severity.HINT] or 0) > 0 then
    parts[#parts + 1] = "󰌵 " .. s[severity.HINT]
  end
  return table.concat(parts, " ")
end

--- LSP progress component using vim.lsp.status() (Neovim 0.12+).
--- Shows active LSP progress messages (e.g., indexing, loading workspace).
local function lsp_status()
  if not vim.lsp.status then
    return ""
  end
  local s = vim.lsp.status()
  if not s or s == "" then
    return ""
  end
  -- Truncate long progress messages to keep statusline clean
  if #s > 40 then
    s = s:sub(1, 37) .. "..."
  end
  return "󰄾 " .. s
end

local has_diagnostic_status = vim.diagnostic.status ~= nil
local has_lsp_status = vim.lsp.status ~= nil

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    local diagnostics_component = has_diagnostic_status and {
      diagnostic_status,
      color = { fg = "#c8d3f5" },
    } or "diagnostics"

    local lsp_status_component = has_lsp_status and {
      lsp_status,
      color = { fg = "#7aa2f7" },
    } or nil

    require("lualine").setup({
      options = {
        theme = "tokyonight",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          diagnostics_component,
        },
        lualine_c = {
          {
            function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            end,
            icon = "📁",
          },
          "filename",
          lsp_status_component,
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "trouble" },
    })
  end,
}
