-- nvim/init.lua
vim.opt.runtimepath:append("/home/ahmed/.config/nvim")
require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.mappings")
---- load colorscheme
require("config.theme").load_theme()

