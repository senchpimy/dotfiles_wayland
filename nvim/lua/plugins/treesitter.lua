return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "python",
      "markdown",
      "latex",
    },
    highlight = {
      enable = true,
      disable = function(lang, buf) return false end,
    },
    indent = {
      enable = false, -- Desactivamos indent para evitar el error de node:range()
    },
  },
}
