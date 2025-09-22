-- nvim/init.lua
-- measure startup time
vim.g.start_time = vim.fn.reltime()

-- faster Lua module loader (Neovim 0.9+)
if vim.loader then
  vim.loader.enable()
end

require("config.lazy")

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- override indent for lua files to use 2 spaces
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})


