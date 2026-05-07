return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "python",
      "markdown",
    },
    highlight = {
      enable = true,
      -- Si Treesitter da error de 'range', desactivamos el resaltado para ciertos lenguajes
      -- para que el LSP tome el control sin crashes en versiones experimentales.
      disable = function(lang, buf) return false end,
    },
    indent = {
      enable = false, -- Desactivamos indent para evitar el error de node:range()
    },
  },
}
