-- nvim/lua/config/autocmd.lua
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

local augroup = vim.api.nvim_create_augroup

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight text when yanking",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- Toggle relative numbers automatically
local num_group = augroup("relative-number-toggle", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
  desc = "Enable relative number when active and not in insert mode",
  group = num_group,
  pattern = "*",
  callback = function()
    if vim.o.number and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
  desc = "Disable relative number when inactive or in insert mode",
  group = num_group,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.opt.relativenumber = false
      if not vim.tbl_contains({ "@", "-" }, vim.v.event.cmdtype or "") then
        vim.cmd("redraw")
      end
    end
  end,
})

-- Disable automatic comment on newline
vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable automatic comment insertion on newline",
  group = augroup("disable-auto-comment", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})


-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restore last cursor position when reopening a file",
  group = augroup("restore-cursor", { clear = true }),
  pattern = "*",
  callback = function()
    local line = vim.fn.line([['"]])
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})
