-- ================================================================================================
-- TITLE : LSP Keymaps & Behavior Setup
-- ABOUT :
--   Sets up an autocommand that runs when any LSP server attaches to a buffer.
--   Configures all LSP-related keymaps and client-specific behavior.
-- ================================================================================================

-- Create autocommand that runs when LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local bufnr = event.buf
    local keymap = vim.keymap.set

    local opts = {
      buffer = bufnr,
      silent = true,
      noremap = true,
    }

    -- ===========================
    -- Native Neovim LSP Keymaps
    -- ===========================
    keymap("n", "<leader>gD", vim.lsp.buf.definition, opts)

    keymap("n", "<leader>gS", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, opts)

    keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
    keymap("n", "K", vim.lsp.buf.hover, opts)

    keymap("n", "<leader>D", function()
      vim.diagnostic.open_float({ scope = "line" })
    end, opts)

    keymap("n", "<leader>d", vim.diagnostic.open_float, opts)

    -- Diagnostic navigation (post-0.11 canonical API)
    keymap("n", "<leader>pd", function()
      vim.diagnostic.jump({
        count = -vim.v.count1,
        float = true,
      })
    end, opts)

    keymap("n", "<leader>nd", function()
      vim.diagnostic.jump({
        count = vim.v.count1,
        float = true,
      })
    end, opts)

    -- ===========================
    -- FZF-Lua LSP Keymaps
    -- ===========================
    keymap("n", "<leader>gd", "<cmd>FzfLua lsp_finder<CR>", opts)
    keymap("n", "<leader>gr", "<cmd>FzfLua lsp_references<CR>", opts)
    keymap("n", "<leader>gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)
    keymap("n", "<leader>ds", "<cmd>FzfLua lsp_document_symbols<CR>", opts)
    keymap("n", "<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts)
    keymap("n", "<leader>gi", "<cmd>FzfLua lsp_implementations<CR>", opts)

    -- ===========================
    -- Organize Imports
    -- ===========================
    if client.server_capabilities.codeActionProvider then
      keymap("n", "<leader>oi", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
          apply = true,
        })
        -- Format after changing import order
        vim.defer_fn(function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end, 50)
      end, opts)
    end

    -- ===========================
    -- DAP Keymaps (Rust only)
    -- ===========================
    if client.name == "rust-analyzer" then
      local dap = require("dap")
      keymap("n", "<leader>dc", dap.continue, opts)
      keymap("n", "<leader>do", dap.step_over, opts)
      keymap("n", "<leader>di", dap.step_into, opts)
      keymap("n", "<leader>du", dap.step_out, opts)
      keymap("n", "<leader>db", dap.toggle_breakpoint, opts)
      keymap("n", "<leader>dr", dap.repl.open, opts)
    end

    -- ===========================
    -- Client-Specific Configurations
    -- ===========================

    -- Disable formatting for certain servers (let dedicated formatters handle it)
    if client.name == "ts_ls" or client.name == "jsonls" then
      client.server_capabilities.documentFormattingProvider = false
    end

    -- Log which LSP attached (useful for debugging)
    vim.notify(
      string.format("LSP: %s attached to buffer %d", client.name, bufnr),
      vim.log.levels.INFO
    )
  end,
})
