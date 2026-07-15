-- ================================================================================================
-- TITLE : rustaceanvim
-- ABOUT : A heavily modified fork of rust-tools.nvim
-- LINKS :
--   > github : https://github.com/mrcjkb/rustaceanvim
-- ================================================================================================

local get_codelldb_adapter = function()
local mason_registry = require("mason-registry")
if mason_registry.is_installed("codelldb") then
	local codelldb = mason_registry.get_package("codelldb")
	local ok, install_path = pcall(function()
	return codelldb:get_install_path()
	end)
	local extension_path
	if ok and install_path then
		extension_path = install_path .. "/extension/"
		else
			print("[error] getting codelldb install path, using fallback...")
			extension_path = vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/")
			end
			local codelldb_path = extension_path .. "adapter/codelldb"
			local base_path = extension_path .. "lldb/lib/liblldb"
			---@diagnostic disable-next-line: undefined-field (os_uname)
			local this_os = vim.uv.os_uname().sysname
			local liblldb_path = base_path .. (this_os == "Linux" and ".so" or ".dylib")
			local cfg = require("rustaceanvim.config")
			return cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
			end
			end

			local config = function()
			-- Get capabilities from cmp for autocompletion
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
				end

				local settings = {
					tools = {
						hover_actions = {
							auto_focus = true,
						},
					},
					server = {
						-- Remove on_attach - the global LspAttach autocommand handles this now
						capabilities = capabilities,
						settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
								},
								-- Additional rust-analyzer settings
								checkOnSave = {
									command = "clippy", -- Use clippy for better lints
								},
							},
						},
					},
					dap = {},
				}

				local ok, adapter = pcall(get_codelldb_adapter)
				if ok and adapter then
					settings.dap.adapter = adapter
					end

					vim.g.rustaceanvim = settings
					end

					return {
						"mrcjkb/rustaceanvim",
						version = "^6",
						lazy = false,
						ft = { "rust" }, -- Only load for Rust files
						config = config,
					}