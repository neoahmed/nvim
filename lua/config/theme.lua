local M = {}

local theme_file = vim.fn.stdpath("config") .. "/lua/config/saved_theme"

-- list of themes: { colorscheme_name, lualine_theme }
local themes = {
  { "gruvbox-material", "gruvbox-material" },
  { "catppuccin", "catppuccin" },
}

local current_theme_index = 1

local function safe_pcall(fn, ...)
  local ok, res = pcall(fn, ...)
  if ok then return res end
  return nil
end

function M.load_theme()
  local file = io.open(theme_file, "r")
  if file then
    local colorscheme = file:read("*l")
    local lualine_theme = file:read("*l")
    file:close()

    if colorscheme and colorscheme ~= "" then
      safe_pcall(vim.cmd.colorscheme, colorscheme)
    end

    -- if saved lualine theme is missing, fall back to colorscheme name
    if lualine_theme and lualine_theme ~= "" then
      safe_pcall(require("lualine").setup, { options = { theme = lualine_theme } })
    elseif colorscheme and colorscheme ~= "" then
      safe_pcall(require("lualine").setup, { options = { theme = colorscheme } })
    end
  else

    -- fallback if no saved theme file
    local colorscheme, lualine = unpack(themes[current_theme_index])
    pcall(vim.cmd.colorscheme, colorscheme)
    pcall(require("lualine").setup, { options = { theme = lualine } })
  end
end

function M.switch_theme()
  current_theme_index = current_theme_index % #themes + 1
  local colorscheme, lualine = unpack(themes[current_theme_index])

  pcall(vim.cmd.colorscheme, colorscheme)
  pcall(require("lualine").setup, { options = { theme = lualine } })

  local file = io.open(theme_file, "w")
  if file then
    file:write(colorscheme .. "\n" .. lualine .. "\n")
    file:close()
  end

  vim.notify("Switched to " .. colorscheme, vim.log.levels.INFO)
end

return M


