if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
        "pyright",
        "tsserver",
        "html",
        "cssls",
        "tailwindcss",
        "jsonls",
        "yamlls",
        "marksman", -- Para Markdown
        "bashls",   -- Para scripts de Shell
        "gopls",    -- Para Go
        "rust_analyzer", -- Para Rust
        "dockerls", -- Para Dockerfiles
        "eslint", -- ESlint como linter/formateador
      },
    },
  },
}
