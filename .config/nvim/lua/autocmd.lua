local yank_hl = { desc = 'Highlight when yanking (copying) text' }
yank_hl.callback = function()
  vim.hl.on_yank() -- need the `function` wrap, doesn't work without it (?)
end

vim.api.nvim_create_autocmd('TextYankPost', yank_hl)

--------------------------------------------------

local lazy_augroup = vim.api.nvim_create_augroup('LazyPatches', { clear = false })
local patches = vim.fn.readdir(vim.fn.stdpath('config') .. '/lua/lazypatches')

local reset_plugins = { desc = '', pattern = 'LazyUpdatePre', group = lazy_augroup }
reset_plugins.callback = function()
  for _, patch in ipairs(patches) do
    local cwd = vim.fn.stdpath('data') .. '/lazy/' .. patch:match('(.+)%..+$') .. '/'
    vim.system({ 'git', 'reset', '--hard' }, { cwd = cwd })
  end
end

local patch_plugins = { desc = '', pattern = { 'LazySync', 'LazyUpdate' }, group = lazy_augroup }
patch_plugins.callback = function()
  for _, patch in ipairs(patches) do
    local cwd = vim.fn.stdpath('data') .. '/lazy/' .. patch:match('(.+)%..+$') .. '/'
    vim.system({ 'git', 'apply', vim.fn.stdpath('config') .. '/lua/lazypatches/' .. patch }, { cwd = cwd })
  end
end

vim.api.nvim_create_autocmd('User', reset_plugins)
vim.api.nvim_create_autocmd('User', patch_plugins)
