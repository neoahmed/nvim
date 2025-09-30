return {
	-- Install LSPs and related tools to stdpath for Neovim
	-- Mason must be loaded before its dependents so we need to set it up here.
	{
		"williamboman/mason.nvim",
		specialization = "Manage LSP servers and binaries locally in your system",
		config = function()
			if pcall(require, "mason") then
				require("mason").setup()
			end
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		specialization = "Bridge mason-nvim servers <> lspconfig",
		config = function()
			if pcall(require, "mason-lspconfig") then
				require("mason-lspconfig").setup()
			end
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		specialization = "Ensure tools are installed via mason",
		config = function() end,
	},

	-- Brief aside: **What is LSP?**
	--
	-- LSP is an initialism you've probably heard, but might not understand what it is.
	--
	-- LSP stands for Language Server Protocol. It's a protocol that helps editors
	-- and language tooling communicate in a standardized fashion.
	--
	-- In general, you have a "server" which is some tool built to understand a particular
	-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
	-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
	-- processes that communicate with some "client" - in this case, Neovim!
	--
	-- LSP provides Neovim with features like:
	--  - Go to definition
	--  - Find references
	--  - Autocompletion
	--  - Symbol Search
	--  - and more!
	--
	-- Thus, Language Servers are external tools that must be installed separately from
	-- Neovim. This is where `mason` and related plugins come into play.
	--
	-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
	-- and elegantly composed help section, `:help lsp-vs-treesitter`
	{
		"neovim/nvim-lspconfig",
		specialization = "LSP servers configuration for neovim",
		config = function()
			-- early exit if editing Obsidian notes
			if vim.g.obsidian then
				return
			end

			-- helper: safe require
			local function sreq(name)
				local ok, mod = pcall(require, name)
				if not ok then
					return nil
				end
				return mod
			end

			-- helper: extend defaults from lspconfig.configs.<name>.default_config if available.
			-- This mirrors the original `extend` behavior but is safe if lspconfig.configs is absent.
			-- local function extend(name, key, values)
			-- 	local lspconfigs = sreq("lspconfig.configs")
			-- 	if not lspconfigs then
			-- 		return values
			-- 	end
			-- 	local mod = lspconfigs[name]
			-- 	if not mod or not mod.default_config then
			-- 		return values
			-- 	end

			-- 	local default = mod.default_config
			-- 	local keys = vim.split(key, ".", { plain = true })
			-- 	while #keys > 0 do
			-- 		local item = table.remove(keys, 1)
			-- 		if default[item] == nil then
			-- 			default = nil
			-- 			break
			-- 		end
			-- 		default = default[item]
			-- 	end
			-- 	if not default then
			-- 		return values
			-- 	end

			-- 	if vim.islist(default) then
			-- 		for _, value in ipairs(default) do
			-- 			table.insert(values, value)
			-- 		end
			-- 	else
			-- 		for item, value in pairs(default) do
			-- 			if not vim.tbl_contains(values, item) then
			-- 				values[item] = value
			-- 			end
			-- 		end
			-- 	end
			-- 	return values
			-- end

			-- capabilities: prefer cmp_nvim_lsp augment on top of base capabilities
			local base_caps = vim.lsp.protocol.make_client_capabilities()
			local cmp_helper = sreq("cmp_nvim_lsp")
			local capabilities = (cmp_helper and cmp_helper.default_capabilities(base_caps)) or base_caps

			-- require util/helpers from lspconfig if available (used for some root patterns)
			-- local lspconfig = sreq("lspconfig")
			-- local lsp_util = sreq("lspconfig.util")

			-- servers table (study-friendly; one entry per server config)
			local servers = {
				bashls = true,

				gopls = {
					manual_install = true,
					settings = {
						gopls = {
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},

				glsl_analyzer = true,

				lua_ls = {
					cmd = { "lua-language-server" },
				},

				-- pyright = true,

				jsonls = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
					settings = {
						json = {
							schemas = (sreq("schemastore") and require("schemastore").json.schemas()) or nil,
							validate = { enable = true },
						},
					},
				},

				yamlls = {
					settings = {
						yaml = {
							schemaStore = { enable = false, url = "" },
						},
					},
				},

				clangd = {
					init_options = { clangdFileStatus = true },
					filetypes = { "c" },
				},
			}

			-- build list of servers that should be ensured by mason-tool-installer
			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			-- default ensure_installed tools (formatter/debugger + servers)
			local ensure_installed = { "stylua", "lua_ls", "gopls", "clangd", "delve" }
			vim.list_extend(ensure_installed, servers_to_install)

			-- ensure mason and mason-tool-installer are configured (mason setup done elsewhere too)
			local mason = sreq("mason")
			if mason and type(mason.setup) == "function" then
				mason.setup()
			end
			local mti = sreq("mason-tool-installer")
			if mti and type(mti.setup) == "function" then
				mti.setup({ ensure_installed = ensure_installed })
			end

			-- register each server with the built-in vim.lsp.config() API
			local to_enable = {}
			for name, cfg in pairs(servers) do
				if cfg == true then
					cfg = {}
				end
				cfg = vim.tbl_deep_extend("force", {}, { capabilities = capabilities }, cfg)

				-- Use builtin API to register the configuration
				vim.lsp.config(name, cfg)
				table.insert(to_enable, name)
			end

			-- enable all the servers we declared (activates them when filetype/root matches)
			-- you can enable a subset if you prefer.
			vim.lsp.enable(to_enable)

			-- optional: disable semantic tokens for listed filetypes
			local disable_semantic_tokens = {
				-- lua = true,
			}

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local client = assert(vim.lsp.get_client_by_id(event.data.client_id), "must have valid client")
					local _, builtin = pcall(require, "telescope.builtin")
					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("<space>gd", builtin.lsp_definitions, "[G]oto [D]efinition")
					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("<space>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					-- Find references for the word under your cursor.
					map("<space>gr", builtin.lsp_references, "[G]oto [r]eferences")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<space>gt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("<space>gi", builtin.lsp_implementations, "[G]oto [I]mplementation")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<space>gO", builtin.lsp_document_symbols, "Open Document Symbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<space>gW", builtin.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

					map("K", vim.lsp.buf.hover, "Hover")
					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<space>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<space>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "v", "x" })

					vim.keymap.set("n", "<space>ww", function()
						builtin.diagnostics({ root_dir = true })
					end, { buffer = event.buf })

					local filetype = vim.bo[event.buf].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end

					-- Apply any server_capabilities overrides declared in `servers`
					if settings.server_capabilities then
						for k, v in pairs(settings.server_capabilities) do
							if v == vim.NIL then
								v = nil
							end
							client.server_capabilities[k] = v
						end
					end

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Enable inlay hints for all attached LSP clients
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserInlayHints", { clear = true }),
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
				end,
			})

			if pcall(require, "lsp_lines") then
				require("lsp_lines").setup()
			end

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			-- custom autoformat setup (optional; keep safe)
			local autoformat = sreq("custom.autoformat")
			if autoformat and type(autoformat.setup) == "function" then
				autoformat.setup()
			end

			-- lsp_lines & diagnostic defaults
			local lsp_lines = sreq("lsp_lines")
			if lsp_lines and type(lsp_lines.setup) == "function" then
				lsp_lines.setup()
			end
			vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

			-- toggle keymap for switching diagnostics view
			vim.keymap.set("", "<leader>l", function()
				local cfg = vim.diagnostic.config() or {}
				if cfg.virtual_text then
					vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
				else
					vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
				end
			end, { desc = "Toggle lsp_lines" })
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "/usr/share/awesome/lib/", words = { "awesome" } },
			},
		},
		specialization = "Lua runtime / Neovim API docs",
	},

	{
		"Bilal2453/luvit-meta",
		lazy = true,
		specialization = "luvit metadata (types/words for lazydev)",
	},

	-- Useful status updates for LSP.
	{
		"j-hui/fidget.nvim",
		opts = {},
		specialization = "LSP UI progress",
	},

	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		specialization = "Diagnostics rendered as virtual lines",
		config = function()
			if pcall(require, "lsp_lines") then
				require("lsp_lines").setup()
			end
		end,
	},

	{
		"b0o/SchemaStore.nvim",
		specialization = "JSON/YAML schemas provider",
	},

	{
		"ray-x/lsp_signature.nvim",
		-- event = "LspAttach", -- load only when LSP attaches
		config = function()
			require("lsp_signature").setup({
				bind = true,
				help = true, -- enable ray-x/lsp_signature
				floating_window = true,
				hint_enable = true,
				handler_opts = { border = "rounded" },
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fb",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat [B]uffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},
}
