-- El scroll animado de snacks pelea con el `zz` de <C-d>/<C-u> (ver keymaps.lua):
-- la animación del desplazamiento corre mientras el `zz` ya recentró al instante,
-- y da la impresión de que centra antes de moverse. Sin animación, `<C-d>zz`
-- es determinista: primero mueve media página, después encuadra al centro.
return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
