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

-- ensure truecolor
vim.opt.termguicolors = true

-- Redefine *TS groups after applying colorscheme
local function set_ts_highlights()
  pcall(function()
    local hl = vim.api.nvim_set_hl
    local links = {
      TSKeyword     = { link = "Keyword" },
      TSFunction    = { link = "Function" },
      TSVariable    = { link = "Identifier" },
      TSString      = { link = "String" },
      TSComment     = { link = "Comment" },
      TSNumber      = { link = "Number" },
      TSConditional = { link = "Conditional" },
      TSRepeat      = { link = "Repeat" },
      TSOperator    = { link = "Operator" },
      TSParameter   = { link = "Identifier" },
      TSField       = { link = "Identifier" },
      TSProperty    = { link = "Identifier" },
      TSKeywordFunction = { link = "Function" },
      TSConstructor = { link = "Special" },
      TSNamespace   = { link = "Namespace" },
    }

    for group, opts in pairs(links) do
      hl(0, group, opts)
    end
  end)
end

-- apply after any colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_ts_highlights,
  desc = "Reapply TS highlights after colorscheme change",
})

function M.load_theme()
  local file = io.open(theme_file, "r")
  if file then
    local colorscheme = file:read("*l")
    local lualine_theme = file:read("*l")
    file:close()

    if colorscheme and colorscheme ~= "" then
      safe_pcall(vim.cmd.colorscheme, colorscheme)
      -- update index to match saved scheme
      for i, t in ipairs(themes) do
        if t[1] == colorscheme then
          current_theme_index = i
          break
        end
      end
    end

    if lualine_theme and lualine_theme ~= "" then
      safe_pcall(require("lualine").setup, { options = { theme = lualine_theme } })
    elseif colorscheme and colorscheme ~= "" then
      safe_pcall(require("lualine").setup, { options = { theme = colorscheme } })
    end
  else
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

-- expose set_ts_highlights for manual use
M.set_ts_highlights = set_ts_highlights

-- switch theme command wrapper
vim.api.nvim_create_user_command("SwitchColorscheme", function()
  require("config.theme").switch_theme()
end, { desc = "Switch colorscheme" })

return M
