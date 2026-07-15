return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 3000,

  opts = {
    compile = false,
    transparent = false,
    theme = "dragon", -- default variant

    colors = {
      palette = {
        dragonBlack0 = "#0d0c0c",
        dragonBlack1 = "#12120f",
        dragonBlack2 = "#1D1C19",
        dragonBlack3 = "#141212",
        dragonBlack4 = "#282727",
        dragonBlack5 = "#393836",
        dragonBlack6 = "#625e5a",
        dragonGreen2 = "#5a6450",
        dragonViolet= "#8992a7",
        dragonRed = "#cd786e",
      },
    },
  },

  config = function(_, opts)
  require("kanagawa").setup(opts)
  vim.cmd.colorscheme("kanagawa-dragon")
  end,
}
