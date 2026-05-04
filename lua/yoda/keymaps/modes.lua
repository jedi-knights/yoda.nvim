local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Keep cursor vertically centered while scrolling and moving through search results.
-- Without zz the view jumps as the cursor approaches the top/bottom edge, which
-- makes it harder to track context. nzzzv / Nzzzv also set the jumplist mark so
-- <C-o>/<C-i> still work correctly.
map({ "n", "x" }, "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map({ "n", "x" }, "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

map("v", "<leader>r", ":s/", { desc = "Visual: Replace" })
map("v", "<leader>y", '"+y', { desc = "Visual: Yank to clipboard" })
map("v", "<leader>d", '"_d', { desc = "Visual: Delete to void register" })
map("v", "<leader>p", "_dP", { desc = "Visual: Delete and paste over" })

-- jk → <Esc> intentionally removed: it caused a 300ms stall on every 'j'
-- typed in insert mode while Neovim waited to see if 'k' would follow.
-- Use <C-[> (equivalent to Escape) or the physical Escape key instead.

map("n", "<up>", "<nop>", { desc = "Disabled: Use k - Arrow keys disabled to encourage hjkl" })
map("n", "<down>", "<nop>", { desc = "Disabled: Use j - Arrow keys disabled to encourage hjkl" })
map("n", "<left>", "<nop>", { desc = "Disabled: Use h - Arrow keys disabled to encourage hjkl" })
map("n", "<right>", "<nop>", { desc = "Disabled: Use l - Arrow keys disabled to encourage hjkl" })
map("n", "<pageup>", "<nop>", { desc = "Disabled: Use <C-u> - Page keys disabled for half-page scrolling" })
map("n", "<pagedown>", "<nop>", { desc = "Disabled: Use <C-d> - Page keys disabled for half-page scrolling" })
