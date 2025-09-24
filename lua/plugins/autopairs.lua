return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    disable_in_macro = true,  -- disable when recording or executing a macro
    disable_in_visualblock = false,  -- disable when insert after visual block mode
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    enable_moveright = true,
    enable_afterquote = true,  -- add bracket pairs after quote
    enable_check_bracket_line = true,  --- check bracket in same line
    enable_bracket_in_quote = true,  -- trigger abbreviation
    enable_abbr = false,  -- switch for basic rule break undo sequence
    break_undo = true,
    check_ts = true,
    map_cr = true,
    map_bs = true,  -- map the <BS> key
    map_c_h = false,  -- Map the <C-h> key to delete a pair
    map_c_w = false,  -- map <c-w> to delete a pair if possible
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    autopairs.setup(opts)
    -- Debug: Print rules after setup to verify
    -- print(vim.inspect(autopairs.state.rules))
  end,
}
