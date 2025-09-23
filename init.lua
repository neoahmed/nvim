-- nvim/init.lua
require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.mappings")
---- load colorscheme
require("config.theme").load_theme()

