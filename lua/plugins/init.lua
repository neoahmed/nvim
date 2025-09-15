-- nvim/lua/plugins/init.lua
-- Aggregate plugin specs returned by files in lua/plugins/*.lua
local M = {}

-- Order matters sometimes (colorscheme first).
local enabled = {
  -- "pluginfile"
}

for _, mod in ipairs(enabled) do
  local ok, res = pcall(require, "plugins." .. mod)
  if not ok then
    vim.notify("Failed to require plugins." .. mod .. ": " .. tostring(res), vim.log.levels.WARN)
  else
    -- if module returned a list of specs, append them
    if type(res) == "table" then
      for _, spec in ipairs(res) do
        table.insert(M, spec)
      end
    else
      -- if module returned a single spec, just insert it
      table.insert(M, res)
    end
  end
end

return M
