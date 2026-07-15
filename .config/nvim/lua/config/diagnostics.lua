-- ================================================================================================
-- TITLE : LSP Diagnostics Configuration
-- ABOUT : Configures how LSP diagnostics (errors, warnings, hints, info) are displayed
--         Sets up custom icons, virtual text, underlines, and floating windows
-- ================================================================================================

-- Define diagnostic symbols/icons for the sign column
-- These appear in the gutter next to line numbers
local diagnostic_signs = {
  Error = " ",
  Warn = " ",
  Hint = "",
  Info = "",
}

-- Register the signs with Neovim's sign system
-- This makes them appear in the sign column (gutter)
for type, icon in pairs(diagnostic_signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl, -- Highlight group for the icon
    numhl = hl,  -- Highlight group for line numbers (optional)
  })
end

-- Configure global diagnostic behavior
vim.diagnostic.config({
  -- === VIRTUAL TEXT ===
  -- Text shown at the end of problematic lines
  virtual_text = {
    prefix = "●", -- Prefix character before the diagnostic message
    spacing = 4, -- Number of spaces between the code and the virtual text

    -- Only show virtual text for errors and warnings (not hints/info)
    -- Uncomment to enable:
    -- severity = {
    -- 	min = vim.diagnostic.severity.WARN,
    -- },

    -- Custom format for virtual text
    -- Shows severity and message
    format = function(diagnostic)
      return string.format("%s", diagnostic.message)
    end,
  },

  -- === SIGNS (GUTTER ICONS) ===
  -- Show diagnostic icons in the sign column (gutter)
  signs = {
    -- Modern Neovim 0.10+ API for diagnostic signs
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
      [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
      [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
      [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
    },
    -- For older Neovim versions, uncomment:
    -- severity = {
    -- 	min = vim.diagnostic.severity.HINT,
    -- },
  },

  -- === UNDERLINE ===
  -- Underline problematic code
  underline = true,

  -- === UPDATE BEHAVIOR ===
  -- Don't update diagnostics while typing in insert mode
  -- Prevents flickering and distraction
  update_in_insert = false,

  -- === SEVERITY SORTING ===
  -- Sort diagnostics by severity (errors first, then warnings, etc.)
  severity_sort = true,

  -- === FLOATING WINDOW ===
  -- Configuration for diagnostic floating windows (shown with vim.diagnostic.open_float)
  float = {
    border = "rounded", -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    source = "always",  -- Show the source of the diagnostic (e.g., "eslint", "pyright")
    header = "",        -- Header text (empty for cleaner look)
    prefix = "",        -- Prefix for each diagnostic line

    -- Custom format for floating window content
    format = function(diagnostic)
      return string.format("%s [%s]", diagnostic.message, diagnostic.source or "unknown")
    end,

    -- Focus the floating window (allows scrolling)
    focusable = true,

    -- Style of the floating window
    style = "minimal",

    -- Add padding inside the floating window
    -- Uncomment to enable:
    -- pad_top = 1,
    -- pad_bottom = 1,
  },
})

-- ================================================================================================
-- Additional Diagnostic Utilities
-- ================================================================================================

-- Helper function to toggle virtual text on/off
-- Usage: :ToggleDiagnosticVirtualText
vim.api.nvim_create_user_command("ToggleDiagnosticVirtualText", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({
    virtual_text = not current,
  })
  local status = not current and "enabled" or "disabled"
  vim.notify("Diagnostic virtual text: " .. status, vim.log.levels.INFO)
end, {
  desc = "Toggle diagnostic virtual text on/off",
})

-- Helper function to show diagnostics in location list
-- Usage: :DiagnosticsToLocList
vim.api.nvim_create_user_command("DiagnosticsToLocList", function()
  vim.diagnostic.setloclist()
end, {
  desc = "Show diagnostics in location list",
})

-- Helper function to show diagnostics in quickfix list
-- Usage: :DiagnosticsToQuickfix
vim.api.nvim_create_user_command("DiagnosticsToQuickfix", function()
  vim.diagnostic.setqflist()
end, {
  desc = "Show diagnostics in quickfix list",
})

-- ================================================================================================
-- Custom Diagnostic Highlights (Optional)
-- ================================================================================================
-- Uncomment to customize diagnostic highlight colors
-- These override your colorscheme's diagnostic colors

-- vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#db4b4b" })
-- vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#e0af68" })
-- vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#0db9d7" })
-- vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#1abc9c" })

-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#db4b4b" })
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#e0af68" })
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#0db9d7" })
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#1abc9c" })
