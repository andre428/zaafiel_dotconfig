-- ================================================================================================
-- TITLE : efm-langserver
-- ABOUT : a general purpose language server protocol implemented here for linters/formatters
-- LINKS :
--   > github : https://github.com/mattn/efm-langserver
--   > configs: https://github.com/creativenull/efmls-configs-nvim/tree/main
-- ================================================================================================

return {
	cmd = { 'efm-langserver' },
	filetypes = {
		"c",
		"cpp",
		"css",
		"docker",
		"go",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"lua",
		"markdown",
		"python",
		"sh",
		"solidity",
		"svelte",
		"typescript",
		"typescriptreact",
		"vue",
	},
	root_markers = { '.git' },
	settings = {
		languages = {
			c = { clangformat, cpplint },
			cpp = { clangformat, cpplint },
			css = { prettier_d },
			docker = { hadolint, prettier_d },
			go = { gofumpt, go_revive },
			html = { prettier_d },
			javascript = { eslint_d, prettier_d },
			javascriptreact = { eslint_d, prettier_d },
			json = { eslint_d, fixjson },
			jsonc = { eslint_d, fixjson },
			lua = { luacheck, stylua },
			markdown = { prettier_d },
			python = { flake8, black },
			sh = { shellcheck, shfmt },
			solidity = { solhint, prettier_d },
			svelte = { eslint_d, prettier_d },
			typescript = { eslint_d, prettier_d },
			typescriptreact = { eslint_d, prettier_d },
			vue = { eslint_d, prettier_d },
		},
	},
}