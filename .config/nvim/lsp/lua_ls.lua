return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = {
		'.luarc.json',
		'.luarc.jsonc',
		'.luacheckrc',
		'.stylua.toml',
		'stylua.toml',
		'selene.toml',
		'.git',
	},
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

-- return function(capabilities)
-- 	vim.lsp.config('lua_ls', {
-- 		capabilities = capabilities,
-- 		settings = {
-- 			Lua = {
-- 				diagnostics = {
-- 					globals = { "vim" },
-- 				},
-- 				workspace = {
-- 					library = {
-- 						vim.fn.expand("$VIMRUNTIME/lua"),
-- 						vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
-- 					},
-- 				},
-- 			},
-- 		},
-- 	})
-- end
