-- Setting leader key MUST happen before plugins are loaded, otherwise wrong leader key will be used
-- See also `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Customized, global objects
vim.custom = {}

require('options')
require('diagnostic')
require('autocmd')
require('lsp')

-- Bootstrap `lazy.nvim`
-- See also `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim
local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazy_path) then
  local lazy_repo = 'https://github.com/folke/lazy.nvim.git'
  local output = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazy_repo, lazy_path })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { output .. '\n', 'ErrorMsg' },
      { 'Press any key to exit...' },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

-- Helper function to create `lazy`'s keymap
vim.custom.lazy_key = function(mode, key, command, args)
  return vim.tbl_extend('keep', { key, command, mode = mode }, args)
end

-- Setup `lazy.nvim`
vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
  checker = { enabled = true },
  install = { colorscheme = { 'catppuccin', 'habamax' } },
  ui = { border = 'rounded', icons = { ft = ' ', lazy = '󰂠 ', loaded = ' ', not_loaded = ' ' } },
  spec = { { import = 'lazyspec' } },
})

vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')
