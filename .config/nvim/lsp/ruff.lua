return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'ruff.toml',
    '.ruff.toml',
    '.git',
  },
  init_options = {
    settings = {
      configuration = vim.fn.getcwd() .. "/pyproject.toml",
      configurationPreference = "filesystemFirst", -- Prioritize pyproject.toml
    },
  },
  settings = {

    ------------------------------------------------------------------
    -- GENERAL CONFIGURATION
    ------------------------------------------------------------------

    -- Maximum allowed line length (keeps consistent with Black)
    lineLength = 100,

    ------------------------------------------------------------------
    -- LINTING SETTINGS
    ------------------------------------------------------------------
    lint = {
      -- Enable linting features
      enable = true,

      -- Which rule groups to activate (see ruff rules documentation)
      select = {
        "E",   -- pycodestyle errors
        "W",   -- pycodestyle warnings
        "F",   -- pyflakes
        "B",   -- flake8-bugbear
        "I",   -- import sorting (isort)
        "N",   -- pep8-naming
        "UP",  -- pyupgrade
        "YTT", -- flake8-2020
        "S",   -- flake8-bandit security rules
        "C4",  -- flake8-comprehensions
        "T10", -- debugger statements
        "T20", -- print statements
      },

      -- Rules to ignore globally
      ignore = {
        "E501", -- Line too long (formatter handles this)
        "S101", -- Allow `assert` (commonly used in tests)
        "T201", -- Allow print() in scripts
      },
    },

    ------------------------------------------------------------------
    -- CODE FORMATTING SETTINGS
    ------------------------------------------------------------------
    format = {
      -- Enable Ruff's formatter
      enable = true,

      -- Preferred quoting style ("single" or "double")
      ["quote-style"] = "double",

      -- Use spaces instead of tabs
      ["indent-style"] = "space",

      -- Format code blocks inside docstrings
      ["docstring-code-format"] = true,

      -- Normalize line endings to Unix style
      ["line-ending"] = "lf",

      -- Follow Black's magic trailing comma rules
      ["skip-magic-trailing-comma"] = false,
    },

    ------------------------------------------------------------------
    -- IMPORT SORTING SETTINGS (ISORT REPLACEMENT)
    ------------------------------------------------------------------
    isort = {
      -- Merge multiple `as` imports into one line
      ["combine-as-imports"] = true,
    },

    ------------------------------------------------------------------
    -- CODE ACTIONS (AUTO-FIXING) SETTINGS
    ------------------------------------------------------------------
    codeAction = {
      -- Enable rule disabling via comments (# noqa-equivalent)
      disableRuleComment = {
        enable = true,
      },

      -- Allow auto-fixes to apply on save or via code actions
      fixViolation = {
        enable = true,
      },
    },
  },
}

