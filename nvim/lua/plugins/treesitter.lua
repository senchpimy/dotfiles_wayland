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
      -- Si Treesitter da error de 'range', desactivamos el resaltado para Python temporalmente
      -- para que el LSP (Pyright/Pylsp) tome el control sin crashes.
      disable = function(lang, buf)
        if lang == "python" then return true end
        return false
      end,
    },
    indent = {
      enable = false, -- Desactivamos indent para evitar el error de node:range()
    },
  },
}
