-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- nvim/lua/config/mappings.lua
local function map(m, k, v, desc)
	vim.keymap.set(m, k, v, { noremap = true, silent = true, desc = desc })
end

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- Diagnostic keymaps
map("n", "<leader>dq", vim.diagnostic.setloclist, "Open [D]iagnostic [Q]uickfix list")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")

-- TIP: Disable arrow keys in normal mode
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', "Block left")
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', "Block right")
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', "Block up")
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', "Block down")

-- visual mode
map("v", "<left>", '<cmd>echo "Use h to move!!"<CR>', "Block left")
map("v", "<right>", '<cmd>echo "Use l to move!!"<CR>', "Block right")
map("v", "<up>", '<cmd>echo "Use k to move!!"<CR>', "Block up")
map("v", "<down>", '<cmd>echo "Use j to move!!"<CR>', "Block down")

-- insert mode
-- map('i', '<left>',  '<cmd>echo "Use h to move!!"<CR>', "Block left"  )
-- map('i', '<right>', '<cmd>echo "Use l to move!!"<CR>', "Block right" )
-- map('i', '<up>',    '<cmd>echo "Use k to move!!"<CR>', "Block up"    )
-- map('i', '<down>',  '<cmd>echo "Use j to move!!"<CR>', "Block down"  )

----------- keymap to switch colorscheme
map("n", "<leader>cs", "<cmd>SwitchColorscheme<cr>", "Switch colorscheme")

---- keypam to execute
map("n", "<space><space>x", "<cmd>source %<CR>", "Source current file")
map("n", "<space>x", ":.lua<CR>", "Run current line Lua")
map("v", "<space>x", ":lua<CR>", "Run selection Lua")

-- Buffers
---- Move to previous/next
map("n", "<S-l>", ":BufferNext<CR>", "Next buffer")
map("n", "<S-h>", ":BufferPrevious<CR>", "Prev buffer")
---- Re-order to previous/next
map("n", "<C-S-l>", ":BufferMoveNext<CR>", "Move buffer to right")
map("n", "<C-S-h>", ":BufferMovePrevious<CR>", "Move buffer to left")
---- Close buffers
map("n", "<leader>cb", ":BufferClose<CR>", "[C]lose [B]uffer")
map("n", "<leader>cB", ":BufferClose!<CR>", "[C]lose [B]uffer (Force)")
map("n", "<leader>cA", ":bufdo bd<CR>", "[C]lose [A]ll buffers")
map("n", "<leader>ca", ":BufferCloseAllButCurrent<CR>", "[C]lose [A]ll but current")

-- Buffer navigation
map("n", "<C-1>", ":BufferGoto 1<CR>", "Go to buffer 1")
map("n", "<C-2>", ":BufferGoto 2<CR>", "Go to buffer 2")
map("n", "<C-3>", ":BufferGoto 3<CR>", "Go to buffer 3")
map("n", "<C-4>", ":BufferGoto 4<CR>", "Go to buffer 4")
map("n", "<C-5>", ":BufferGoto 5<CR>", "Go to buffer 5")
map("n", "<C-6>", ":BufferGoto 6<CR>", "Go to buffer 6")
map("n", "<C-7>", ":BufferGoto 7<CR>", "Go to buffer 7")
map("n", "<C-8>", ":BufferGoto 8<CR>", "Go to buffer 8")
map("n", "<C-9>", ":BufferGoto 9<CR>", "Go to buffer 9")
map("n", "<C-0>", ":BufferLast<CR>", "Go to last buffer")
---- Pin/unpin buffer
map("n", "<C-S-p>", ":BufferPin<CR>", "Pin buffer")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", "Move focus to the left window")
map("n", "<C-l>", "<C-w><C-l>", "Move focus to the right window")
map("n", "<C-j>", "<C-w><C-j>", "Move focus to the lower window")
map("n", "<C-k>", "<C-w><C-k>", "Move focus to the upper window")

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", "Move window to the left"  )
-- map("n", "<C-S-l>", "<C-w>L", "Move window to the right" )
-- map("n", "<C-S-j>", "<C-w>J", "Move window to the lower" )
-- map("n", "<C-S-k>", "<C-w>K", "Move window to the upper" )

-- Quickfix
map("n", "<leader>qo", "<cmd>copen<CR>", "[Q]uickfix [O]pen")
map("n", "<leader>qc", "<cmd>cclose<CR>", "[Q]uickfix [C]lose")
map("n", "<leader>qj", "<cmd>cnext<CR>", "Next quickfix item")
map("n", "<leader>qk", "<cmd>cprev<CR>", "Previous quickfix item")
map("n", "<leader>qG", "<cmd>clast<CR>", "Last quickfix item")
map("n", "<leader>qgg", "<cmd>cfirst<CR>", "First quickfix item")

-- Misc
-- map("n", "<leader>zl", ":Twilight<CR>", "Toggle Twilight")
-- map("n", "<leader>zz", ":ZenMode<CR>", "Toggle Zen Mode")
map("n", "<leader>zz", function()
	require("zen-mode").setup({
		window = {
			width = 90,
			options = {},
		},
	})
	require("zen-mode").toggle()
	vim.wo.wrap = false
	vim.wo.number = true
	vim.wo.rnu = true
end, "Toggle zen Mode")

map("n", "<leader>zZ", function()
	require("zen-mode").setup({
		window = {
			width = 80,
			options = {},
		},
	})
	require("zen-mode").toggle()
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.rnu = false
	vim.opt.colorcolumn = "0"
end, "Toggle ZEN Mode")

-- Delete behavior
---- Normal + Visual delete goes to black-hole
map({ "n", "x" }, "d", '"_d', "Delete")
map("n", "dd", '"_dd', "Delete")
map("n", "D", '"_D', "Delete till end of line")

-- Line numbers
-- map("n", "<leader>nn",
--   function()
--     if vim.wo.relativenumber then
--       vim.wo.relativenumber = false
--       vim.wo.number         = true
--     else
--       vim.wo.relativenumber = true
--     end
--   end,
--   "Toggle relative line numbers"
-- )
