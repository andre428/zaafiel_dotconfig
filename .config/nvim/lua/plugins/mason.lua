-- ================================================================================================
-- TITLE : Mason - LSP/DAP/Linter Installer
-- ABOUT : Portable package manager for Neovim that provides a UI for installing and managing
--         LSP servers, DAP servers, linters, and formatters
-- LINKS : https://github.com/williamboman/mason.nvim
-- ================================================================================================

return {
    "williamboman/mason.nvim",
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
        "MasonUpdate",
    },
    opts = {
        -- UI customization
        ui = {
            border = "rounded", -- Border style: "none", "single", "double", "rounded", "solid", "shadow"

            -- Width and height as percentages of the screen
            width = 0.8,
            height = 0.8,

            -- Icons used in the Mason UI
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },

            -- Whether to check for new versions of packages on open
            check_outdated_packages_on_open = true,

            keymaps = {
                -- Keymap to expand a package (show details)
                toggle_package_expand = "<CR>",
                -- Keymap to install the package under the cursor
                install_package = "i",
                -- Keymap to update the package under the cursor
                update_package = "u",
                -- Keymap to check for new version for the package under the cursor
                check_package_version = "c",
                -- Keymap to update all installed packages
                update_all_packages = "U",
                -- Keymap to check which installed packages are outdated
                check_outdated_packages = "C",
                -- Keymap to uninstall a package
                uninstall_package = "X",
                -- Keymap to cancel a package installation
                cancel_installation = "<C-c>",
                -- Keymap to apply language filter
                apply_language_filter = "<C-f>",
            },
        },

        -- The maximum number of packages to be installed/updated/uninstalled at the same time
        max_concurrent_installers = 2,

        -- Where Mason should install packages
        -- This is relative to vim.fn.stdpath("data")
        -- Default: "mason"
        install_root_dir = vim.fn.stdpath("data") .. "/mason",

        -- Path to Python 3 executable. Set this if mason has trouble finding python
        -- pip = {
        -- 	upgrade_pip = false,
        -- 	install_args = {},
        -- },

        -- GitHub credentials for downloading tools from GitHub
        -- Leave commented unless you hit rate limits
        -- github = {
        -- 	download_url_template = "https://github.com/%s/releases/download/%s/%s",
        -- },

        -- Controls to which degree logs are written to the log file
        -- Levels: "off", "error", "warn", "info", "debug", "trace"
        log_level = vim.log.levels.INFO,
    },
}