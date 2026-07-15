return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard",
        ignore = { "**/node_modules", "**/__pycache__", ".venv" },
        useLibraryCodeForTypes = true,
        inlayHints = {
          callArgumentNames = "partial",
          functionReturnTypes = true,
          genericTypes = true,
          variableTypes = false,
          parameterTypes = false,
        },
        diagnosticSeverityOverrides = {
          reportUnusedImport = "warning",
          reportUnusedVariable = "warning",
          reportOptionalMemberAccess = "information",
          reportUnknownMemberType = "none",
        },
      },
    },
  },
}

