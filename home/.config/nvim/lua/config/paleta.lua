-- Paleta única del entorno. Los highlights de markdown salen de acá, no del
-- colorscheme: así el look no cambia si algún día se cambia de tema.
-- Valores tomados de eldritch.nvim (lua/eldritch/colors.lua).

return {
  fondo = "#212337",
  fondo_oscuro = "#171928",
  fondo_realce = "#292e42",
  texto = "#ebfafa",
  comentario = "#7081d0",

  rosa = "#f265b5",
  verde = "#37f499",
  cyan = "#04d1f9",
  violeta = "#a48cf2",
  amarillo = "#f1fc79",
  rojo = "#f16c75",
  naranja = "#f7c67f",

  -- Orden de los seis niveles de heading.
  headings = { "#f265b5", "#37f499", "#04d1f9", "#a48cf2", "#f1fc79", "#f16c75" },
  -- Texto sobre la barra del heading. Oscuro, para que el color sea el que grita.
  heading_texto = "#171928",
}
