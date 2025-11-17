local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local large_file = require("yoda.large_file")
local filetype_detection = require("yoda.filetype.detection")
local terminal_autocmds = require("yoda-terminal.autocmds")
local performance_autocmds = require("yoda.performance.autocmds")
local yoda_autocmds = require("yoda.autocmds")

local function create_autocmd(events, opts)
  opts.group = opts.group or augroup("YodaAutocmd", { clear = true })
  autocmd(events, opts)
end

filetype_detection.setup_all(autocmd, augroup)

create_autocmd("BufReadPre", {
  group = augroup("YodaLargeFile", { clear = true }),
  desc = "Detect and optimize for large files",
  callback = function(args)
    large_file.on_buf_read(args.buf)
  end,
})

terminal_autocmds.setup_all(autocmd, augroup)

performance_autocmds.setup_all(autocmd, augroup)

yoda_autocmds.setup_all()

yoda_autocmds.setup_commands()
