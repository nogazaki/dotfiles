local M = {}

--------------------------------------------------

local snacks = { 'folke/snacks.nvim' }
snacks.priority = 1000
snacks.event = 'VimEnter'
snacks.config = function()
  local opts = {}

  local dashboard = { enabled = true }
  dashboard.width = 45
  dashboard.sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 2 },
    { section = 'startup' },
  }

  local layout = {}
  layout = { box = 'horizontal', width = 0.8, height = 0.8, min_width = 120 }
  layout[1] = { box = 'vertical', border = 'rounded', title = '{live}{title} {flags}' }
  layout[1][1] = { win = 'input', height = 1 }
  layout[1][2] = { win = 'list', border = 'top' }
  layout[2] = { win = 'preview', width = 0.5, border = 'rounded' }

  local picker = { enabled = true, layout = {}, layouts = { default = { layout = layout } } }
  picker.win = { preview = { wo = { number = false, statuscolumn = '', signcolumn = 'no' } } }
  picker.sources = { explorer = { layout = { layout = { width = 30, backdrop = false } } } }

  opts.input = { enabled = true }
  opts.zen = { enabled = true }
  opts.dim = { enabled = true, scope = { min_size = 1, max_size = 20, siblings = true } }
  opts.dashboard = dashboard
  opts.picker = picker

  require('snacks').setup(opts)

  Snacks.toggle.dim():map('<leader>td')
  Snacks.toggle.zen():map('<leader>tz')

  vim.keymap.set('n', '<leader>sc', function()
    Snacks.picker.files({ cwd = vim.fn.stdpath('config') })
  end, { desc = '[c]onfigurations' })

  vim.keymap.set('n', '<leader>sh', Snacks.picker.help, { desc = '[h]elps' })
  vim.keymap.set('n', '<leader>sb', Snacks.picker.buffers, { desc = '[b]uffers' })
  vim.keymap.set('n', '<leader>se', Snacks.picker.explorer, { desc = '[e]xplorer' })
  vim.keymap.set('n', '<leader>sf', Snacks.picker.files, { desc = '[f]iles' })
  vim.keymap.set('n', '<leader>sg', Snacks.picker.grep, { desc = 'content with [g]rep' })
  vim.keymap.set('n', '<leader>sl', Snacks.picker.resume, { desc = '[l]ast search' })

  vim.g.snacks_animate = false
end

table.insert(M, snacks)

--------------------------------------------------

local mini = { 'echasnovski/mini.nvim' }
mini.version = false
mini.event = 'VimEnter'
mini.config = function()
  require('mini.surround').setup()
  require('mini.pairs').setup()
  require('mini.bracketed').setup()
end

table.insert(M, mini)

--------------------------------------------------

return M
