return {
	-- LSP servers and clients are able to communicate to each other what features they support.
	--  By default, Neovim doesn't support everything that is in the LSP specification.
	--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
	--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
	{
		"hrsh7th/nvim-cmp",
		lazy = false,
		priority = 100,
		specialization = "Completion engine for neovim",
		opts = {
			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				-- By default, you may press `<c-space>` to show the documentation.
				-- Optionally, set `auto_show = true` to show the documentation after a delay.
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "luasnip" },

			-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
			-- which automatically downloads a prebuilt binary when enabled.
			--
			-- By default, we use the Lua implementation instead, but you may enable
			-- the rust implementation via `'prefer_rust_with_warning'`
			--
			-- See :h blink-cmp-config-fuzzy for more information
			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true },
		},

		config = function(_, opts)
			-- Prefer user's original completion file if present
			local ok, _ = pcall(require, "custom.completion")
			if ok then
				return
			end

			-- Fallback minimal setup (safe, self-contained)
			local ok_cmp, cmp = pcall(require, "cmp")
			if not ok_cmp then
				return
			end

			local ok_luasnip, luasnip = pcall(require, "luasnip")
			local types
			if ok_luasnip then
				types = require("luasnip.util.types")
				luasnip.config.setup({
					ext_opts = {
						[types.choiceNode] = { active = { virt_text = { { "⇥", "GruvboxRed" } } } },
						[types.insertNode] = { active = { virt_text = { { "⇥", "GruvboxBlue" } } } },
					},
				})
			end

			local ok_lspkind, lspkind = pcall(require, "lspkind")

			local function luasnip_jumpable_forward()
				if not ok_luasnip then
					return false
				end
				if type(luasnip.locally_jumpable) == "function" then
					return luasnip.locally_jumpable(1)
				elseif type(luasnip.jumpable) == "function" then
					return luasnip.jumpable(1)
				end
				return false
			end
			local function luasnip_jumpable_back()
				if not ok_luasnip then
					return false
				end
				if type(luasnip.locally_jumpable) == "function" then
					return luasnip.locally_jumpable(-1)
				elseif type(luasnip.jumpable) == "function" then
					return luasnip.jumpable(-1)
				end
				return false
			end
			local function luasnip_jump_forward()
				if not ok_luasnip then
					return
				end
				if type(luasnip.jump) == "function" then
					luasnip.jump(1)
				elseif type(luasnip.expand_or_jump) == "function" then
					luasnip.expand_or_jump()
				end
			end
			local function luasnip_jump_back()
				if not ok_luasnip then
					return
				end
				if type(luasnip.jump) == "function" then
					luasnip.jump(-1)
				end
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						if ok_luasnip and type(luasnip.lsp_expand) == "function" then
							luasnip.lsp_expand(args.body)
						end
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					["<C-n>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-p>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-k>"] = cmp.mapping(function(fallback)
						if luasnip_jumpable_forward() then
							luasnip_jump_forward()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-j>"] = cmp.mapping(function(fallback)
						if luasnip_jumpable_back() then
							luasnip_jump_back()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
				}),
				formatting = (ok_lspkind and {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 70,
						show_labelDetails = true,
					}),
				}) or nil,
			})

			local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp_nvim_lsp then
				local caps = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
				_G.__CMP_DEFAULT_CAPABILITIES = caps
			end

			cmp.setup(opts)
		end,
	},

	{
		"neovim/nvim-lspconfig",
		specialization = "LSP configuration (used by completion for capabilities)",
	},

	{
		"onsails/lspkind-nvim",
		specialization = "Completion item pictograms",
	},

	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		specialization = "Snippet engine (source and expansion)",
		config = function()
			local ok, loader = pcall(require, "luasnip.loaders.from_vscode")
			if ok and loader and loader.lazy_load then
				loader.lazy_load()
			end
		end,
	},

	{
		"saadparwaiz1/cmp_luasnip",
		enabled = true,
		specialization = "cmp source for LuaSnip (supply nvimcmp with list of possible snippets)",
	},

	{
		--    See the README about individual language/framework/plugin snippets:
		--    https://github.com/rafamadriz/friendly-snippets
		"rafamadriz/friendly-snippets",
		specialization = "Premade snippets (vscode like)",
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		specialization = "nvim-cmp LSP capabilities helper (cmp reports layer)",
	},
}
