local M = {}

--------------------------------------------------

local lang_rust = { 'mrcjkb/rustaceanvim' }
lang_rust.version = '^6'
lang_rust.ft = { 'rust' }

table.insert(M, lang_rust)

--------------------------------------------------

local lang_ledger = { 'ledger/vim-ledger' }
lang_ledger.ft = 'ledger'

table.insert(M, lang_ledger)

--------------------------------------------------

local debugger = { 'mfussenegger/nvim-dap' }
debugger.dependencies = { 'nvim-neotest/nvim-nio' }
debugger.keys = {
  vim.custom.lazy_key('n', '<leader>dd', function()
    require('dapui').open()
    require('dap').continue()
  end, { desc = '[c]ontinue' }),
  vim.custom.lazy_key('n', '<leader>dq', function()
    require('dap').terminate()
    require('dapui').close()
  end, { desc = '[q]uit' }),
  vim.custom.lazy_key('n', '<leader>db', function()
    require('dap').toggle_breakpoint()
  end, { desc = 'toggle [b]reakpoint' }),
}
debugger.config = function()
  local dap = require('dap')

  dap.adapters.lldb = {
    name = 'lldb',
    type = 'executable',
    command = '/usr/bin/lldb-dap',
  }
end

table.insert(M, debugger)

--------------------------------------------------

local debugger_ui = { 'rcarriga/nvim-dap-ui' }
debugger_ui.dependencies = { 'mfussenegger/nvim-dap' }
debugger_ui.lazy = true
debugger_ui.opts = {}

table.insert(M, debugger_ui)

--------------------------------------------------

return M
