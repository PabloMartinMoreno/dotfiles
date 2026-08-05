return {
  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- nvim no pinta el fondo: se ve el del terminal. Sin esto, cada celda queda
      -- opaca y la transparencia de st/kitty no aparece.
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "eldritch" },
  },
}
