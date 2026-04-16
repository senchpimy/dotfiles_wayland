---@type LazySpec
return {

  --"andweeb/presence.nvim", -- Discord trash/ migth use
      "benlubas/molten-nvim",
  "sindrets/diffview.nvim" ,
{
    "ray-x/lsp_signature.nvim",
    event = "BufRead", -- Carga el plugin cuando abres un archivo
    opts = {
      bind = true, -- Esencial para que funcionen los bordes y otras configuraciones
      handler_opts = {
        border = "rounded", -- Estilo del borde: "rounded", "single", "double", "shadow"
      },
      hint_prefix = "💡 ", -- Prefijo para la ayuda de parámetros (puedes usar "🐼 ", "▸ ", etc.)
      zindex = 200,      -- Asegura que la ventana flotante aparezca sobre otros elementos como el menú de autocompletado
      doc_lines = 5,     -- Muestra hasta 5 líneas de documentación en la ventana flotante
      floating_window_above_cur_line = true, -- Intenta mostrar la ventana sobre la línea actual para no tapar el autocompletado
      max_width = 80,    -- Ancho máximo de la ventana flotante
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)

      vim.keymap.set({ 'n' }, '<leader>lk', function()
        require('lsp_signature').toggle_float_win()
      end, { silent = true, noremap = true, desc = 'Toggle signature help' })
    end
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          {
            section='terminal',
            --cmd = 'chafa ~/img.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1',
            cmd = "pokemon-colorscripts -r --no-title; sleep .1",
            random=18,
            height = 18,
            padding = 1,
          },
          {
            pane = 2,
            { section = "keys", gap = 1, padding = 1 },
            --{ section = "startup" },
          },
        }
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  ---- Personal -----
  { "mattn/emmet-vim" },
  { "jeetsukumaran/vim-indentwise" },
  {
    "senchpimy/liverserver.nvim",
    config = function()
      require('liveserver')
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },
  {
  "mikavilpas/yazi.nvim",
    config = function()
      require("yazi").setup()
      vim.keymap.set("n", "<C-f>", "<Cmd>Yazi<CR>")
    end,
  },
  --{
  --  "lmburns/lf.nvim",
  --  config = function()
  --    vim.g.lf_netrw = 1

  --    require("lf").setup({
  --      default_cmd = "/bin/lf",
  --      escape_quit = true,
  --      border = "rounded",
  --    })

  --    vim.keymap.set("n", "<C-f>", "<Cmd>Lf<CR>")
  --  end,
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
  --[[
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
  ]]--
  --/////////////// TEST \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  { "Isrothy/neominimap.nvim",
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = false,
    }
  end,
  },
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
  --{ 'numToStr/Comment.nvim' },
  --{
  --  "lukas-reineke/indent-blankline.nvim",
  --  main = "ibl",
  --  ---@module "ibl"
  --  ---@type ibl.config
  --  opts = {},
  --},
  --{
  --  'windwp/nvim-autopairs',
  --  event = "InsertEnter",
  --  config = true
  --  -- use opts = {} for passing setup options
  --  -- this is equivalent to setup({}) function
  --},
  --https://github.com/edluffy/hologram.nvim
  --{ 'wakatime/vim-wakatime', lazy = false },
  --{ "cordx56/rustowl",       dependencies = { "neovim/nvim-lspconfig" } },

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
  --{ "akinsho/bufferline.nvim" },
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
  --{
  --  'nvimdev/dashboard-nvim',
  --  event = 'VimEnter',
  --  config = function()
  --    require('dashboard').setup {
  --      preview = {
  --        command = "chafa",
  --        --command = "kitty +kitten icat --place 30x10@1x1",
  --        file_path = read_file_as_string("/home/plof/.config/lvim/nvim.txt"),
  --        file_height = 20,
  --        file_width = 90
  --      },
  --      theme = 'doom',
  --      config = {
  --        header = {}, --your header
  --        center = {
  --          { icon = '  ',
  --            desc = 'Recently opened files                   ',
  --            action = 'Telescope oldfiles', },
  --          { icon = '  ',
  --            desc = 'Find  File                              ',
  --            action = 'Telescope find_files find_command=rg,--hidden,--files', },
  --          { icon = '  ',
  --            desc = 'File Browser                            ',
  --            action = 'Lf', },
  --          { icon = '⇁  ',
  --            desc = 'Harpoon                                ',
  --            action = 'lua require("harpoon.ui").toggle_quick_menu()', },
  --          { icon = '  ',
  --            desc = 'Find text                                ',
  --            action = 'Telescope live_grep', },
  --          { icon = '  ',
  --            desc = 'Configuration                                ',
  --            action = 'e ~/.config/lvim/config.lua', },
  --        },
  --        footer = {}
  --      }
  --    }
  --  end,
  --  dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  --},
  {"nvim-telescope/telescope.nvim"},
  {
    "giusgad/pets.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "giusgad/hologram.nvim" },
      config=function()
        require("pets").setup(
        {
          row = 1, -- the row (height) to display the pet at (higher row means the pet is lower on the screen), must be 1<=row<=10
          col = 0, -- the column to display the pet at (set to high number to have it stay still on the right side)
          speed_multiplier = 1, -- you can make your pet move faster/slower. If slower the animation will have lower fps.
          default_pet = "dog", -- the pet to use for the PetNew command
          default_style = "brown", -- the style of the pet to use for the PetNew command
          random = true, -- whether to use a random pet for the PetNew command, overrides default_pet and default_style
          death_animation = true, -- animate the pet's death, set to false to feel less guilt -- currently no animations are available
          popup = { -- popup options, try changing these if you see a rectangle around the pets
            width = "30%", -- can be a string with percentage like "45%" or a number of columns like 45
            winblend = 100, -- winblend value - see :h 'winblend' - only used if avoid_statusline is false
            hl = { Normal = "Normal" }, -- hl is only set if avoid_statusline is true, you can put any hl group instead of "Normal"
            avoid_statusline = false, -- if winblend is 100 then the popup is invisible and covers the statusline, if that
            -- doesn't work for you then set this to true and the popup will use hl and will be spawned above the statusline (hopefully)
          }
        }
      )
      end
  }
}

-- https://github.com/nvim-mini/mini.comment
-- https://github.com/michaelb/sniprun
-- https://github.com/benlubas/molten-nvim 
