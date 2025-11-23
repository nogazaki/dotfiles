local M = {}

--------------------------------------------------

local tmux = { 'christoomey/vim-tmux-navigator' }
tmux.config = function()
  local keymap = vim.keymap.set

  keymap('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Move focus to the left window' })
  keymap('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Move focus to the below window' })
  keymap('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Move focus to the above window' })
  keymap('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Move focus to the rigth window' })
end

table.insert(M, tmux)

--------------------------------------------------

local whichkey = { 'folke/which-key.nvim' }
whichkey.event = 'UIEnter'
whichkey.keys = { '<leader>', 'g' }
whichkey.config = function()
  local wk = require('which-key')
  wk.add({ '<leader>s', icon = '', group = '[s]earch' })
  wk.add({ '<leader>t', icon = '', group = '[t]oggle' })
  wk.add({ '<leader>o', icon = '', group = '[o]rgmode' })
  wk.add({ '<leader>g', icon = '', group = '[g]it' })
end

table.insert(M, whichkey)

--------------------------------------------------

return M
