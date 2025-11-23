local M = {}

--------------------------------------------------

local interface = { 'NeogitOrg/neogit' }
interface.dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' }
interface.keys = {
  vim.custom.lazy_key('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'open [g]it interface (neogit)' }),
}
interface.opts = {
  graph_style = 'kitty',
  disable_hint = true,
  disable_signs = true,
  integrations = { diffview = true, snacks = true },
  sections = { untracked = { folded = true, hidden = false } },
}

table.insert(M, interface)

--------------------------------------------------

local signs = { 'lewis6991/gitsigns.nvim' }
signs.event = 'VeryLazy'
signs.opts = { current_line_blame = true }
signs.opts.on_attach = function(bufnr)
  local gs = require('gitsigns')
  local function keymap(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  keymap('n', '[c', function()
    gs.nav_hunk('prev')
  end, { desc = 'previous git [c]hange' })
  keymap('n', ']c', function()
    gs.nav_hunk('next')
  end, { desc = 'next git [c]hange' })

  keymap('n', '<leader>gs', function()
    gs.stage_hunk()
  end, { desc = '[s]tage this git change' })
  keymap('v', '<leader>gs', function()
    gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
  end, { desc = '[s]tage this git change' })
end

table.insert(M, signs)

--------------------------------------------------

return M
