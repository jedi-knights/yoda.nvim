return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    -- Disable default `<Tab>` mapping
    vim.g.copilot_no_tab_map = true

    -- Map `<C-J>` to accept Copilot suggestions
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

    -- Optional: Customize Copilot behavior
    vim.g.copilot_filetypes = {
      ["*"] = true, -- Enable Copilot for all filetypes
      ["markdown"] = false, -- Disable Copilot for Markdown files
      ["text"] = false, -- Disable Copilot for plain text files
    }

    -- Copilot Keymaps
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true, desc = "Accept Copilot suggestion" })
    vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Dismiss()', { silent = true, expr = true, desc = "Dismiss Copilot suggestion" })
    vim.api.nvim_set_keymap("i", "<C-Space>", 'copilot#Complete()', { silent = true, expr = true, desc = "Trigger Copilot completion" })


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

    -- Toggle keymap
    vim.keymap.set("n", "<leader>cp", ":CopilotToggle<CR>", { desc = "Toggle Copilot" })
  end
}


