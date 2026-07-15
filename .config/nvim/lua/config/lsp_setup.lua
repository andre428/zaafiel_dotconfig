-- ================================================================================================
-- TITLE : LSP Server Configuration & Initialization
-- ABOUT :
--   Configures global LSP capabilities (for nvim-cmp integration) and enables all LSP servers.
--   Server-specific configurations are loaded from the lsp/ directory.
-- ================================================================================================

-- Set up global LSP capabilities for autocompletion (nvim-cmp integration)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Apply capabilities to all LSP servers
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Enable all LSP servers
-- Neovim will automatically load configurations from ~/.config/nvim/lsp/<server_name>.lua
vim.lsp.enable({
  'lua_ls',
  'basedpyright',
  'jsonls',
  'ts_ls',
  'bashls',
  'clangd',
  'dockerls',
  'emmet_ls',
  'yamlls',
  'tailwindcss',
  'solidity_ls_nomicfoundation',
  'efm',
  'ruff',
})
