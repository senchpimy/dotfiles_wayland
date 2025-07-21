vim.keymap.set("n", "nh", ":HopWord<CR>")
vim.keymap.set("n", "<TAB>", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-TAB>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-c>", ":BufferLinePickClose<CR>")
vim.api.nvim_set_keymap('i', '<C-Tab>', 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_trail_size = 1.0
vim.g.neovide_cursor_animation_length = 0.1
vim.g.neovide_cursor_vfx_particle_density = 1.0
--vim.keymap.set("n", "<C-o>", require("rustowl").rustowl_cursor, { noremap = true, silent = true })


lvim.builtin.alpha.active = false

function read_file_as_string(filepath)
  local file = io.open(filepath, "r")
  if not file then
    error("No se pudo abrir el archivo: " .. filepath)
  end

  local content = file:read("*a")
  file:close()
  return content
end

vim.wo.relativenumber = true
-- En tu configuración de indent_blankline.nvim (init.lua)
--vim.g.indent_blankline_use_treesitter = false

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.b.indent_blankline_use_treesitter = false -- Desactiva Treesitter para C++
    vim.b.indent_blankline_enabled = true         -- Opcional: Usa indentación por regex
  end,
})

lvim.log.level = "warn"
lvim.format_on_save.enabled = true
--lvim.format_on_save.enabled = false
lvim.colorscheme = "lunar"
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false


-- Deshabilitar configuración automática para evitar conflictos
--vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rustowl" })

lvim.lsp.automatic_servers_installation = false

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  --"rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.highlight.enable = true

lvim.plugins = {
  { "mattn/emmet-vim" },
  { "jeetsukumaran/vim-indentwise" },
  {
    "senchpimy/liverserver.nvim",
    config = function()
      require('liveserver')
    end
  },
  { "tpope/vim-surround" },
  {
    "lmburns/lf.nvim",
    config = function()
      vim.g.lf_netrw = 1

      require("lf").setup({
        default_cmd = "lfrun",
        escape_quit = false,
        border = "rounded",
      })

      vim.keymap.set("n", "<C-f>", "<Cmd>Lf<CR>")
    end,
  },
  -- Until LunarVim supports neovim 0.11
  --{
  --  "mikavilpas/yazi.nvim",
  --  event = "VeryLazy",
  --  dependencies = {
  --    "folke/snacks.nvim"
  --  },
  --  keys = {
  --    {
  --      "<C-f>",
  --      mode = { "n", "v" },
  --      "<cmd>Yazi<cr>",
  --      desc = "Open yazi at the current file",
  --    }
  --  }
  --},
  {
    "hedyhli/outline.nvim",
    config = function()
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })

      require("outline").setup {
      }
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown", "quarto" },
    after = { 'nvim-treesitter' },
    dependencies = { 'echasnovski/mini.nvim', opt = true }, -- if you use the mini.nvim suite
    -- requires = { 'echasnovski/mini.icons', opt = true }, -- if you use standalone mini plugins
    -- requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
    config = function()
      require('render-markdown').setup({})
    end,
  },
  --/////////////// TEST \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  { "Isrothy/neominimap.nvim", },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
      require("telescope").load_extension("refactoring")
      require("refactoring").setup({
        prompt_func_return_type = {
          go = true,
          python = true,
          javascript = true,
          typescript = true,
          rust = true,
        },
        prompt_func_param_type = {
          go = true,
          python = true,
          javascript = true,
          typescript = true,
          rust = true,
        },
      })

      vim.keymap.set(
        { "n", "x" },
        "<leader>rr", -- "Refactor Refactor"
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        { noremap = true, silent = true, desc = "[R]efactor -> [R]efactor menu" }
      )
    end
  },
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    config = function()
      local image = require("image")

      ---@diagnostic disable-next-line: missing-fields
      image.setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "quarto" }, -- markdown extensions (ie. quarto) can go here
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
          },
        },
        max_width = 100,
        max_height = 8,
        max_height_window_percentage = math.huge,
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true,    -- toggles images when windows are overlapped
        editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fidget", "" },
      })
    end,
  },
  { "3rd/diagram.nvim",  dependencies = { "image.nvim" },      enabled = true, opts = {} },
  {
    "GCBallesteros/jupytext.nvim",
    -- ft = { "ipynb" },
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  { "jmbuhr/otter.nvim", ft = { "markdown", "quarto", "norg" } },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "nvim-lspconfig",
      "hydra.nvim",
      "otter.nvim",
    },
    ft = { "quarto", "markdown", "norg" },
    config = function()
      local quarto = require("quarto")
      quarto.setup({
        lspFeatures = {
          languages = { "python", "rust", "lua" },
          chunks = "all", -- 'curly' or 'all'
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = "H",
          definition = "gd",
          rename = "<leader>rn",
          references = "gr",
          format = "<leader>gf",
        },
        codeRunner = {
          enabled = true,
          ft_runners = {
            bash = "slime",
          },
          default_method = "molten",
        },
      })

      vim.keymap.set("n", "<localleader>qp", quarto.quartoPreview,
        { desc = "Preview the Quarto document", silent = true, noremap = true })
      -- to create a cell in insert mode, I have the ` snippet
      vim.keymap.set("n", "<localleader>cc", "i`<c-j>", { desc = "Create a new code cell", silent = true })
      vim.keymap.set("n", "<localleader>cs", "i```\r\r```{}<left>",
        { desc = "Split code cell", silent = true, noremap = true })

      -- for more keybinds that I would use in a quarto document, see the configuration for molten
      --require("benlubas.hydra.notebook")
    end,
  },

  --/////////////// TEST \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  {
    "chrisgrieser/nvim-spider",
    config = function()
      vim.keymap.set(
        { "n", "o", "x" },
        "W",
        "<cmd>lua require('spider').motion('w')<CR>",
        { desc = "Spider-w" }
      )
      vim.keymap.set(
        { "n", "o", "x" },
        "E",
        "<cmd>lua require('spider').motion('e')<CR>",
        { desc = "Spider-e" }
      )
      vim.keymap.set(
        { "n", "o", "x" },
        "B",
        "<cmd>lua require('spider').motion('b')<CR>",
        { desc = "Spider-b" }
      )
    end
  },
  { "RRethy/vim-illuminate" },
  { 'wakatime/vim-wakatime', lazy = false },
  { "cordx56/rustowl",       dependencies = { "neovim/nvim-lspconfig" } },

  {
    "anuvyklack/hydra.nvim",
    config = function()
      local Hydra = require('hydra')
      local window_hint = [[
        ^ ^^ Move     ^^Size   ^^   ^^Split   ^^   ^^Buffers
        ^ ^-------^^  ^^------^^   ^^----------^^ ^^---------
        ^^   ^^ _k_ ^^      ^^ _+_   ^ ^^  ^^_s_: horiz^^  ^^_r_: Inter
        ^ _h_ ^^ _w_^ ^ _l_ ^^  ^^_<_^^   ^^_>_  ^^  ^^_v_: vert^^   ^^_H_: Hor2Vert
        ^^   ^^ _j_ ^^      ^^ _-_   ^^   ^^_Q_: cerrar^^ ^^_J_:Vert2Hor
        	            ^^_=_: igual^
        ]]
      Hydra({
        name = "Windows",
        hint = window_hint,
        config = {},
        mode = 'n',
        body = '<C-w>',
        heads = {
          { '+', '<Cmd>res +3<CR>',                       { desc = 'Aumentar horizontal' } },
          { '-', '<Cmd>res -3<CR>',                       { desc = 'Disminuir horizontal' } },
          { '=', '<Cmd>wincmd =<CR>',                     { desc = 'Igualar horizontal' } },
          { '<', '<Cmd>vertical resize -3<CR>',           { desc = 'Disminuir vertical' } },
          { '>', '<Cmd>vertical resize +3<CR>',           { desc = 'Aumentar vertical' } },
          { 's', '<Cmd>wincmd s<CR>',                     { desc = 'Dividir Horizontal' } },
          { 'l', '<Cmd>wincmd l<CR>',                     { desc = 'Navegar Izquierda' } },
          { 'h', '<Cmd>wincmd h<CR>',                     { desc = 'Navegar Derecha' } },
          { 'v', '<Cmd>wincmd v<CR>',                     { desc = 'Dividr Vertical' } },
          { 'w', '<Cmd>wincmd w<CR>',                     { desc = 'Intercambiar cursor' } },
          { 'j', '<Cmd>wincmd j<CR>',                     { desc = 'Navegar Abajo' } },
          { 'r', '<Cmd>wincmd r<CR>',                     { desc = 'Intercambiar los buffers' } },
          { 'k', '<Cmd>wincmd k<CR>',                     { desc = 'Navegar Arriba' } },
          { 'Q', '<Cmd>try | close | catch | endtry<CR>', { desc = 'Cerrar buffer' } },
          { 'H', '<Cmd>wincmd H<CR>',                     { desc = 'Pasar de horizontal a vertical ' } },
          { 'J', '<Cmd>wincmd J<CR>',                     { desc = 'Pasar de vertical a horizontal' } } },
      })
    end
  },
  --{ 'andymass/vim-matchup' },
  {
    "phaazon/hop.nvim",
    config = function()
      require 'hop'.setup()
    end
  },
  { "lambdalisue/suda.vim" },
  { "github/copilot.vim" },
  { "farmergreg/vim-lastplace" },
  { "akinsho/bufferline.nvim" },
  --  {
  --    'mrcjkb/rustaceanvim',
  --    version = '^5', -- Recommended
  --    lazy = false,   -- This plugin is already lazy
  --  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "css", "scss", "html", "javascript", "json", "lua" }, {
        RGB = true,      -- #RGB hex codes
        RRGGBB = true,   -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true,   -- CSS rgb() and rgba() functions
        hsl_fn = true,   -- CSS hsl() and hsla() functions
        css = true,      -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true,   -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
    end,
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        preview = {
          command = "chafa",
          --command = "kitty +kitten icat --place 30x10@1x1",
          file_path = read_file_as_string("/home/plof/.config/lvim/nvim.txt"),
          file_height = 20,
          file_width = 90
        },
        theme = 'doom',
        config = {
          header = {}, --your header
          center = {
            { icon = '  ',
              desc = 'Recently opened files                   ',
              action = 'Telescope oldfiles', },
            { icon = '  ',
              desc = 'Find  File                              ',
              action = 'Telescope find_files find_command=rg,--hidden,--files', },
            { icon = '  ',
              desc = 'File Browser                            ',
              action = 'Lf', },
            { icon = '⇁  ',
              desc = 'Harpoon                                ',
              action = 'lua require("harpoon.ui").toggle_quick_menu()', },
            { icon = '  ',
              desc = 'Find text                                ',
              action = 'Telescope live_grep', },
            { icon = '  ',
              desc = 'Configuration                                ',
              action = 'e ~/.config/lvim/config.lua', },
          },
          footer = {}
        }
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  }
}

lvim.builtin.alpha.active = false -- Dashboard

--local function get_command_output(command)
--  local handle = io.popen(command)
--  local result = handle:read("*a")
--  handle:close()
--  return result
--end
--
--local dashboard = lvim.builtin.alpha.dashboard
--
--dashboard.section.header.val = vim.split(
--  get_command_output("chafa /home/plof/configs/hyde/themes/Leo/wallpapers/fondo2.png -f sixel --polite on"), "\n")
--
vim.g.neominimap = {
  auto_enable = false
}
