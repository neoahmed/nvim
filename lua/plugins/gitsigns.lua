-- ███ Gitsigns Keymaps Cheatsheet ███
-- <leader>hj  → move to next hunk
-- <leader>hk  → move to previous hunk
-- <leader>hs  → Stage hunk (index)
-- <leader>hr  → Reset hunk (to the latest version in git)
-- <leader>hu  → Undo stage hunk
-- <leader>hp  → Preview hunk (show diff in popup)
-- <leader>hS  → Stage buffer
-- <leader>hR  → Reset buffer
-- <leader>hd  → Diff against index
-- <leader>hD  → Diff with latest commit
-- <leader>hb  → Blame line (hunk author)
-- <leader>tb  → Toggle inline blame
-- <leader>hK  → Toggle deleted preview

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- optional config
    signs = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged_enable = true,
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      follow_files = true
    },
    auto_attach = true,
    attach_to_untracked = false,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
      -- Options passed to nvim_open_win
      border = 'single',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },

    -- keymaps
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "<leader>hk", function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      map("n", "<leader>hj", function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          gs.nav_hunk("prev")
        end
      end, "Prev hunk")

      -- Actions (visual)
      map("v", "<leader>hs", function()
        gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
      end, "Stage hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
      end, "Reset hunk")

      -- Actions (normal)
      map("n", "<leader>hs", gs.stage_hunk,                "Stage hunk (toggles)")
      -- map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hr", gs.reset_hunk,          "[R]eset hunk")
      map("n", "<leader>hS", gs.stage_buffer,        "[S]tage buffer")
      map("n", "<leader>hR", gs.reset_buffer,        "[R]eset buffer")
      map("n", "<leader>hp", gs.preview_hunk,        "[P]review hunk")
      map('n', '<leader>hi', gs.preview_hunk_inline, "[P]review hunk [I]nline")
      map("n", "<leader>hd", gs.diffthis,            "[D]iff against index")
      map("n", "<leader>hb", function()                
        gs.blame_line({ full = true }) end,          "[B]lame line")
      map("n", "<leader>hD", function()                
        gs.diffthis("@") end,                        "[D]iff against last commit")

      map('n', '<leader>hq', gs.setqflist,           "[Q]uickfix unstaged hunks")

      map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, "[Q]uickfix all hunks")
      
      -- Toggles
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame line")
      map("n", "<leader>hJ", gs.preview_hunk_inline,       "Toggle deleted preview")
      
      -- Text object
      map({'o', 'x'}, 'ih', gs.select_hunk, "Select Git hunk (text object)")
    end,
  },
}
