-- Paleta única del entorno. Los highlights de markdown salen de acá, no del
-- colorscheme: así el look no cambia si algún día se cambia de tema.
-- Valores tomados de eldritch.nvim (lua/eldritch/colors.lua), salvo el dorado:
-- eldritch no trae ninguno y H6 lo necesita.

return {
  fondo = "#212337",
  fondo_oscuro = "#171928",
  fondo_realce = "#292e42",
  texto = "#ebfafa",
  comentario = "#7081d0",

  rosa = "#f265b5",
  verde = "#37f499",
  cyan = "#04d1f9",
  cyan_brillante = "#39DDFD",
  violeta = "#a48cf2",
  amarillo = "#f1fc79",
  rojo = "#f16c75",
  rojo_fuerte = "#f0313e",
  naranja = "#f7c67f",
  dorado = "#d4a017",

  -- Orden de los seis niveles de heading. H2 y H3 van cambiados respecto de la
  -- paleta original: el cyan pesa menos que el verde y ordena mejor la jerarquía.
  -- H5 y H6 son vecinos de tono (naranja y dorado están a 8° de hue), así que lo
  -- que los separa es el brillo: el naranja claro arriba, el dorado profundo abajo.
  headings = { "#f0313e", "#04d1f9", "#37f499", "#a48cf2", "#f7c67f", "#d4a017" },
  -- Texto sobre la barra del heading. Oscuro, para que el color sea el que grita.
  heading_texto = "#171928",
}
