-- Delimitadores: agregar, borrar y reemplazar.
-- El vault está lleno de **negrita** y de `código inline`.
return {
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
      custom_surroundings = {
        -- Pisa el alias 'b' de mini.surround, que era ) ] } juntos.
        -- Para borrar un paréntesis sigue estando gsd)
        b = {
          input = { "%*%*().-()%*%*" },
          output = { left = "**", right = "**" },
        },
        c = {
          input = { "`().-()`" },
          output = { left = "`", right = "`" },
        },
      },
    },
  },
}
