-- Silenciar avisos de deprecación (ESENCIAL al inicio en versiones experimentales)
vim.deprecate = function() end
vim.g.deprecation_warnings = false

-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

vim.keymap.set("n", "nh", ":HopWord<CR>")
vim.keymap.set("n", "<TAB>", ":bnext<CR>")
vim.keymap.set("n", "<S-TAB>", ":bprev<CR>")
vim.keymap.set("n", "<C-c>", ":bdelete<CR>")
vim.api.nvim_set_keymap("i", "<C-Tab>", 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_trail_size = 1.0
vim.g.neovide_cursor_animation_length = 0.1
vim.g.neovide_cursor_vfx_particle_density = 1.0
--vim.keymap.set("n", "<C-o>", require("rustowl").rustowl_cursor, { noremap = true, silent = true })

function read_file_as_string(filepath)
  local file = io.open(filepath, "r")
  if not file then error("No se pudo abrir el archivo: " .. filepath) end

  local content = file:read "*a"
  file:close()
  return content
end

vim.g.neominimap = {
  auto_enable = false,
}

vim.keymap.set("n", "<C-f>", "<Cmd>Yazi toggle<CR>")

-- Fix for Neovim v0.12 Treesitter Markdown crash
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = "on"
  end,
})

-- Silenciar avisos de deprecación (útil en versiones experimentales de nvim)
-- Neovim v0.12 usa vim.deprecate para estos mensajes.
vim.deprecate = function() end
