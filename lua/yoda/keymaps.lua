-- lua/yoda/core/keymaps.lua

local kmap = require("yoda.utils.keymap_logger")
local job_id = 0

-- general keymaps

-- Reload neovim config
kmap.set("n", "<leader><leader>r", function()
  -- Unload your plugin/config namespace so it can be re-required
  for name, _ in pairs(package.loaded) do
    if name:match("^yoda") then -- or your namespace prefix
      package.loaded[name] = nil
    end
  end

  -- Reload your plugin spec file (if using `import = "yoda.plugins.spec"`)
  require("yoda")

  -- Defer notify so that `vim.notify` has a chance to be overridden again
  vim.defer_fn(function()
    vim.notify("✅ Reloaded yoda plugin config", vim.log.levels.INFO)
  end, 100)
end, { desc = "Hot reload Yoda plugin config" })

local showkeys_enabled = false

-- Toggle ShowKeys plugin
kmap.set("n", "<leader>kk", function()
  local ok, showkeys = pcall(require, "showkeys")
  if not ok then
    require("lazy").load({ plugins = { "showkeys" } })
    ok, showkeys = pcall(require, "showkeys")
  end
  if ok and showkeys then
    showkeys.toggle()
    showkeys_enabled = not showkeys_enabled

    if showkeys_enabled then
      vim.notify("✅ ShowKeys enabled", vim.log.levels.INFO)
    else
      vim.notify("🚫 ShowKeys disabled", vim.log.levels.INFO)
    end
  else
    vim.notify("❌ Failed to load showkeys plugin", vim.log.levels.ERROR)
  end
end, { desc = "Toggle ShowKeys" })

-- run tests
kmap.set("n", "<leader>tp", function()
  require("yoda.testpicker").run()
end, { desc = "run tests with yoda" })

-- toggle terminal at bottom
kmap.set("n", "<leader>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("j")
  vim.api.nvim_win_set_height(0, 5)
  job_id = vim.opt.channel
  vim.cmd("startinsert!") -- 👈 auto-enter insert mode after terminal opens
end, { desc = "open bottom terminal" })

kmap.set("n", "<leader>sc", function()
  vim.fn.chansend(job_id, { "echo 'hi'\r\n" })
end, { desc = "send command to terminal" })
-- windows
-- split
kmap.set("n", "<leader>|", ":vsplit<cr>", { desc = "vertical split" })
kmap.set("n", "<leader>-", ":split<cr>", { desc = "horizontal split" })
kmap.set("n", "<leader>se", "<c-w>=", { desc = "equalize window sizes" })
kmap.set("n", "<leader>sx", ":close<cr>", { desc = "close current split" })

-- window navigation
kmap.set("n", "<c-h>", "<c-w>h", { desc = "move to left window" })
kmap.set("n", "<c-j>", "<c-w>j", { desc = "move to lower window" })
kmap.set("n", "<c-k>", "<c-w>k", { desc = "move to upper window" })
kmap.set("n", "<c-l>", "<c-w>l", { desc = "move to right window" })
kmap.set("n", "<c-c>", "<c-w>c", { desc = "close window" })

-- tab navigation
kmap.set("n", "<c-t>", vim.cmd.tabnew, { desc = "new tab" })
kmap.set("n", "<c-w>", vim.cmd.tabclose, { desc = "close tab" })
kmap.set("n", "<c-p>", vim.cmd.tabprevious, { desc = "previous tab" })
kmap.set("n", "<c-n>", vim.cmd.tabnext, { desc = "next tab" })

-- buffer navigation
kmap.set("n", "<s-left>", vim.cmd.bprevious, { desc = "previous buffer" })
kmap.set("n", "<s-right>", vim.cmd.bnext, { desc = "next buffer" })
kmap.set("n", "<s-down>", vim.cmd.buffers, { desc = "list buffers" })
kmap.set("n", "<s-up>", ":buffer ", { desc = "switch to buffer" })
kmap.set("n", "<s-del>", vim.cmd.bdelete, { desc = "delete buffer" })

-- window resizing
kmap.set("n", "<m-left>", ":vertical resize -2<cr>", { desc = "shrink window width" })
kmap.set("n", "<m-right>", ":vertical resize +2<cr>", { desc = "expand window width" })
kmap.set("n", "<m-up>", ":resize -1<cr>", { desc = "shrink window height" })
kmap.set("n", "<m-down>", ":resize +1<cr>", { desc = "expand window height" })

-- save/quit
kmap.set("n", "<c-s>", ":w<cr>", { desc = "save file" })
kmap.set("n", "<c-q>", ":wq<cr>", { desc = "save and quit" })
kmap.set("n", "<c-x>", ":bd<cr>", { desc = "close buffer" })

-- visual mode improvements
kmap.set("v", "j", ":m '>+1<cr>gv=gv", { desc = "move selection down" })
kmap.set("v", "k", ":m '<-2<cr>gv=gv", { desc = "move selection up" })
kmap.set("x", "j", ":move '>+1<cr>gv-gv", { desc = "move block down" })
kmap.set("x", "k", ":move '<-2<cr>gv-gv", { desc = "move block up" })

-- exit terminal mode
kmap.set("t", "<esc>", "<c-\\><c-n>", { desc = "exit terminal mode" })

-- clipboard/yank
kmap.set("n", "<leader>y", ":%y+<cr>", { desc = "yank buffer to system clipboard" })

-- disable macro recording
kmap.set("n", "q", "<nop>", { desc = "disable q" })

-- fast mode exits
kmap.set("i", "jk", "<esc>", { noremap = true, silent = true, desc = "exit insert mode" })
kmap.set("v", "jk", "<esc>", { noremap = true, silent = true, desc = "exit visual mode" })

-- re-indent whole file
kmap.set("n", "<leader>i", "gg=g", { desc = "re-indent entire file" })

-- buffer management
kmap.set("n", "<leader>bq", function()
  local api = vim.api
  local cur_buf = api.nvim_get_current_buf()
  local alt_buf = vim.fn.bufnr("#")
  if vim.bo[alt_buf].filetype ~= "neo-tree" and vim.bo[alt_buf].buflisted then
    api.nvim_set_current_buf(alt_buf)
  else
    vim.cmd("bnext")
  end
  vim.cmd("bd " .. cur_buf)
end, { desc = "close buffer and switch" })

kmap.set("n", "<leader>bo", function()
  vim.cmd("%bd | e# | bd#")
end, { desc = "close others" })
kmap.set("n", "<leader>bd", ":bufdo bd<cr>", { desc = "delete all buffers" })

-- neo-tree (grouped under <leader>e)
kmap.set("n", "<leader>nt", function()
  vim.cmd("neotree toggle")
end, { desc = "toggle neotree" })

kmap.set("n", "<leader>nc", ":neotree close<cr>", { desc = "close neotree" })

vim.keymap.set("n", "<leader>nf", function()
  require("neo-tree.command").execute({ action = "focus" })
end, { desc = "Focus Neo-tree" })

-- telescope mappings (grouped)
kmap.set("n", "<leader>ff", function()
  local builtin = require("telescope.builtin")
  builtin.find_files()
end, { desc = "find files" })

kmap.set("n", "<leader>fb", function()
  local builtin = require("telescope.builtin")
  builtin.buffers()
end, { desc = "find buffers" })

kmap.set("n", "<leader>fr", function()
  local builtin = require("telescope.builtin")
  builtin.registers()
end, { desc = "find registers" })

kmap.set("n", "<leader>fg", function()
  local builtin = require("telescope.builtin")
  builtin.live_grep()
end, { desc = "search grep" })

kmap.set("n", "<leader>sw", function()
  local builtin = require("telescope.builtin")
  builtin.grep_string()
end, { desc = "search word under cursor" })

kmap.set("n", "<leader>sh", function()
  local builtin = require("telescope.builtin")
  builtin.search_history()
end, { desc = "search history" })

kmap.set("n", "<leader>hh", function()
  local builtin = require("telescope.builtin")
  builtin.help_tags()
end, { desc = "help tags" })

kmap.set("n", "<leader>hc", function()
  local builtin = require("telescope.builtin")
  builtin.commands()
end, { desc = "command palette" })

-- quit all
kmap.set("n", "<leader>qq", ":qa<cr>", { desc = "quit neovim" })

-- copilot keymaps
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local kmap = require("yoda.utils.keymap_logger")

    kmap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {
      expr = true,
      silent = true,
      desc = "Copilot Accept",
    })

    kmap.set("i", "<C-k>", 'copilot#Dismiss()', {
      expr = true,
      silent = true,
      desc = "Copilot Dismiss",
    })

    kmap.set("i", "<C-Space>", 'copilot#Complete()', {
      expr = true,
      silent = true,
      desc = "Copilot Complete",
    })
  end,
})

kmap.set("n", "<leader>cp", function()
  -- Ensure the plugin is loaded (if lazy-loaded)
  require("lazy").load({ plugins = { "copilot.vim" } })

  -- Now it's safe to call VimL functions
  local status_ok, is_enabled = pcall(vim.fn["copilot#IsEnabled"])
  if not status_ok then
    vim.notify("❌ Copilot is not available", vim.log.levels.ERROR)
    return
  end

  if is_enabled == 1 then
    vim.cmd("Copilot disable")
    vim.notify("🚫 Copilot disabled", vim.log.levels.INFO)
  else
    vim.cmd("Copilot enable")
    vim.notify("✅ Copilot enabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Copilot" })

-- floaterm keymaps
kmap.set("n", "<leader>tr", ":w<cr>:floattermnew --autoclose=0 python3 %<cr>",
  { noremap = true, silent = true, desc = "run python in floaterm" })
kmap.set("n", "<leader>tt", function()
  require("yoda.terminals").open_sourced_terminal()
end, { desc = "Open floating terminal with venv support", silent = true })
vim.keymap.set("n", "<leader>tx", ":FloatermKill<CR>", { desc = "Kill Floating Terminal", silent = true })
