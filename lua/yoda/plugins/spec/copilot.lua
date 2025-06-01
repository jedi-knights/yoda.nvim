return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    -- Disable default `<Tab>` maping
    vim.g.copilot_no_tab_map = true

    -- Optional: Customize Copilot behavior
    vim.g.copilot_filetypes = {
      ["*"] = true, -- Enable Copilot for all filetypes
      ["markdown"] = false, -- Disable Copilot for Markdown files
      ["text"] = false, -- Disable Copilot for plain text files
    }

    -- Create a :CopilotToggle command
    vim.api.nvim_create_user_command("CopilotToggle", function()
      local copilot_status = vim.g.copilot_enabled
      if copilot_status == 1 then
        vim.cmd("Copilot disable")
        print("Copilot disabled")
      else
        vim.cmd("Copilot enable")
        print("Copilot enabled")
      end
    end, { desc = "Toggle Copilot" })
  end
}


