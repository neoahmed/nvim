return {
	-- Catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				styles = {
					cmp = true,
					telescope = true,
					sidebars = "transparent",
					floats = "transparent",
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Gruvbox Material
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.termguicolors = true
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_enable_bold = 1
			vim.g.gruvbox_material_enable_italic = 1
			vim.g.gruvbox_material_transparent_background = 0
			vim.g.gruvbox_material_better_performance = 1
		end,
	},
}
