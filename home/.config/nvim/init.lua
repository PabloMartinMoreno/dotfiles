-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Después de config.lazy a propósito: el colorscheme pisa cualquier highlight
-- definido antes.
require("config.highlights")
