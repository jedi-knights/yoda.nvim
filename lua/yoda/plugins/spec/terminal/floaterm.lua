-- Floating terminal
return {
  'voldikss/vim-floaterm',
  lazy = false, -- ensure it's loaded immediately
  init = function()
    vim.g.floaterm_keymap_new    = '<F7>'
    vim.g.floaterm_keymap_prev   = '<F8>'
    vim.g.floaterm_keymap_next   = '<F9>'
    vim.g.floaterm_keymap_toggle = '<F12>'
  end,
  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'python',
      callback = function()
        vim.api.nvim_set_keymap('i', '<leader>tr', '<ESC>:w<CR>:FloatermNew --autoclose=0 python3 %<CR>', { noremap = true, silent = true })
      end
    })
  end
}

