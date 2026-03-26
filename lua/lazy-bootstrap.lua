-- lua/lazy-bootstrap.lua
-- Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("[yoda] Failed to clone lazy.nvim — check network/git", vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)
