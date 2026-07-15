-- ================================================================================================
-- JSON Language Server with SchemaStore integration
-- Provides validation, completion, and hover documentation for JSON files
-- ================================================================================================

return {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	root_markers = { '.git', 'package.json' },

	-- Initialize schemastore schemas before LSP starts
	-- This lazy-loads the schemastore plugin only when needed
	init_options = {
		provideFormatter = true,
	},

	settings = {
		json = {
			-- Load all schemas from SchemaStore catalog
			-- This provides validation for package.json, tsconfig.json, etc.
			schemas = require('schemastore').json.schemas(),

			-- Enable validation
			validate = { enable = true },

			-- Format settings
			format = {
				enable = true,
			},

			-- Keep lines together when possible
			keepLines = {
				enable = true,
			},
		},
	},
}

-- schemas = require('schemastore').json.schemas({
--     select = {
--         'package.json',
--         'tsconfig.json',
--         '.eslintrc',
--         'prettier.json',
--         'composer.json',
--     },
-- }),