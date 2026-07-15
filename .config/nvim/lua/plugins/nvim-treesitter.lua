-- ================================================================================================
-- TITLE : nvim-treesitter (2025 Modern Config)
-- ABOUT : Treesitter configurations for Neovim 0.11+
-- LINKS :
--   > github : https://github.com/nvim-treesitter/nvim-treesitter
--   > docs   : https://github.com/nvim-treesitter/nvim-treesitter/blob/main/doc/nvim-treesitter.txt
-- ================================================================================================

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Always use main branch (master is deprecated)
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  lazy = false, -- treesitter should NOT be lazy-loaded

  config = function()
    local ts = require("nvim-treesitter")

    -- Install parsers
    ts.install({
      "bash", "c", "cpp", "css", "dockerfile", "go", "html",
      "javascript", "json", "lua", "markdown", "markdown_inline",
      "python", "rust", "svelte", "typescript", "vue", "yaml",
    }):wait(30000)

    -- Create autocommand to enable features when opening these filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("TreesitterEnable", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local lang = args.match

        -- FEATURE 1: Syntax Highlighting (native Neovim)
        -- This is now built into Neovim, not a treesitter module!
        local ok = pcall(vim.treesitter.start, bufnr, lang)
        if not ok then
          -- Parser might not be installed yet
          vim.notify(
            string.format("Treesitter parser for %s not available", lang),
            vim.log.levels.WARN
          )
        end

        -- FEATURE 2: Indentation (provided by nvim-treesitter plugin)
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- FEATURE 3: Folding (native Neovim with treesitter)
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldenable = false -- Start with folds open
      end,
    })
    -- Automatically install parsers when opening files with unknown languages
    -- This replaces the old auto_install = true option

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
      callback = function(args)
        local lang = args.match
        local bufnr = args.buf

        -- Check if parser is already installed
        if not pcall(vim.treesitter.language.add, lang) then
          -- Parser not installed, try to install it
          vim.notify(
            string.format("Installing treesitter parser for %s...", lang),
            vim.log.levels.INFO
          )

          local task = ts.install({ lang }, { summary = true })
          if task then
            task:wait(10000) -- Wait up to 10 seconds

            -- Try to start highlighting after install
            pcall(vim.treesitter.start, bufnr, lang)
          end
        end
      end,
    })

    -- Keymaps for expanding/shrinking visual selection based on syntax tree
    -- This is now handled manually, not in a config table
    vim.keymap.set({ "n", "v" }, "<CR>", function()
      -- Get current selection or start new one
      local mode = vim.fn.mode()
      if mode == "n" then
        -- Start selection at cursor
        vim.cmd("normal! v")
      else
        -- Expand selection to parent node
        vim.treesitter.selection.select_incremental()
      end
    end, { desc = "Treesitter: Expand selection" })

    vim.keymap.set("v", "<S-CR>", function()
      -- Shrink selection to child node
      vim.treesitter.selection.select_decremental()
    end, { desc = "Treesitter: Shrink selection" })

    -- ====================================
    -- User Commands for Manual Control
    -- ====================================
    -- :TSInstall <language> - Install parser
    vim.api.nvim_create_user_command("TSInstall", function(opts)
      local langs = vim.split(opts.args, " ", { trimempty = true })
      ts.install(langs, { summary = true }):wait(30000)
    end, {
      nargs = "+",
      complete = function()
        -- Get available parsers (simplified)
        return { "python", "lua", "rust", "go", "typescript", "javascript" }
      end,
      desc = "Install treesitter parser(s)",
    })

    -- :TSUpdate - Update all installed parsers
    vim.api.nvim_create_user_command("TSUpdate", function()
      ts.update(nil, { summary = true }):wait(30000)
    end, { desc = "Update all treesitter parsers" })

    -- :TSUninstall <language> - Uninstall parser
    vim.api.nvim_create_user_command("TSUninstall", function(opts)
      local langs = vim.split(opts.args, " ", { trimempty = true })
      for _, lang in ipairs(langs) do
        ts.uninstall(lang)
      end
    end, { nargs = "+", desc = "Uninstall treesitter parser(s)" })
  end,
}
