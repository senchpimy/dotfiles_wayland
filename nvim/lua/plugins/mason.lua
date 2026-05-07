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
        "texlab",

        -- install formatters
        "stylua",
        "bibtex-tidy",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
        "pyright",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "json-lsp",
        "yaml-language-server",
        "marksman", -- Para Markdown
        "bash-language-server",   -- Para scripts de Shell
        "gopls",    -- Para Go
        "rust-analyzer", -- Para Rust
        "dockerfile-language-server", -- Para Dockerfiles
        "eslint-lsp", -- ESlint como linter/formateador
      },
    },
  },
}
