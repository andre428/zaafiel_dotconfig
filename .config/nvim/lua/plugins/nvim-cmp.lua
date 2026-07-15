-- {codeium = "",	luasnip = "",	buffer = "",	path = "",	nvim_lsp = "🅻",},

-- ================================================================================================
-- TITLE : nvim-cmp - Autocompletion Engine
-- ABOUT : A highly customizable completion plugin for Neovim written in Lua
--         Integrates with LSP, snippets, buffer words, file paths, and command-line completion
-- LINKS :
--   > github                             : https://github.com/hrsh7th/nvim-cmp
--   > lspkind (dep)                      : https://github.com/onsails/lspkind.nvim
--   > cmp_luasnip (dep)                  : https://github.com/saadparwaiz1/cmp_luasnip
--   > luasnip (dep)                      : https://github.com/L3MON4D3/LuaSnip
--   > friendly-snippets (dep)            : https://github.com/rafamadriz/friendly-snippets
--   > cmp-nvim-lsp (dep)                 : https://github.com/hrsh7th/cmp-nvim-lsp
--   > cmp-buffer (dep)                   : https://github.com/hrsh7th/cmp-buffer
--   > cmp-path (dep)                     : https://github.com/hrsh7th/cmp-path
--   > cmp-cmdline (dep)                  : https://github.com/hrsh7th/cmp-cmdline
--   > cmp-nvim-lsp-signature-help (dep)  : https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
-- ================================================================================================

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Lazy load when entering insert mode
  dependencies = {
    -- Icons for completion items (VS Code-like pictograms)
    "onsails/lspkind.nvim",

    -- Snippet engine integration
    "saadparwaiz1/cmp_luasnip",

    -- Snippet engine
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        -- Collection of pre-made snippets for various languages
        "rafamadriz/friendly-snippets",
      },
    },

    -- Completion sources
    "hrsh7th/cmp-nvim-lsp",                -- LSP completion
    "hrsh7th/cmp-buffer",                  -- Buffer words
    "hrsh7th/cmp-path",                    -- File paths
    "hrsh7th/cmp-cmdline",                 -- ← FIXED: Added command-line completion
    "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signatures
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Load VSCode-style snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- ================================================================================================
    -- Main nvim-cmp Configuration (Insert Mode)
    -- ================================================================================================
    cmp.setup({
      -- === SNIPPET ENGINE ===
      -- Tells cmp how to expand snippets
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- === COMPLETION WINDOW APPEARANCE ===
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
      },

      -- === FORMATTING ===
      -- How completion items are displayed
      formatting = {
        -- Format completion items with icons and source names
        format = lspkind.cmp_format({
          mode = "symbol_text",  -- Show icon + text
          maxwidth = 50,         -- Truncate at 50 characters
          ellipsis_char = "...", -- Truncation indicator

          -- Custom icons for each completion source
          -- {codeium = "",	luasnip = "",	buffer = "",	path = "",	nvim_lsp = "🅻",},
          menu = {
            codeium = "", -- AI completion (if using codeium)
            luasnip = "", -- Snippet icon
            buffer = "", -- Buffer words icon
            path = "", -- File path icon
            nvim_lsp = "🅻", -- LSP icon
            nvim_lsp_signature_help = "?", -- Signature help icon
            cmdline = ":", -- Command-line icon
          },

          -- Custom formatting per source
          before = function(entry, vim_item)
            -- Add source name in brackets
            vim_item.menu = ({
              codeium = "[AI]",
              luasnip = "[Snip]",
              nvim_lsp = "[LSP]",
              buffer = "[Buf]",
              path = "[Path]",
              nvim_lsp_signature_help = "[Sig]",
              cmdline = "[Cmd]",
            })[entry.source.name]
            return vim_item
          end,
        }),
      },

      -- === KEYMAPS (Insert Mode) ===
      -- How to navigate and interact with completion menu
      mapping = cmp.mapping.preset.insert({
        -- Navigate completion items
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous item
        ["<C-j>"] = cmp.mapping.select_next_item(), -- Next item

        -- Scroll documentation window
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Trigger completion manually
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Close completion menu
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirm selection (only if explicitly selected)
        ["<CR>"] = cmp.mapping.confirm({
          select = false, -- Don't auto-select first item
          behavior = cmp.ConfirmBehavior.Replace,
        }),

        -- Tab completion with snippet jump support
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        -- Shift-Tab for reverse navigation
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- === COMPLETION SOURCES (Insert Mode) ===
      -- Order matters: higher priority sources come first
      sources = cmp.config.sources({
        { name = "codeium" },                 -- AI-powered completions (if installed)
        { name = "nvim_lsp" },                -- LSP completions
        { name = "luasnip" },                 -- Snippet completions
        { name = "nvim_lsp_signature_help" }, -- Function signatures
        { name = "path" },                    -- File path completions
      }, {
        -- Lower priority sources (only shown if no results from above)
        {
          name = "buffer",
          option = {
            -- Complete from all visible buffers
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
      }),

      -- === EXPERIMENTAL FEATURES ===
      experimental = {
        ghost_text = false, -- Show inline preview of completion (can be distracting)
      },

      -- === PERFORMANCE ===
      performance = {
        debounce = 60,          -- Delay before showing completions (ms)
        throttle = 30,          -- Delay before updating completions (ms)
        fetching_timeout = 500, -- Max time to wait for sources (ms)
        max_view_entries = 50,  -- Max number of items to show
      },
    })

    -- ================================================================================================
    -- Command-Line Completion (Search: / and ?)
    -- ================================================================================================
    -- When searching with / or ?, complete from buffer words
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- ================================================================================================
    -- Command-Line Completion (Neovim Commands: :)
    -- ================================================================================================
    -- When typing Neovim commands (:), complete commands and paths
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({
        -- Enhanced Tab behavior for command-line
        ["<Tab>"] = {
          c = function()
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end,
        },
        ["<S-Tab>"] = {
          c = function()
            if cmp.visible() then
              cmp.select_prev_item()
            else
              cmp.complete()
            end
          end,
        },
      }),
      sources = cmp.config.sources({
        { name = "path" }, -- File/directory paths have higher priority
      }, {
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" }, -- Don't complete for these commands
          },
        },
      }),
      -- Command-line specific settings
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    -- ================================================================================================
    -- Optional: Fallback to Wildmenu if cmp-cmdline Fails
    -- ================================================================================================
    -- If cmp-cmdline has issues, these wildmenu settings act as a fallback
    -- You can remove these if cmp-cmdline works perfectly for you
    vim.opt.wildmenu = true
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = "pum"
    vim.opt.wildignorecase = true
  end,
}
