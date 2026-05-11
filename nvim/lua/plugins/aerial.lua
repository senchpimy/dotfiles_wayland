return {
  "stevearc/aerial.nvim",
  opts = {
    -- Eliminamos "treesitter" de los backends para evitar el error de compatibilidad
    backends = { "lsp", "markdown", "man" },
    show_guides = true,
    layout = {
      max_width = { 40, 0.2 },
      min_width = 10,
    },
  },
}
