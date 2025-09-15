-- Ref: https://github.com/nvim-tree/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional for file icons

  keys = {
    { "<leader>t", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
  },

  config = function()
    -- disable netrw at the very start
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- enable 24-bit color
    vim.opt.termguicolors = true

    -- setup with defaults
    require("nvim-tree").setup()

  end,
}

