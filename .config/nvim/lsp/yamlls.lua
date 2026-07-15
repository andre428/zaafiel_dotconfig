-- ================================================================================================
-- YAML Language Server with SchemaStore integration
-- Provides validation, completion, and hover documentation for YAML files
-- ================================================================================================

return {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml', 'yaml.docker-compose', 'yml' },
	root_markers = { '.git' },

	settings = {
		-- Disable RedHat telemetry
		redhat = {
			telemetry = {
				enabled = false,
			},
		},

		yaml = {
			-- Enable validation
			validate = true,

			-- Enable hover documentation
			hover = true,

			-- Enable completion
			completion = true,

			-- Format settings
			format = {
				enable = true,
				singleQuote = false,
				bracketSpacing = true,
			},

			-- IMPORTANT: Disable built-in schemaStore to use SchemaStore.nvim
			-- This prevents conflicts and enables advanced features
			schemaStore = {
				enable = false,
				url = "",
			},

			-- Load all schemas from SchemaStore catalog
			-- This provides validation for docker-compose.yml, GitHub Actions, etc.
			schemas = require('schemastore').yaml.schemas(),

			-- Custom tags for specific YAML flavors
			customTags = {
				-- CloudFormation tags
				"!Ref",
				"!Sub",
				"!GetAtt",
				"!Join",
				"!Select",
				"!FindInMap",
				"!GetAZs",
				"!Base64",
				"!Cidr",
				"!ImportValue",
				"!Split",
			},

			-- Don't enforce alphabetical key ordering
			keyOrdering = false,
		},
	},
}

-- schemas = require('schemastore').yaml.schemas({
--     select = {
--         'GitHub Workflow',
--         'docker-compose.yml',
--         'gitlab-ci',
--     },
-- }),