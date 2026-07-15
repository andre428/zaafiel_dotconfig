-- ================================================================================================
-- TITLE : Neovim Auto-Commands Configuration
-- ABOUT : Automatically execute commands in response to specific events (saves, yanks, LSP attach)
--         Includes intelligent formatting, import organization, and helpful editor behaviors
-- ================================================================================================

-- ============================================================================
-- SECTION: Helper Functions
-- ============================================================================

--- Creates an augroup with automatic clearing to prevent duplicate autocommands
--- @param name string The name of the augroup
--- @return number The augroup ID
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

--- Preserves cursor position and view while executing a command
--- Useful for operations that might jump the cursor (like formatting)
--- @param callback function The function to execute
local function preserve_view(callback)
  local view = vim.fn.winsaveview()
  callback()
  vim.fn.winrestview(view)
end

-- ============================================================================
-- SECTION: Large File Optimization
-- ============================================================================
-- Disable heavy features for large files to improve performance
-- Turns off syntax, treesitter, LSP, etc. for files > 1MB
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup("LargeFileOptimization"),
  desc = "Disable heavy features for large files",
  callback = function(event)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))

    -- If file is larger than 1MB
    if ok and stats and stats.size > 1024 * 1024 then
      vim.b[event.buf].large_file = true

      -- Disable features
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.breakindent = false
      vim.opt_local.colorcolumn = ""
      vim.opt_local.statuscolumn = ""
      vim.opt_local.signcolumn = "no"
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.winbar = ""

      -- Disable syntax and treesitter
      vim.bo[event.buf].syntax = "off"
      vim.api.nvim_buf_call(event.buf, function()
        pcall(vim.treesitter.stop)
      end)

      vim.notify("Large file detected - some features disabled", vim.log.levels.WARN)
    end
  end,
})

-- ============================================================================
-- SECTION: Number Toggle Based on Mode
-- ============================================================================
-- Show relative numbers in normal mode, absolute numbers in insert mode
-- Helps with navigation in normal mode, clearer positioning in insert mode
-- ============================================================================

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  desc = "Use absolute line numbers in insert mode",
  group = augroup("RelativeNumbersOff"),
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  desc = "Use relative line numbers in normal mode",
  group = augroup("RelativeNumbersOn"),
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- ============================================================================
-- SECTION: Better Search Highlighting
-- ============================================================================
-- Temporarily enable search highlighting when searching
-- Automatically disable after cursor moves
-- Keeps screen clean but highlights when needed
-- ============================================================================

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { "/", "?" },
  desc = "Enable search highlighting when searching",
  group = augroup("SearchHighlightOn"),
  callback = function()
    vim.opt.hlsearch = true
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = { "/", "?" },
  desc = "Disable search highlighting after search",
  group = augroup("SearchHighlightOff"),
  callback = function()
    vim.defer_fn(function()
      vim.opt.hlsearch = false
    end, 1000)
  end,
})

-- ============================================================================
-- SECTION: Cursor Position Restoration
-- ============================================================================
-- When reopening a file, jump to the last known cursor position
-- Respects the '" mark which stores the last position before exiting
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file at last edit position (with exclusions)",
  group = augroup("RestoreCursor"),
  callback = function()
    local exclude_ft = { "gitcommit", "gitrebase", "xxd", "help" }
    local buf = vim.api.nvim_get_current_buf()

    if vim.tbl_contains(exclude_ft, vim.bo[buf].filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)

    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================================
-- SECTION: Visual Feedback for Yanking
-- ============================================================================
-- Briefly highlight yanked (copied) text to provide visual confirmation
-- Uses the 'IncSearch' highlight group for visibility
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  desc = "Highlight yanked text briefly for visual feedback",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})

-- ============================================================================
-- SECTION: Remove Extra Blank Lines
-- ============================================================================
-- Collapse multiple consecutive blank lines into a single blank line
-- Keeps code readable without excessive vertical spacing
-- Preserves cursor position
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("SqueezeBlankLines"),
                            desc = "Collapse excessive blank lines (keeps up to 2 blank lines)",
                            callback = function()
                            -- Skip for filetypes where blank lines might be significant
                            local skip_squeeze = {
                              "markdown",
                              "text",
                            }

                            if vim.tbl_contains(skip_squeeze, vim.bo.filetype) then
                              return
                              end

                              preserve_view(function()
                              -- Replace 3+ blank lines with 2 blank lines
                              -- Pattern: \n\n\n\n+ (4+ newlines = 3+ blank lines) → \n\n\n (3 newlines = 2 blank lines)
                              vim.cmd([[%s/\n\n\n\n\+/\r\r\r/e]])
                              end)
                              end,
})

-- ============================================================================
-- SECTION: Intelligent Format on Save
-- ============================================================================
-- Automatically formats code before saving, with intelligent prioritization:
-- 1. Python files: Use ruff (fast Python linter/formatter)
-- 2. Other files: Try efm-langserver (multi-language tool)
-- 3. Fallback: Use any LSP that supports formatting
--
-- Synchronous formatting ensures the file is properly formatted before write
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("FormatOnSave"),
  desc = "Format buffer before saving using the best available formatter",
  callback = function(event)
    -- Skip formatting if globally disabled
    if not vim.g.enable_format_on_save then
      return
    end

    local bufnr = event.buf
    local filetype = vim.bo[bufnr].filetype

    -- Skip formatting for specific filetypes where it might cause issues
    local skip_filetypes = {
      "markdown", -- Markdown formatters can be too aggressive
      "text",     -- Plain text doesn't need formatting
    }

    if vim.tbl_contains(skip_filetypes, filetype) then
      return
    end

    -- Get all LSP clients attached to this buffer
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    -- === PYTHON-SPECIFIC FORMATTING ===
    -- Prefer ruff for Python files (fast and opinionated)
    if filetype == "python" then
      local ruff_client = vim.tbl_filter(function(client)
        return client.name == "ruff"
      end, clients)[1]

      if ruff_client then
        vim.lsp.buf.format({
          bufnr = bufnr,
          name = "ruff",
          async = false,
          timeout_ms = 2000,
        })
        return
      end
    end

    -- === EFM LANGSERVER FORMATTING ===
    -- Try efm-langserver if configured (supports multiple languages)
    local efm_client = vim.tbl_filter(function(client)
      return client.name == "efm"
    end, clients)[1]

    if efm_client then
      vim.lsp.buf.format({
        bufnr = bufnr,
        name = "efm",
        async = false,
        timeout_ms = 2000,
      })
      return
    end

    -- === FALLBACK FORMATTING ===
    -- Use any available LSP that supports formatting
    local formatting_clients = vim.tbl_filter(function(client)
      return client.server_capabilities.documentFormattingProvider
    end, clients)

    if #formatting_clients > 0 then
      vim.lsp.buf.format({
        bufnr = bufnr,
        async = false,
        timeout_ms = 2000,
      })
    end
  end,
})

-- ============================================================================
-- SECTION: Auto-Format Specific File Types
-- ============================================================================
-- Automatically format specific file types using external tools
-- Examples: JSON with jq, XML with xmllint, SQL with pg_format
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.json",
  desc = "Auto-format JSON files with jq before saving",
  group = augroup("JSONFormatOnSave"),
  callback = function()
    if vim.fn.executable("jq") == 1 then
      -- Format in-place without re-saving
      vim.cmd("silent! %!jq .")
    end
  end,
})

-- ============================================================================
-- SECTION: Python Import Organization
-- ============================================================================
-- For Python files, organize imports before saving
-- This runs BEFORE the format-on-save to avoid conflicts
-- Uses ruff's "source.organizeImports" code action
-- - Removes unused imports
-- - Sorts imports alphabetically
-- - Groups standard library, third-party, and local imports
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("PythonOrganizeImports"),
  pattern = "*.py",
  desc = "Organize Python imports before saving (remove unused, sort)",
  callback = function(event)
    local bufnr = event.buf

    -- Find ruff LSP client
    local ruff_clients = vim.lsp.get_clients({
      bufnr = bufnr,
      name = "ruff",
    })

    if #ruff_clients == 0 then
      return
    end

    -- Request import organization via LSP code action
    vim.lsp.buf.code_action({
      context = {
        only = { "source.organizeImports" },
        diagnostics = {},
      },
      apply = true,
    })

    -- Small delay to ensure import organization completes before formatting
    vim.wait(100)
  end,
})

-- ============================================================================
-- SECTION: Auto-Create Directories
-- ============================================================================
-- Automatically create parent directories when saving a new file
-- Example: :w ~/foo/bar/baz.txt will create ~/foo/bar/ if it doesn't exist
-- Prevents annoying "E212: Can't open file for writing" errors
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Create missing parent directories with confirmation",
  group = augroup("AutoCreateDir"),
  callback = function(event)
    local file = vim.uv.fs_realpath(event.match) or assert(event.match)
    local dir = vim.fn.fnamemodify(file, ":p:h")

    if vim.fn.isdirectory(dir) == 0 then
      local choice = vim.fn.confirm(
        string.format('Directory "%s" doesn\'t exist. Create it?', dir),
        "&Yes\n&No",
        1
      )

      if choice == 1 then
        vim.fn.mkdir(dir, "p")
      else
        error("Directory creation cancelled")
      end
    end
  end,
})

-- ============================================================================
-- SECTION: Trim Trailing Whitespace
-- ============================================================================
-- Remove trailing spaces at the end of lines before saving
-- Preserves cursor position and search pattern
-- Can be disabled for specific filetypes if needed
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("TrimWhitespace"),
  desc = "Remove trailing whitespace on save while preserving cursor position",
  callback = function()
    -- Skip whitespace trimming for certain filetypes
    local skip_trim = {
      "markdown", -- Markdown uses trailing spaces for line breaks
      "diff",     -- Diff files shouldn't be modified
    }

    if vim.tbl_contains(skip_trim, vim.bo.filetype) then
      return
    end

    preserve_view(function()
      -- Use substitute command with 'e' flag to suppress errors if no matches
      vim.cmd([[%s/\s\+$//e]])
    end)
  end,
})

-- ============================================================================
-- SECTION: Auto-Compile on Save (Language-Specific)
-- ============================================================================
-- Automatically compile certain file types when saving
-- Examples: LaTeX → PDF, Markdown → HTML, TypeScript → JavaScript
-- ============================================================================

-- LaTeX: Compile to PDF on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  desc = "Compile LaTeX to PDF after saving",
  group = augroup("LaTeXCompile"),
  command = "silent! !pdflatex %",
})

-- Markdown: Convert to HTML using pandoc
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  desc = "Convert Markdown to HTML after saving",
  group = augroup("MarkdownToHTML"),
  callback = function()
    local file = vim.fn.expand("%:p")
    local output = vim.fn.expand("%:p:r") .. ".html"
    vim.fn.system(string.format("pandoc %s -o %s", file, output))
  end,
})

-- ============================================================================
-- SECTION: Check for External File Changes
-- ============================================================================
-- When Neovim regains focus, check if files were modified externally
-- Prompts to reload if file changed on disk (prevents conflicts)
-- ============================================================================

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold" }, {
  group = augroup("CheckExternalChanges"),
  desc = "Check if file was modified externally when regaining focus and reload",
  callback = function()
    if vim.fn.mode() ~= "c" then -- Not in command-line mode
      vim.cmd("checktime")
    end
  end,
})

-- ============================================================================
-- SECTION: Resize Splits on Terminal Resize
-- ============================================================================
-- When terminal is resized, automatically adjust split sizes proportionally
-- Keeps splits balanced when changing terminal dimensions
-- ============================================================================

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("ResizeSplits"),
  desc = "Automatically resize splits when terminal is resized",
  command = "wincmd =",
})

-- ============================================================================
-- SECTION: Close Certain Windows with 'q'
-- ============================================================================
-- In special buffer types (help, quickfix, etc.), press 'q' to close
-- Makes it faster to dismiss temporary/read-only windows
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("CloseWithQ"),
  pattern = {
    "help",
    "qf",          -- Quickfix window
    "lspinfo",     -- LSP info window
    "man",         -- Man pages
    "startuptime", -- :StartupTime output
    "checkhealth", -- :checkhealth output
  },
  desc = "Close certain buffer types with 'q' key",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Close window",
    })
  end,
})

-- ============================================================================
-- SECTION: Toggle Format-on-Save (User Command)
-- ============================================================================
-- Global flag to enable/disable automatic formatting
-- Useful for debugging or working with files that shouldn't be auto-formatted
-- Usage: :ToggleFormatOnSave
-- ============================================================================

vim.g.enable_format_on_save = true

vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
  vim.g.enable_format_on_save = not vim.g.enable_format_on_save
  local status = vim.g.enable_format_on_save and "enabled" or "disabled"
  vim.notify("Format on save: " .. status, vim.log.levels.INFO)
end, {
  desc = "Toggle automatic formatting on save",
})

-- ============================================================================
-- SECTION: Terminal Mode Settings
-- ============================================================================
-- Automatically enter insert mode when opening a terminal
-- Disables line numbers in terminal buffers for cleaner look
-- ============================================================================

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("TerminalSettings"),
  desc = "Configure terminal buffer settings",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- ============================================================================
-- SECTION: Git Commit Message Configuration
-- ============================================================================
-- For git commit messages: enable spell check, set text width, start in insert mode
-- Makes writing commit messages more ergonomic and follows conventional commit standards
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "gitrebase" },
  desc = "Configure git commit editing experience",
  group = augroup("GitCommitMessage"),
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72 -- Git conventional commit line length
    vim.cmd("startinsert")       -- Start in insert mode at beginning
  end,
})

-- ============================================================================
-- SECTION: Auto-Save on Focus Loss
-- ============================================================================
-- Automatically save all modified buffers when Neovim loses focus
-- Prevents losing work when switching to other applications
-- Only saves normal buffers (not terminals, help files, etc.)
-- ============================================================================

vim.api.nvim_create_autocmd("FocusLost", {
  desc = "Auto-save all modified buffers when losing focus",
  group = augroup("AutoSaveOnFocusLost"),
  callback = function()
    -- Only save if buffer is modifiable and has a name
    if vim.bo.modifiable and vim.bo.buftype == "" then
      vim.cmd("silent! wa") -- Write all, suppress errors
    end
  end,
})

-- ============================================================================
-- SECTION: Highlight on Cursor Hold
-- ============================================================================
-- Briefly highlight the current line when cursor stops moving
-- Helps you find the cursor quickly in large files
-- Uses CursorHold event (triggers after 'updatetime' milliseconds of inactivity)
-- ============================================================================

vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Highlight current line briefly when cursor stops",
  group = augroup("HighlightCursorHold"),
  callback = function()
    vim.opt.cursorline = true
    -- Remove highlight after brief delay
    vim.defer_fn(function()
      vim.opt.cursorline = false
    end, 120)
  end,
})

-- ============================================================================
-- SECTION: Disable Auto-Comment on New Line
-- ============================================================================
-- Prevents Vim from automatically adding comment leaders when pressing Enter
-- or 'o' in a comment line
-- Many find this default behavior annoying
-- ============================================================================

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Disable automatic comment continuation",
  group = augroup("NoNextLineComment"),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ============================================================================
-- SECTION: Remember Folds
-- ============================================================================
-- Save and restore fold state when closing/opening files
-- Only works for files with a name (not temporary buffers)
-- Creates view files in ~/.local/state/nvim/view/
-- ============================================================================

vim.api.nvim_create_autocmd("BufWinLeave", {
  group = augroup("RememberFolds"),
  pattern = "?*", -- Any file with a name (not empty)
  desc = "Save fold state when leaving buffer",
  callback = function()
    if vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! mkview")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("RememberFolds"),
  pattern = "?*",
  desc = "Restore fold state when entering buffer",
  callback = function()
    if vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! loadview")
    end
  end,
})

-- ============================================================================
-- SECTION: URL Handling
-- ============================================================================
-- Open URLs under cursor with gx in normal mode
-- Works with http, https, and www links
-- ============================================================================

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Enable URL opening with gx",
  group = augroup("OpenURLWithGx"),
  callback = function()
    vim.keymap.set("n", "gx", function()
      local url = vim.fn.expand("<cfile>")
      if url:match("^https?://") or url:match("^www%.") then
        vim.fn.jobstart({ "xdg-open", url }, { detach = true })
      else
        vim.notify("No URL under cursor", vim.log.levels.WARN)
      end
    end, { buffer = true, desc = "Open URL under cursor" })
  end,
})

-- ============================================================================
-- SECTION: Spell Check for Text Files
-- ============================================================================
-- Enable spell checking for text-based files
-- Automatically underlines misspelled words
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "tex" },
  desc = "Enable spell check for text files",
  group = augroup("TextSpellCheck"),
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- ============================================================================
-- SECTION: Prevent Accidental Write to Buffer
-- ============================================================================
-- Make certain buffer types read-only
-- Prevents accidentally modifying help files, man pages, etc.
-- ============================================================================

vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*.orig", "*.pacnew" },
  desc = "Make backup/system files read-only",
  group = augroup("SystemFilesReadOnly"),
  callback = function()
    vim.bo.readonly = true
    vim.bo.modifiable = false
  end,
})

-- ============================================================================
-- SECTION: Better Quickfix Window
-- ============================================================================
-- Automatically open quickfix window after grep, make, etc.
-- Automatically close it when empty
-- ============================================================================

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "[^l]*" },
  desc = "Auto-open quickfix window after grep/make",
  group = augroup("GrepQuickfix"),
  command = "cwindow",
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "l*" },
  desc = "Auto-open location list",
  group = augroup("GrepQuickfix"),
  command = "lwindow",
})

-- ============================================================================
-- SECTION: Markdown-Specific Settings
-- ============================================================================
-- Configure markdown files for better writing experience
-- Enables word wrap, concealment of markdown syntax
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  desc = "Configure markdown editing environment",
  group = augroup("MarkdownSettings"),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.spell = true
  end,
})
-- ============================================================================
-- END OF AUTOCOMMANDS
-- ============================================================================
