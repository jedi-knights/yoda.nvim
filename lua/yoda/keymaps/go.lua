-- lua/yoda/keymaps/go.lua
-- Go-specific keymaps

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Set up Go-specific keymaps only for Go files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Smart Enter for Go: manually handle indentation after {
    map("i", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local col = cursor[2]

      -- Get text before cursor
      local before_cursor = line:sub(1, col)

      -- If line ends with {, add indented newline
      if before_cursor:match("{%s*$") then
        local current_indent = before_cursor:match("^(%s*)")
        local new_indent = current_indent .. string.rep(" ", 4)

        -- Insert newline with proper indentation
        vim.api.nvim_put({ "", new_indent }, "c", true, true)

        -- Position cursor at end of indented line
        vim.schedule(function()
          local new_cursor = vim.api.nvim_win_get_cursor(0)
          vim.api.nvim_win_set_cursor(0, { new_cursor[1], #new_indent })
        end)
      else
        -- Normal Enter behavior
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      end
    end, { buffer = bufnr, desc = "Smart Enter with Go indentation" })

    -- Quick format on save
    map("n", "<leader>gf", function()
      vim.cmd("silent! %!gofmt")
    end, { buffer = bufnr, desc = "Format Go file with gofmt" })

    -- Quick build
    map("n", "<leader>gb", function()
      vim.cmd("!go build")
    end, { buffer = bufnr, desc = "Build Go project" })

    -- Quick run
    map("n", "<leader>gr", function()
      vim.cmd("!go run " .. vim.fn.expand("%"))
    end, { buffer = bufnr, desc = "Run current Go file" })
  end,
})
